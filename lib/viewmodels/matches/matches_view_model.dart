import '../../models/match/match_model.dart';
import '../../services/interfaces/i_match_service.dart';
import '../base/base_view_model.dart';

class MatchesViewModel extends BaseViewModel {
  final IMatchService _matchService;

  MatchesViewModel({required IMatchService matchService})
      : _matchService = matchService;

  List<MatchModel> _matches = [];

  List<MatchModel> get matches => _matches;
  List<MatchModel> get newMatches => _matches.where((m) => m.isNew).toList();
  List<MatchModel> get conversations =>
      _matches.where((m) => m.lastMessage != null).toList();

  Future<void> loadMatches() async {
    setLoading();
    final response = await _matchService.getMatches();
    if (!response.isSuccess) {
      setError(response.error?.message ?? response.message);
      return;
    }
    if (!response.hasData || response.data!.isEmpty) {
      setEmpty();
      return;
    }
    _matches = response.data!;
    setIdle();
  }

  Future<void> unmatch(String matchId) async {
    await _matchService.unmatch(matchId);
    _matches.removeWhere((m) => m.id == matchId);
    if (_matches.isEmpty) {
      setEmpty();
    } else {
      notifyListeners();
    }
  }
}
