import '../../models/common/base_response.dart';
import '../../models/onboarding/onboarding_slide_model.dart';

abstract class IOnboardingService {
  Future<BaseResponse<List<OnboardingSlideModel>>> getSlides();
}
