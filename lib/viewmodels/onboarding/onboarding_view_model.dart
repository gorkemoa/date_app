import '../../models/onboarding/onboarding_slide_model.dart';
import '../../services/interfaces/i_onboarding_service.dart';
import '../base/base_view_model.dart';

class OnboardingViewModel extends BaseViewModel {
  final IOnboardingService _service;

  OnboardingViewModel({required IOnboardingService service})
      : _service = service;

  List<OnboardingSlideModel> _slides = [];
  int _currentIndex = 0;

  List<OnboardingSlideModel> get slides => _slides;
  int get currentIndex => _currentIndex;
  bool get isLastSlide => _slides.isNotEmpty && _currentIndex == _slides.length - 1;
  int get totalSlides => _slides.length;

  Future<void> load() async {
    setLoading();
    final response = await _service.getSlides();
    if (response.isSuccess && response.hasData) {
      _slides = response.data!;
      _slides.isEmpty ? setEmpty() : setIdle();
    } else {
      setError(response.message);
    }
  }

  void goToPage(int index) {
    if (index < 0 || index >= _slides.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  void nextPage() {
    if (isLastSlide) return;
    _currentIndex++;
    notifyListeners();
  }
}
