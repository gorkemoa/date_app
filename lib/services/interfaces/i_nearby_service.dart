import '../../models/common/base_response.dart';
import '../../models/nearby/nearby_user_model.dart';

abstract interface class INearbyService {
  Future<BaseResponse<List<NearbyUserModel>>> getNearbyUsers();
  Future<BaseResponse<NearbyUserModel>> getMyLocation();
}
