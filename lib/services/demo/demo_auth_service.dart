import 'dart:math';

import '../../core/constants/app_constants.dart';
import '../../core/enums/app_enums.dart';
import '../../models/auth/auth_result_model.dart';
import '../../models/common/base_response.dart';
import '../interfaces/i_auth_service.dart';

class DemoAuthService implements IAuthService {
  @override
  Future<BaseResponse<AuthResultModel>> signInWithGoogle() async {
    await Future.delayed(AppConstants.mediumDelay);
    return BaseResponse.success(
      data: AuthResultModel(
        userId: 'demo_google_${Random().nextInt(9999)}',
        displayName: 'Demo Kullanıcı',
        email: 'demo@gmail.com',
        photoUrl: 'https://i.pravatar.cc/200?img=12',
        provider: AuthProvider.google,
      ),
    );
  }

  @override
  Future<BaseResponse<AuthResultModel>> signInWithApple() async {
    await Future.delayed(AppConstants.mediumDelay);
    return BaseResponse.success(
      data: AuthResultModel(
        userId: 'demo_apple_${Random().nextInt(9999)}',
        displayName: 'Demo Kullanıcı',
        email: 'demo@icloud.com',
        provider: AuthProvider.apple,
      ),
    );
  }

  @override
  Future<BaseResponse<void>> signOut() async {
    await Future.delayed(AppConstants.shortDelay);
    return BaseResponse.success(data: null);
  }
}
