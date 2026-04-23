class AppConstants {
  static const apiBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://10.45.42.172:8000",
  );

  static const connectTimeoutMs = 20000;
  static const receiveTimeoutMs = 20000;
}

