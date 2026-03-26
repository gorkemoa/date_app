import '../../models/common/base_response.dart';
import '../../models/profile/profile_model.dart';

abstract interface class IProfileService {
  Future<BaseResponse<ProfileModel>> getMyProfile();
  Future<BaseResponse<ProfileModel>> updateProfile(ProfileModel profile);
  Future<BaseResponse<List<String>>> getInterests();
}
