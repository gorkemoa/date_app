import '../../core/enums/app_enums.dart';
import '../../models/auth/auth_result_model.dart';
import '../../models/common/base_response.dart';
import '../../services/interfaces/i_auth_service.dart';
import '../base/base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  final IAuthService _authService;

  AuthViewModel({required IAuthService authService})
      : _authService = authService;

  AuthResultModel? _authResult;
  AuthResultModel? get authResult => _authResult;

  Future<bool> signIn(AuthProvider provider) async {
    clearError();
    setLoading();
    final BaseResponse<AuthResultModel> res = provider == AuthProvider.google
        ? await _authService.signInWithGoogle()
        : await _authService.signInWithApple();

    if (res.isSuccess && res.data != null) {
      _authResult = res.data;
      setIdle();
      return true;
    } else {
      setError(res.error?.message ?? 'Giriş yapılamadı. Lütfen tekrar deneyin.');
      return false;
    }
  }
}
