import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';

import '../../models/discover/discover_card_model.dart';
import '../../services/interfaces/i_discover_service.dart';
import '../base/base_view_model.dart';

class DiscoverViewModel extends BaseViewModel {
  final IDiscoverService _discoverService;

  DiscoverViewModel({required IDiscoverService discoverService})
    : _discoverService = discoverService;

  List<DiscoverCardModel> _allCards = [];
  final Set<String> _connectedIds = {};
  final Set<String> _pendingRequestIds = {};
  String? _selectedFilter;
  final Map<String, String> _skillToCategory = {};
  List<String> _userInterests = [];
  final Map<String, int> _categoryWeights = {};

  String formatSkillCategory(String key) {
    if (key == 'yazilim_ve_teknoloji') return 'Yazılım ve Teknoloji';
    if (key == 'tasarim_ve_yartici_isler') return 'Tasarım ve Yaratıcı İşler';
    if (key == 'pazarlama_ve_sosyal_medya') return 'Pazarlama ve Sosyal Medya';
    if (key == 'urun_ve_proje_yonetimi') return 'Ürün ve Proje Yönetimi';
    if (key == 'is_gelistirme_ve_satis') return 'İş Geliştirme ve Satış';
    if (key == 'insan_kaynaklari_ve_idari') return 'İnsan Kaynakları ve İdari';
    if (key == 'finans_ve_danismanlik') return 'Finans ve Danışmanlık';
    if (key == 'egitim_ve_diger_beyaz_yaka') return 'Eğitim ve Diğer';
    return key
        .split('_')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }

  // 24 saatlik gruplama: her gün belirli bir "epoch day" bazında
  // 10 kişilik dilim seçilir.
  static const int _groupSize = 10;

  int get _todayEpoch =>
      DateTime.now().toUtc().millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// Sored group of 10 people based on user interest density.
  List<DiscoverCardModel> get dailyGroup {
    if (_allCards.isEmpty) return [];

    // Sort all cards by density score if weights are available
    final sortedCards = List<DiscoverCardModel>.from(_allCards);
    if (_categoryWeights.isNotEmpty) {
      sortedCards.sort((a, b) {
        final scoreA = _calculateScore(a);
        final scoreB = _calculateScore(b);
        return scoreB.compareTo(scoreA); // Higher score first
      });
    }

    final epoch = _todayEpoch;
    final total = sortedCards.length;
    final startIndex = (epoch * _groupSize) % total;
    final List<DiscoverCardModel> group = [];
    for (var i = 0; i < _groupSize; i++) {
      group.add(sortedCards[(startIndex + i) % total]);
    }
    return group;
  }

  double _calculateScore(DiscoverCardModel card) {
    if (_categoryWeights.isEmpty) return 0;
    double score = 0;
    for (final skill in card.interests) {
      final category = _skillToCategory[skill];
      if (category != null) {
        score += _categoryWeights[category] ?? 0;
      }
    }
    return score;
  }

  String? get selectedFilter => _selectedFilter;

  /// Unique interest tags from today's group, sorted alphabetically.
  /// Unique interest categories (titles) from today's group, sorted alphabetically.
  List<String> get availableFilters {
    final all = <String>{};
    for (final c in dailyGroup) {
      for (final s in c.interests) {
        final cat = _skillToCategory[s];
        if (cat != null) all.add(cat);
      }
    }
    return all.toList()..sort();
  }

  /// Today's group filtered by category title, excluding already connected friends.
  /// (Pending requests stay in the list).
  List<DiscoverCardModel> get filteredCards {
    return dailyGroup.where((c) {
      if (_connectedIds.contains(c.id)) return false;
      if (_selectedFilter != null) {
        final cardCategories = c.interests
            .map((s) => _skillToCategory[s])
            .where((cat) => cat != null)
            .toSet();
        if (!cardCategories.contains(_selectedFilter)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  bool isPendingRequest(String id) => _pendingRequestIds.contains(id);

  bool get hasCards => filteredCards.isNotEmpty;

  DiscoverCardModel? get currentCard =>
      filteredCards.isNotEmpty ? filteredCards.first : null;

  /// Bir sonraki grup yenilenene kadar kalan süre.
  Duration get timeUntilRefresh {
    final now = DateTime.now().toUtc();
    final nextMidnight = DateTime.utc(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }

  /// Toggle a filter. Tapping the active filter clears it.
  void setFilter(String? filter) {
    _selectedFilter = _selectedFilter == filter ? null : filter;
    notifyListeners();
  }

  Future<void> loadCards({List<String>? userInterests}) async {
    setLoading();
    if (userInterests != null) {
      _userInterests = userInterests;
      _calculateWeights();
    }

    // Load skills dictionary formatting
    if (_skillToCategory.isEmpty) {
      try {
        final jsonStr = await rootBundle.loadString('assets/skills.json');
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final roles = data['professional_roles'] as Map<String, dynamic>;
        for (final entry in roles.entries) {
          final title = formatSkillCategory(entry.key);
          for (final skill in List<String>.from(entry.value)) {
            _skillToCategory[skill] = title;
          }
        }
        // Recalculate weights once dict is loaded
        _calculateWeights();
      } catch (e) {
        dev.log('Error loading skills in discover: $e');
      }
    }
    final response = await _discoverService.getDiscoverCards();
    if (!response.isSuccess) {
      setError(response.error?.message ?? response.message);
      return;
    }
    if (!response.hasData || response.data!.isEmpty) {
      setEmpty();
      return;
    }
    _allCards = response.data!;
    _connectedIds.clear();
    _pendingRequestIds.clear();
    setIdle();
  }

  void _calculateWeights() {
    if (_userInterests.isEmpty || _skillToCategory.isEmpty) return;
    _categoryWeights.clear();
    for (final skill in _userInterests) {
      final category = _skillToCategory[skill];
      if (category != null) {
        _categoryWeights[category] = (_categoryWeights[category] ?? 0) + 1;
      }
    }
  }

  /// Bağlantı isteği gönder — durumu 'istek gönderildi' olarak işaretle.
  Future<void> connect(String id) async {
    _pendingRequestIds.add(id);
    notifyListeners();
    // Simulate API delay, normally this stays as a request until accepted.
    await _discoverService.swipeRight(id);
  }

  // Legacy compat
  Future<void> swipeRight() async {
    final card = currentCard;
    if (card == null) return;
    await connect(card.id);
  }
}
