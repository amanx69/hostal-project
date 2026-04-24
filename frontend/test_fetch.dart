import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'));
  try {
    final res = await dio.get('/api/posts/posts/');
    final data = res.data;
    List<dynamic> results;
    if (data is Map && data.containsKey('posts')) {
      results = data['posts'] as List<dynamic>;
      print("Found posts: \${results.length}");
    } else if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
      print("Found results: \${results.length}");
    } else {
      results = [];
    }
    print("Mapping to Post objects...");
    // Just simulating Post.fromJson logic
    for (var json in results) {
       final id = json['id'] as int;
       final title = json['title'] as String?;
       final postUser = json['post_user'] != null ? json['post_user'] as Map<String, dynamic> : null;
       print("Parsed Post \$id");
    }
    print("Success!");
  } catch (e, st) {
    print("Error: \$e");
    print(st);
  }
}
