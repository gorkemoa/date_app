class UserModel {
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

  const UserModel({
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
  });

  bool get hasPhotos => photoUrls.isNotEmpty;
  String? get primaryPhoto => photoUrls.isNotEmpty ? photoUrls.first : null;

  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    String? bio,
    String? occupation,
    String? location,
    List<String>? photoUrls,
    List<String>? interests,
    bool? isVerified,
    double? distance,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      photoUrls: photoUrls ?? this.photoUrls,
      interests: interests ?? this.interests,
      isVerified: isVerified ?? this.isVerified,
      distance: distance ?? this.distance,
    );
  }
}
