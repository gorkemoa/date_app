import 'dart:typed_data';

import '../../core/enums/app_enums.dart';
import '../../models/registration/registration_draft_model.dart';
import '../../services/interfaces/i_linkedin_parser_service.dart';
import '../base/base_view_model.dart';

class RegistrationViewModel extends BaseViewModel {
  final ILinkedInParserService _linkedInParser;

  RegistrationViewModel({required ILinkedInParserService linkedInParser})
      : _linkedInParser = linkedInParser;

  // Kullanıcıya sunulan ilgi alanları listesi
  static const List<String> availableInterests = [
    'Yazılım', 'Tasarım', 'Girişimcilik', 'Pazarlama', 'Fintech',
    'SaaS', 'AI / ML', 'Mobil Geliştirme', 'Veri Bilimi', 'DevOps',
    'Grafik Tasarım', 'İçerik Üretimi', 'Fotoğrafçılık', 'Video',
    'Sosyal Medya', 'SEO', 'PR & İletişim', 'Spor', 'Seyahat',
    'Müzik', 'Kitap', 'Kafe Kültürü', 'Yemek', 'Podcast',
  ];

  RegistrationStep _step = RegistrationStep.basicInfo;
  RegistrationDraftModel _draft = RegistrationDraftModel.empty;
  bool _linkedInLoading = false;
  bool _linkedInJustApplied = false;

  RegistrationStep get step => _step;
  RegistrationDraftModel get draft => _draft;
  bool get linkedInLoading => _linkedInLoading;
  bool get linkedInJustApplied => _linkedInJustApplied;
  int get stepIndex => RegistrationStep.values.indexOf(_step);
  int get totalSteps => RegistrationStep.values.length;

  bool get canGoNext {
    switch (_step) {
      case RegistrationStep.basicInfo:
        return _draft.fullName.trim().length >= 2 && _draft.birthYear != null;
      case RegistrationStep.professional:
        return _draft.jobTitle.trim().isNotEmpty;
      case RegistrationStep.interests:
        return _draft.selectedInterests.length >= 3;
      case RegistrationStep.complete:
        return true;
    }
  }

  void updateBasicInfo({required String fullName, required int? birthYear}) {
    _draft = _draft.copyWith(fullName: fullName, birthYear: birthYear);
    notifyListeners();
  }

  void updateProfessional({
    required String jobTitle,
    required String company,
    required String industry,
    required String bio,
    required bool currentlyWorking,
  }) {
    _draft = _draft.copyWith(
      jobTitle: jobTitle,
      company: company,
      industry: industry,
      bio: bio,
      currentlyWorking: currentlyWorking,
    );
    notifyListeners();
  }

  void toggleInterest(String interest) {
    final current = List<String>.from(_draft.selectedInterests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else if (current.length < 10) {
      current.add(interest);
    }
    _draft = _draft.copyWith(selectedInterests: current);
    notifyListeners();
  }

  void nextStep() {
    final steps = RegistrationStep.values;
    final idx = steps.indexOf(_step);
    if (idx < steps.length - 1) {
      _step = steps[idx + 1];
      notifyListeners();
    }
  }

  void previousStep() {
    final steps = RegistrationStep.values;
    final idx = steps.indexOf(_step);
    if (idx > 0) {
      _step = steps[idx - 1];
      notifyListeners();
    }
  }

  void clearLinkedInJustApplied() {
    _linkedInJustApplied = false;
  }

  Future<void> parseLinkedInPdf(Uint8List bytes, String fileName) async {
    _linkedInLoading = true;
    clearError();
    notifyListeners();

    final res = await _linkedInParser.parsePdf(bytes, fileName);
    _linkedInLoading = false;

    if (res.isSuccess && res.data != null) {
      final result = res.data!;
      final hasCurrentJob = result.currentCompany != null;
      _draft = _draft.copyWith(
        fullName: (_draft.fullName.isEmpty && result.fullName != null)
            ? result.fullName
            : _draft.fullName,
        // Deneyim kartından gelen pozisyon ünvanı (Present ise dolu, yoksa boş)
        jobTitle: result.currentJobTitle?.isNotEmpty == true
            ? result.currentJobTitle!
            : _draft.jobTitle,
        // Şu anki işveren (şenlik Present ise dolu)
        company: hasCurrentJob ? result.currentCompany! : _draft.company,
        // LinkedIn headline (profil başlığı) sektör alanına gider
        industry: result.headline?.isNotEmpty == true
            ? result.headline!
            : _draft.industry,
        bio: result.summary?.isNotEmpty == true
            ? result.summary!
            : _draft.bio,
        selectedInterests: _mergeInterests(result.skills),
        linkedInImported: true,
        currentlyWorking: hasCurrentJob,
      );
      _linkedInJustApplied = true;
      notifyListeners();
    } else {
      setError(res.error?.message ?? 'PDF okunamadı. Lütfen tekrar deneyin.');
    }
  }

  bool _readyToNavigateHome = false;
  bool get readyToNavigateHome => _readyToNavigateHome;

  void finalizeRegistration() {
    _readyToNavigateHome = true;
    notifyListeners();
  }

  void clearNavigationFlag() {
    _readyToNavigateHome = false;
  }

  List<String> _mergeInterests(List<String> newSkills) {
    final current = List<String>.from(_draft.selectedInterests);
    for (final skill in newSkills) {
      final matched = availableInterests.where(
        (i) =>
            i.toLowerCase().contains(skill.toLowerCase()) ||
            skill.toLowerCase().contains(i.toLowerCase()),
      );
      for (final m in matched) {
        if (!current.contains(m) && current.length < 10) {
          current.add(m);
        }
      }
    }
    return current;
  }
}
