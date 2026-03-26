import '../../models/auth/auth_result_model.dart';
import '../../models/common/base_response.dart';

abstract class IAuthService {
  Future<BaseResponse<AuthResultModel>> signInWithGoogle();
  Future<BaseResponse<AuthResultModel>> signInWithApple();
  Future<BaseResponse<void>> signOut();
}
