import '../../core/constants/app_constants.dart';
import '../../models/common/base_response.dart';
import '../../models/profile/profile_model.dart';
import '../interfaces/i_profile_service.dart';

class DemoProfileService implements IProfileService {
  ProfileModel _profile = const ProfileModel(
    id: 'me',
    name: 'Ahmet',
    age: 28,
    bio: 'Teknoloji ve tasarım tutkunu. Yeni insanlarla tanışmayı seviyorum.',
    occupation: 'Product Manager',
    location: 'İstanbul',
    photoUrls: ['https://i.pravatar.cc/600?img=12'],
    interests: ['Teknoloji', 'Tasarım', 'Seyahat', 'Spor'],
    isVerified: true,
    profileCompletionPercent: 85,
  );

  @override
  Future<BaseResponse<ProfileModel>> getMyProfile() async {
    await Future.delayed(AppConstants.mediumDelay);
    return BaseResponse.success(data: _profile);
  }

  @override
  Future<BaseResponse<ProfileModel>> updateProfile(ProfileModel profile) async {
    await Future.delayed(AppConstants.mediumDelay);
    _profile = profile;
    return BaseResponse.success(data: _profile, message: 'Profil güncellendi');
  }

  @override
  Future<BaseResponse<List<String>>> getInterests() async {
    await Future.delayed(AppConstants.shortDelay);
    const interests = [
      'Müzik', 'Seyahat', 'Spor', 'Yemek', 'Teknoloji',
      'Sanat', 'Sinema', 'Kitap', 'Fotoğrafçılık', 'Dans',
      'Yoga', 'Dağcılık', 'Yüzme', 'Bisiklet', 'Oyun',
      'Meditasyon', 'Kahve', 'Tasarım', 'Mimari', 'Moda',
    ];
    return BaseResponse.success(data: interests);
  }
}
