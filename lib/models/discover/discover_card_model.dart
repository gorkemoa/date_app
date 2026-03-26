class DiscoverCardModel {
  final String id;
  final String name;
  final int age;
  final String? bio;
  final String? occupation;
  final String? location;
  final List<String> photoUrls;
  final List<String> interests;
  final bool isVerified;
  final double? distance;
  final double? compatibilityScore;

  const DiscoverCardModel({
    required this.id,
    required this.name,
    required this.age,
    this.bio,
    this.occupation,
    this.location,
    this.photoUrls = const [],
    this.interests = const [],
    this.isVerified = false,
    this.distance,
    this.compatibilityScore,
  });

  String? get primaryPhoto => photoUrls.isNotEmpty ? photoUrls.first : null;
  String get nameAndAge => '$name, $age';
}
