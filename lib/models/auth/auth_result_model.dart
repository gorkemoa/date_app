import '../../core/enums/app_enums.dart';

class AuthResultModel {
  final String userId;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final AuthProvider provider;

  const AuthResultModel({
    required this.userId,
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.provider,
  });
}
