// Data model matching backend PostSerializer response

class PostUser {
  final int id;
  final String username;
  final String? profilePicture;

  const PostUser({
    required this.id,
    required this.username,
    this.profilePicture,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'] as int,
      username: json['username'] as String? ?? 'Unknown',
      profilePicture: json['profile_picture'] as String?,
    );
  }
}

class Comment {
  final int id;
  final String text;
  final String createdAt;
  final String userEmail;

  const Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userEmail,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      text: json['text'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      userEmail: json['user_email'] as String? ?? '',
    );
  }
}

class Post {
  final int id;
  final String? title;
  final String? description;
  final String? media;
  final String createdAt;
  final String updatedAt;
  final PostUser? postUser;
  final int authorUserId;
  final List<Comment> comments;
  final int likesCount;
  final int commentsCount;
  final bool likedByMe;
  final bool isFollowingAuthor;

  const Post({
    required this.id,
    this.title,
    this.description,
    this.media,
    required this.createdAt,
    required this.updatedAt,
    this.postUser,
    required this.authorUserId,
    required this.comments,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByMe,
    required this.isFollowingAuthor,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['dec'] as String?,
      media: json['media'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      postUser: json['post_user'] != null
          ? PostUser.fromJson(json['post_user'] as Map<String, dynamic>)
          : null,
      authorUserId: json['author_user_id'] as int? ?? 0,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      isFollowingAuthor: json['is_following_author'] as bool? ?? false,
    );
  }

  Post copyWith({
    int? likesCount,
    bool? likedByMe,
    bool? isFollowingAuthor,
    List<Comment>? comments,
    int? commentsCount,
  }) {
    return Post(
      id: id,
      title: title,
      description: description,
      media: media,
      createdAt: createdAt,
      updatedAt: updatedAt,
      postUser: postUser,
      authorUserId: authorUserId,
      comments: comments ?? this.comments,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedByMe: likedByMe ?? this.likedByMe,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
    );
  }
}
