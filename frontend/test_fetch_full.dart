import 'dart:io';
import 'package:dio/dio.dart';
import 'lib/features/post/data/models/post_model.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'));
  try {
    final res = await dio.get('/api/posts/posts/');
    final data = res.data;
    List<dynamic> results;
    if (data is Map && data.containsKey('posts')) {
      results = data['posts'] as List<dynamic>;
      print("Found posts: \${results.length}");
    } else {
      results = [];
    }
    
    final posts = results.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    print("Successfully mapped \${posts.length} posts!");
  } catch (e, st) {
    print("Error: \$e");
    print(st);
  }
}
