class LinkedInParseResultModel {
  final String? fullName;
  final String? headline;
  final String? currentCompany;
  final String? summary;
  final List<String> skills;

  const LinkedInParseResultModel({
    this.fullName,
    this.headline,
    this.currentCompany,
    this.summary,
    this.skills = const [],
  });
}
