class LinkedInParseResultModel {
  final String? fullName;
  final String? headline;
  final String? currentCompany;
  final String? currentJobTitle;
  final String? summary;
  final List<String> skills;

  const LinkedInParseResultModel({
    this.fullName,
    this.headline,
    this.currentCompany,
    this.currentJobTitle,
    this.summary,
    this.skills = const [],
  });
}
