import '../../models/common/base_response.dart';
import '../../models/match/match_model.dart';

abstract interface class IMatchService {
  Future<BaseResponse<List<MatchModel>>> getMatches({int page = 1});
  Future<BaseResponse<MatchModel>> getMatchDetail(String matchId);
  Future<BaseResponse<void>> unmatch(String matchId);
}
