import 'dart:io';
import 'package:dio/dio.dart';
import 'lib/features/post/data/models/post_model.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'));
  try {
    final formData = FormData.fromMap({
      'title': 'Test post from script',
      'dec': 'Hello world',
    });
    // This will fail because we are not authenticated, but we want to see the error format.
    // Actually, we can use the login api to get a token!
    print("Testing create...");
  } catch (e) {
    print("Network error: \$e");
  }
}
