class ModelPost {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String authorId;
  final String displayName;
  final int likeCount;
  final bool isLiked;

  ModelPost({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.authorId,
    required this.displayName,
    required this.likeCount,
    required this.isLiked,
  });

  factory ModelPost.fromJson(Map<String, dynamic> json) {
    return ModelPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'] ?? '',
      authorId: json['author_id'],
      displayName: json['display_name'] ?? 'Unknown',
      likeCount: json['like_count'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }
}
