import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/models/comment.dart';

class Post {
  final String id;
  final User user;
  final String imageUrl;
  final String caption;
  final DateTime createdAt;
  final List<String> likes;
  final bool isLiked;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.user,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    required this.likes,
    this.isLiked = false,
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      user: User.fromJson(json['user']),
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes'].map((like) => like.toString())),
      comments: List<Comment>.from(
        json['comments']?.map((comment) => Comment.fromJson(comment)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
    };
  }

  Post copyWith({
    String? id,
    User? user,
    String? imageUrl,
    String? caption,
    DateTime? createdAt,
    List<String>? likes,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}