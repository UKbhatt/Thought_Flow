class Modelpost {
  final String id;
  final String authorId;
  final String content;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final String visibility;
  final String title;
  final String displayName;

  Modelpost({
    required this.id,
    required this.authorId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    required this.visibility,
    required this.title,
    required this.displayName,
  });

  factory Modelpost.fromJson(Map<String, dynamic> json) {
    return Modelpost(
      id: json['id'] ?? '',
      authorId: json['author_id'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      likes: json['likes'] ?? 0,
      visibility: json['visibility'] ?? 'public',
      title: json['title'] ?? '',
      displayName:
          json['display_name'] ?? "", // Ensures displayName is always a String
    );
  }
}
