import '../../models/common/base_response.dart';
import '../../models/discover/discover_card_model.dart';

abstract interface class IDiscoverService {
  Future<BaseResponse<List<DiscoverCardModel>>> getDiscoverCards({int page = 1});
  Future<BaseResponse<DiscoverCardModel>> getCardDetail(String userId);
  Future<BaseResponse<void>> swipeRight(String userId);
  Future<BaseResponse<void>> swipeLeft(String userId);
  Future<BaseResponse<void>> superLike(String userId);
}
