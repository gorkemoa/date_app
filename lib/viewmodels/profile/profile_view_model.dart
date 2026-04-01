import '../../models/profile/profile_model.dart';
import '../../services/interfaces/i_profile_service.dart';
import '../base/base_view_model.dart';
import '../../models/registration/registration_draft_model.dart';

class ProfileViewModel extends BaseViewModel {
  final IProfileService _profileService;

  ProfileViewModel({required IProfileService profileService})
      : _profileService = profileService;

  ProfileModel? _profile;
  List<String> _availableInterests = [];

  ProfileModel? get profile => _profile;
  List<String> get availableInterests => _availableInterests;

  Future<void> loadProfile({RegistrationDraftModel? regDraft}) async {
    setLoading();
    final response = await _profileService.getMyProfile();
    if (!response.isSuccess) {
      setError(response.error?.message ?? response.message);
      return;
    }

    _profile = response.data;

    // Apply registration draft overrides if available (Semi-dynamic mock)
    if (regDraft != null && _profile != null) {
      _profile = _profile!.copyWith(
        bio: regDraft.bio.isNotEmpty ? regDraft.bio : _profile!.bio,
        occupation: regDraft.occupation.isNotEmpty ? regDraft.occupation : _profile!.occupation,
        interests: regDraft.selectedInterests.isNotEmpty ? regDraft.selectedInterests : _profile!.interests,
      );
    }
    
    setIdle();
  }

  Future<void> updateProfile(ProfileModel updated) async {
    setLoading();
    final response = await _profileService.updateProfile(updated);
    if (!response.isSuccess) {
      setError(response.error?.message ?? response.message);
      return;
    }
    _profile = response.data;
    setIdle();
  }

  Future<void> loadInterests() async {
    final response = await _profileService.getInterests();
    if (response.isSuccess && response.hasData) {
      _availableInterests = response.data!;
      notifyListeners();
    }
  }
}
