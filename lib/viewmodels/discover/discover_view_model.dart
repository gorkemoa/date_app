import '../../models/discover/discover_card_model.dart';
import '../../services/interfaces/i_discover_service.dart';
import '../base/base_view_model.dart';

class DiscoverViewModel extends BaseViewModel {
  final IDiscoverService _discoverService;

  DiscoverViewModel({required IDiscoverService discoverService})
      : _discoverService = discoverService;

  List<DiscoverCardModel> _allCards = [];
  final Set<String> _passedIds = {};
  final Set<String> _connectedIds = {};
  String? _selectedFilter;

  String? get selectedFilter => _selectedFilter;

  /// Unique interest tags from all loaded cards, sorted alphabetically.
  List<String> get availableFilters {
    final all = <String>{};
    for (final c in _allCards) {
      all.addAll(c.interests);
    }
    return all.toList()..sort();
  }

  /// Cards excluding acted-upon entries, optionally filtered by interest.
  List<DiscoverCardModel> get filteredCards {
    return _allCards.where((c) {
      if (_passedIds.contains(c.id) || _connectedIds.contains(c.id)) {
        return false;
      }
      if (_selectedFilter != null && !c.interests.contains(_selectedFilter)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Top-compatibility cards (≥ 80%) regardless of active filter.
  List<DiscoverCardModel> get topMatches {
    final list = _allCards.where((c) {
      return !_passedIds.contains(c.id) &&
          !_connectedIds.contains(c.id) &&
          (c.compatibilityScore ?? 0) >= 0.80;
    }).toList();
    list.sort(
        (a, b) => (b.compatibilityScore ?? 0).compareTo(a.compatibilityScore ?? 0));
    return list;
  }

  bool get hasCards => filteredCards.isNotEmpty;

  // Kept for legacy callers; returns first visible card.
  DiscoverCardModel? get currentCard =>
      filteredCards.isNotEmpty ? filteredCards.first : null;

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
    _passedIds.clear();
    _connectedIds.clear();
    setIdle();
  }

  /// Send a connection request — removes card from visible list optimistically.
  Future<void> connect(String id) async {
    _connectedIds.add(id);
    notifyListeners();
    await _discoverService.swipeRight(id);
  }

  /// Pass on a card — removes from visible list optimistically.
  Future<void> pass(String id) async {
    _passedIds.add(id);
    notifyListeners();
    await _discoverService.swipeLeft(id);
  }

  // ── Legacy wrappers kept for backward compatibility ──

  Future<void> swipeRight() async {
    final card = currentCard;
    if (card == null) return;
    await connect(card.id);
  }

  Future<void> swipeLeft() async {
    final card = currentCard;
    if (card == null) return;
    await pass(card.id);
  }

  Future<void> superLike() async {
    final card = currentCard;
    if (card == null) return;
    await connect(card.id);
  }
}

