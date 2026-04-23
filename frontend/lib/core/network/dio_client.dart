import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../constants/app_constants.dart";
import "../../features/auth/presentation/providers/auth_providers.dart";
import "../../features/auth/presentation/providers/token_storage_service.dart";
import "api_exception.dart";

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      headers: {"Content-Type": "application/json"},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(tokenStorageProvider).readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401 &&
            !err.requestOptions.path.contains("/api/auth/Login") &&
            !err.requestOptions.path.contains("/api/auth/signup") &&
            !err.requestOptions.path.contains("/api/auth/refresh")) {
          final refreshed =
              await ref.read(authControllerProvider.notifier).tryRefreshToken();
          if (refreshed) {
            final retryReq = err.requestOptions;
            final newToken = await ref.read(tokenStorageProvider).readAccessToken();
            retryReq.headers["Authorization"] = "Bearer $newToken";
            final response = await dio.fetch(retryReq);
            return handler.resolve(response);
          }
          await ref.read(authControllerProvider.notifier).logout();
        }
        handler.next(err);
      },
    ),
  );

  return dio;
});

ApiException mapDioError(DioException e) {
  final statusCode = e.response?.statusCode;
  if (statusCode == 400) {
    return const ApiException("Please check your input and try again.");
  }
  if (statusCode == 401) {
    return const ApiException("Session expired. Please login again.");
  }
  if (statusCode == 429) {
    return const ApiException("Too many requests. Please wait and retry.");
  }
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout) {
    return const ApiException("Network error. Check connection and retry.");
  }
  return const ApiException("Something went wrong. Please try again.");
}

