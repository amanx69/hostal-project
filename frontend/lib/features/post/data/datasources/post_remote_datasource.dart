import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../models/post_model.dart';
import '../models/profile_model.dart';

class PostRemoteDataSource {
  final Dio _dio;

  PostRemoteDataSource(this._dio);

  // ─── Feed ─────────────────────────────────────────────────────────────────

  Future<List<Post>> fetchPosts() async {
    final res = await _dio.get('/api/posts/posts/');
    dynamic data = res.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    List<dynamic> results;
    if (data is Map && data.containsKey('posts')) {
      results = data['posts'] as List<dynamic>;
    } else if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else if (data is List) {
      results = data;
    } else {
      results = [];
    }
    return results
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Create post (multipart) ──────────────────────────────────────────────

  Future<Post> createPost({
    String? title,
    String? description,
    MultipartFile? media,
  }) async {
    final formData = FormData.fromMap({
      if (title != null && title.isNotEmpty) 'title': title,
      if (description != null && description.isNotEmpty) 'dec': description,
      if (media != null) 'media': media,
    });
    final res = await _dio.post(
      '/api/posts/posts/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data as Map<String, dynamic>;
    if (data.containsKey('post')) {
      return Post.fromJson(data['post'] as Map<String, dynamic>);
    }
    return Post.fromJson(data);
  }

  // ─── Delete post ──────────────────────────────────────────────────────────

  Future<void> deletePost(int postId) async {
    await _dio.delete('/api/posts/posts/$postId/');
  }

  // ─── Like / unlike toggle ─────────────────────────────────────────────────

  Future<void> toggleLike(int postId) async {
    await _dio.post('/api/posts/like/$postId/');
  }

  // ─── Comments ─────────────────────────────────────────────────────────────

  Future<List<Comment>> fetchComments(int postId) async {
    final res = await _dio.get('/api/posts/comments/$postId/');
    final list = res.data as List<dynamic>? ?? [];
    return list.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Comment> addComment(int postId, String text) async {
    final res = await _dio.post(
      '/api/posts/comments/$postId/',
      data: {'text': text},
    );
    return Comment.fromJson(res.data as Map<String, dynamic>);
  }

  // ─── Follow / unfollow ────────────────────────────────────────────────────

  Future<void> followUser(int userId) async {
    await _dio.post('/api/posts/follow/$userId/');
  }

  Future<void> unfollowUser(int userId) async {
    await _dio.delete('/api/posts/follow/$userId/unfollow/');
  }

  // ─── Profile ──────────────────────────────────────────────────────────────

  Future<UserProfile> fetchMyProfile() async {
    final res = await _dio.get('/api/Profile/profile/');
    print(res.data);
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserProfile> fetchUserProfile(int userId) async {
    final res = await _dio.get('/api/Profile/profile/$userId/');
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  }
}
