import 'post_model.dart';

class UserProfile {
  final int id;
  final int userId;
  final String username;
  final String email;
  final String? profilePicture;
  final String? bio;
  final String? location;
  final String? phoneNumber;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final List<Post> posts;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    this.profilePicture,
    this.bio,
    this.location,
    this.phoneNumber,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.posts,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profileData = json['profile'] as Map<String, dynamic>? ?? {};
    final statsData = json['stats'] as Map<String, dynamic>? ?? {};
    final postsData = json['posts'] as List<dynamic>? ?? [];

    return UserProfile(
      id: profileData['id'] as int? ?? 0,
      userId: profileData['user_id'] as int? ?? 0,
      username: profileData['username'] as String? ?? 'Unknown',
      email: profileData['email'] as String? ?? '',
      profilePicture: profileData['profile_picture'] as String?,
      bio: profileData['bio'] as String?,
      location: profileData['location'] as String?,
      phoneNumber: profileData['phone_number'] as String?,
      followersCount: statsData['followers_count'] as int? ?? 0,
      followingCount: statsData['following_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      posts: postsData
          .map((p) => Post.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  UserProfile copyWith({bool? isFollowing, int? followersCount, int? followingCount}) {
    return UserProfile(
      id: id,
      userId: userId,
      username: username,
      email: email,
      profilePicture: profilePicture,
      bio: bio,
      location: location,
      phoneNumber: phoneNumber,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      posts: posts,
    );
  }
}
