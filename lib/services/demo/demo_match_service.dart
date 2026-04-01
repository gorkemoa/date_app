import '../../core/constants/app_constants.dart';
import '../../models/common/api_error.dart';
import '../../models/common/base_response.dart';
import '../../models/match/match_model.dart';
import '../interfaces/i_match_service.dart';

class DemoMatchService implements IMatchService {
  final List<MatchModel> _matches = [
    MatchModel(
      id: 'm1',
      userId: '1',
      userName: 'Ayşe',
      userPhoto: 'https://randomuser.me/api/portraits/women/1.jpg',
      lastMessage: 'Merhaba! 👋',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isNew: true,
      unreadCount: 1,
    ),
    MatchModel(
      id: 'm2',
      userId: '2',
      userName: 'Zeynep',
      userPhoto: 'https://randomuser.me/api/portraits/women/9.jpg',
      lastMessage: 'Nasılsın?',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
      isNew: false,
      unreadCount: 0,
    ),
    MatchModel(
      id: 'm3',
      userId: '5',
      userName: 'Deniz',
      userPhoto: 'https://randomuser.me/api/portraits/women/17.jpg',
      lastMessage: null,
      lastMessageAt: null,
      isNew: true,
      unreadCount: 0,
    ),
    MatchModel(
      id: 'm4',
      userId: '9',
      userName: 'Selin',
      userPhoto: 'https://randomuser.me/api/portraits/women/44.jpg',
      lastMessage: null,
      lastMessageAt: null,
      isNew: true,
      unreadCount: 0,
    ),
    MatchModel(
      id: 'm5',
      userId: '10',
      userName: 'Elif',
      userPhoto: 'https://randomuser.me/api/portraits/women/68.jpg',
      lastMessage: null,
      lastMessageAt: null,
      isNew: true,
      unreadCount: 0,
    ),
  ];

  @override
  Future<BaseResponse<List<MatchModel>>> getMatches({int page = 1}) async {
    await Future.delayed(AppConstants.mediumDelay);
    if (_matches.isEmpty) {
      return BaseResponse.empty(message: 'Henüz eşleşme yok');
    }
    return BaseResponse.success(data: List.unmodifiable(_matches));
  }

  @override
  Future<BaseResponse<MatchModel>> getMatchDetail(String matchId) async {
    await Future.delayed(AppConstants.shortDelay);
    final match = _matches.where((m) => m.id == matchId).firstOrNull;
    if (match == null) {
      return BaseResponse.failure(
        error: const ApiError(code: 'NOT_FOUND', message: 'Eşleşme bulunamadı'),
      );
    }
    return BaseResponse.success(data: match);
  }

  @override
  Future<BaseResponse<void>> unmatch(String matchId) async {
    await Future.delayed(AppConstants.shortDelay);
    _matches.removeWhere((m) => m.id == matchId);
    return BaseResponse.success(data: null, message: 'Eşleşme kaldırıldı');
  }
}
