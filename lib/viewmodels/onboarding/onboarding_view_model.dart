import '../../core/enums/app_enums.dart';
import '../base/base_view_model.dart';

class OnboardingViewModel extends BaseViewModel {
  OnboardingStep _currentStep = OnboardingStep.gender;
  int _currentPageIndex = 0;

  OnboardingStep get currentStep => _currentStep;
  int get currentPageIndex => _currentPageIndex;
  bool get isLastStep => _currentStep == OnboardingStep.done;

  void nextStep() {
    final steps = OnboardingStep.values;
    final currentIdx = steps.indexOf(_currentStep);
    if (currentIdx < steps.length - 1) {
      _currentStep = steps[currentIdx + 1];
      _currentPageIndex++;
      notifyListeners();
    }
  }

  void previousStep() {
    final steps = OnboardingStep.values;
    final currentIdx = steps.indexOf(_currentStep);
    if (currentIdx > 0) {
      _currentStep = steps[currentIdx - 1];
      _currentPageIndex--;
      notifyListeners();
    }
  }
}
