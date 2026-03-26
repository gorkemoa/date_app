import '../../models/discover/discover_card_model.dart';
import '../../services/interfaces/i_discover_service.dart';
import '../base/base_view_model.dart';

class DiscoverViewModel extends BaseViewModel {
  final IDiscoverService _discoverService;

  DiscoverViewModel({required IDiscoverService discoverService})
      : _discoverService = discoverService;

  List<DiscoverCardModel> _cards = [];
  int _currentIndex = 0;

  List<DiscoverCardModel> get cards => _cards;
  int get currentIndex => _currentIndex;
  bool get hasCards => _cards.isNotEmpty && _currentIndex < _cards.length;
  DiscoverCardModel? get currentCard => hasCards ? _cards[_currentIndex] : null;

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
    _cards = response.data!;
    _currentIndex = 0;
    setIdle();
  }

  Future<void> swipeRight() async {
    final card = currentCard;
    if (card == null) return;
    _currentIndex++;
    notifyListeners();
    await _discoverService.swipeRight(card.id);
  }

  Future<void> swipeLeft() async {
    final card = currentCard;
    if (card == null) return;
    _currentIndex++;
    notifyListeners();
    await _discoverService.swipeLeft(card.id);
  }

  Future<void> superLike() async {
    final card = currentCard;
    if (card == null) return;
    _currentIndex++;
    notifyListeners();
    await _discoverService.superLike(card.id);
  }
}
