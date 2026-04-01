class ExpertiseItem {
  final String slug;
  final String title;

  const ExpertiseItem({required this.slug, required this.title});

  String get iconUrl => 'https://thesvg.org/icons/$slug/default.svg';

  factory ExpertiseItem.fromJson(Map<String, dynamic> json) => ExpertiseItem(
        slug: json['slug'] as String,
        title: json['title'] as String,
      );

  Map<String, dynamic> toJson() => {'slug': slug, 'title': title};

  @override
  bool operator ==(Object other) =>
      other is ExpertiseItem && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;
}
