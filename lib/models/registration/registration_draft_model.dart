class RegistrationDraftModel {
  final String fullName;
  final int? birthYear;
  final String jobTitle;
  final String company;
  final String industry;
  final String bio;
  final List<String> selectedInterests;
  final bool linkedInImported;

  const RegistrationDraftModel({
    required this.fullName,
    this.birthYear,
    required this.jobTitle,
    required this.company,
    required this.industry,
    required this.bio,
    required this.selectedInterests,
    required this.linkedInImported,
  });

  static const empty = RegistrationDraftModel(
    fullName: '',
    birthYear: null,
    jobTitle: '',
    company: '',
    industry: '',
    bio: '',
    selectedInterests: [],
    linkedInImported: false,
  );

  RegistrationDraftModel copyWith({
    String? fullName,
    int? birthYear,
    String? jobTitle,
    String? company,
    String? industry,
    String? bio,
    List<String>? selectedInterests,
    bool? linkedInImported,
  }) {
    return RegistrationDraftModel(
      fullName: fullName ?? this.fullName,
      birthYear: birthYear ?? this.birthYear,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      industry: industry ?? this.industry,
      bio: bio ?? this.bio,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      linkedInImported: linkedInImported ?? this.linkedInImported,
    );
  }
}
