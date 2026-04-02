class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String creatorName;
  final String? creatorPhoto;
  final String? imageUrl;
  final int attendeeCount;
  final String category; // Coffee, Seminar, Workshop, etc.
  final List<String> attendeePhotos;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.creatorName,
    this.creatorPhoto,
    this.imageUrl,
    required this.attendeeCount,
    required this.category,
    this.attendeePhotos = const [],
  });
}
