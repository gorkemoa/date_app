import '../../models/common/base_response.dart';
import '../../models/onboarding/onboarding_slide_model.dart';
import '../interfaces/i_onboarding_service.dart';

class DemoOnboardingService implements IOnboardingService {
  @override
  Future<BaseResponse<List<OnboardingSlideModel>>> getSlides() async {
    await Future.delayed(const Duration(milliseconds: 150));

    return BaseResponse.success(
      data: const [
        OnboardingSlideModel(
          title: 'Network Kur,\nFırsatları Yakala',
          description:
              'Çevrende kim olduğu her şeyi değiştirir.\nYüz yüze bağlantılar, kalıcı fırsatlar getirir.',
          videoPath: 'assets/4318550-hd_1080_1920_30fps.mp4',
        ),
        OnboardingSlideModel(
          title: 'Bir Arada\nBüyü',
          description:
              'Sektörünün öncüleriyle aynı masada ol.\nOrtak fikirler, büyük projelere dönüşür.',
          videoPath: 'assets/6912098-hd_1080_1920_25fps.mp4',
        ),
        OnboardingSlideModel(
          title: 'Başarı,\nDoğru Kişiyle Başlar',
          description:
              'Her kariyer dönüm noktasının arkasında\nbir tanışma vardır. Seninki burada.',
          videoPath: 'assets/9047514-uhd_2160_3840_24fps.mp4',
        ),
      ],
    );
  }
}
