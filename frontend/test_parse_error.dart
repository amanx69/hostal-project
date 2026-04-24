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
    } else if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else if (data is List) {
      results = data;
    } else {
      results = [];
    }
    
    for (var i = 0; i < results.length; i++) {
      try {
        Post.fromJson(results[i] as Map<String, dynamic>);
      } catch (e, st) {
        print("Error parsing post \$i: \$e");
        print(results[i]);
      }
    }
    print("Checked all posts.");
  } catch (e) {
    print("Network error: \$e");
  }
}
