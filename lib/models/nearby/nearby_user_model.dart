class NearbyUserModel {
  final String id;
  final String name;
  final int age;
  final String? photoUrl;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final bool isMe;
  final String? occupation;

  const NearbyUserModel({
    required this.id,
    required this.name,
    required this.age,
    this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.isMe = false,
    this.occupation,
  });

  String get nameAndAge => '$name, $age';
  String get distanceLabel =>
      distanceKm < 1 ? '${(distanceKm * 1000).round()} m' : '${distanceKm.toStringAsFixed(1)} km';
}
