import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/post_remote_datasource.dart';
import '../../data/models/post_model.dart';
import '../../data/models/profile_model.dart';

// ─── DataSource Provider ──────────────────────────────────────────────────────

final postDataSourceProvider = Provider<PostRemoteDataSource>(
  (ref) => PostRemoteDataSource(ref.watch(dioProvider)),
);

// ─── Feed State ───────────────────────────────────────────────────────────────

class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isCreating;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.error,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isCreating,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── Feed Notifier ────────────────────────────────────────────────────────────

class FeedNotifier extends StateNotifier<FeedState> {
  final PostRemoteDataSource _ds;

  FeedNotifier(this._ds) : super(const FeedState()) {
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await _ds.fetchPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
  }

  Future<bool> createPost({
    String? title,
    String? description,
    File? mediaFile,
  }) async {
    state = state.copyWith(isCreating: true, clearError: true);
    try {
      MultipartFile? media;
      if (mediaFile != null) {
        media = await MultipartFile.fromFile(mediaFile.path);
      }
      final newPost = await _ds.createPost(
        title: title,
        description: description,
        media: media,
      );
      state = state.copyWith(
        posts: [newPost, ...state.posts],
        isCreating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> toggleLike(int postId) async {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = state.posts[idx];
    final wasLiked = post.likedByMe;
    // Optimistic update
    final updated = post.copyWith(
      likedByMe: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    final newList = List<Post>.from(state.posts)..[idx] = updated;
    state = state.copyWith(posts: newList);
    try {
      await _ds.toggleLike(postId);
    } catch (_) {
      // Revert on error
      final revert = List<Post>.from(state.posts)..[idx] = post;
      state = state.copyWith(posts: revert);
    }
  }

  Future<void> addComment(int postId, String text) async {
    final comment = await _ds.addComment(postId, text);
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = state.posts[idx];
    final newComments = [comment, ...post.comments];
    final updated = post.copyWith(
      comments: newComments,
      commentsCount: newComments.length,
    );
    final newList = List<Post>.from(state.posts)..[idx] = updated;
    state = state.copyWith(posts: newList);
  }

  Future<void> deletePost(int postId) async {
    try {
      await _ds.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
    }
  }

  String _parseError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) return data.values.first.toString();
      return e.message ?? 'Something went wrong';
    }
    return e.toString();
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(ref.watch(postDataSourceProvider)),
);

// ─── Profile State ────────────────────────────────────────────────────────────

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── My Profile Notifier ──────────────────────────────────────────────────────

class MyProfileNotifier extends StateNotifier<ProfileState> {
  final PostRemoteDataSource _ds;

  // Start with isLoading:true so the screen shows skeleton immediately
  MyProfileNotifier(this._ds)
      : super(const ProfileState(isLoading: true)) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _ds.fetchMyProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final myProfileProvider =
    StateNotifierProvider<MyProfileNotifier, ProfileState>(
  (ref) => MyProfileNotifier(ref.watch(postDataSourceProvider)),
);

// ─── Other User Profile ───────────────────────────────────────────────────────

class UserProfileNotifier extends StateNotifier<ProfileState> {
  final PostRemoteDataSource _ds;
  final int _userId;

  // Start with isLoading:true so the skeleton renders immediately
  UserProfileNotifier(this._ds, this._userId)
      : super(const ProfileState(isLoading: true)) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _ds.fetchUserProfile(_userId);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleFollow() async {
    final p = state.profile;
    if (p == null) return;
    try {
      if (p.isFollowing) {
        await _ds.unfollowUser(_userId);
        state = state.copyWith(
          profile: p.copyWith(
            isFollowing: false,
            followersCount: p.followersCount - 1,
          ),
        );
      } else {
        await _ds.followUser(_userId);
        state = state.copyWith(
          profile: p.copyWith(
            isFollowing: true,
            followersCount: p.followersCount + 1,
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final userProfileProvider = StateNotifierProvider.family<UserProfileNotifier,
    ProfileState, int>(
  (ref, userId) =>
      UserProfileNotifier(ref.watch(postDataSourceProvider), userId),
);
