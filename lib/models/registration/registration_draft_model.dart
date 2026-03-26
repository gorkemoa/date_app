import '../../core/enums/app_enums.dart';

class RegistrationDraftModel {
  final DateTime? birthDate;
  final UserGender? gender;
  final String bio;
  final String city;
  final String district;
  final String jobTitle;
  final String company;
  final String industry;
  final List<String> selectedInterests;
  final bool linkedInImported;
  final bool currentlyWorking;

  const RegistrationDraftModel({
    this.birthDate,
    this.gender,
    required this.bio,
    required this.city,
    required this.district,
    required this.jobTitle,
    required this.company,
    required this.industry,
    required this.selectedInterests,
    required this.linkedInImported,
    this.currentlyWorking = true,
  });

  static const empty = RegistrationDraftModel(
    birthDate: null,
    gender: null,
    bio: '',
    city: '',
    district: '',
    jobTitle: '',
    company: '',
    industry: '',
    selectedInterests: [],
    linkedInImported: false,
    currentlyWorking: true,
  );

  RegistrationDraftModel copyWith({
    DateTime? birthDate,
    UserGender? gender,
    String? bio,
    String? city,
    String? district,
    String? jobTitle,
    String? company,
    String? industry,
    List<String>? selectedInterests,
    bool? linkedInImported,
    bool? currentlyWorking,
  }) {
    return RegistrationDraftModel(
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      district: district ?? this.district,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      industry: industry ?? this.industry,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      linkedInImported: linkedInImported ?? this.linkedInImported,
      currentlyWorking: currentlyWorking ?? this.currentlyWorking,
    );
  }
}
