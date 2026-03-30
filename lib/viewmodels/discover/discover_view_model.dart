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

  // 24 saatlik gruplama: her gün belirli bir "epoch day" bazında
  // 10 kişilik dilim seçilir.
  static const int _groupSize = 10;

  int get _todayEpoch =>
      DateTime.now().toUtc().millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// Bugünkü gruba ait 10 kişi.
  List<DiscoverCardModel> get dailyGroup {
    if (_allCards.isEmpty) return [];
    final epoch = _todayEpoch;
    final total = _allCards.length;
    // Her gün farklı başlangıç indeksi
    final startIndex = (epoch * _groupSize) % total;
    final List<DiscoverCardModel> group = [];
    for (var i = 0; i < _groupSize; i++) {
      group.add(_allCards[(startIndex + i) % total]);
    }
    return group;
  }

  String? get selectedFilter => _selectedFilter;

  /// Unique interest tags from today's group, sorted alphabetically.
  List<String> get availableFilters {
    final all = <String>{};
    for (final c in dailyGroup) {
      all.addAll(c.interests);
    }
    return all.toList()..sort();
  }

  /// Today's group filtered by interest, excluding already connected friends.
  /// (Pending requests stay in the list).
  List<DiscoverCardModel> get filteredCards {
    return dailyGroup.where((c) {
      if (_connectedIds.contains(c.id)) return false;
      if (_selectedFilter != null && !c.interests.contains(_selectedFilter)) {
        return false;
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

  Future<void> loadCards() async {
    setLoading();
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

