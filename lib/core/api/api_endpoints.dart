import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // static const String _apiBaseUrlOverride = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: '',
  // );

  // Base URL - change this for production
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const bool isPhysicalDevice = true;
  static const String compIpAddress = "10.247.30.231";
  static String get baseUrl {
    if (isPhysicalDevice) {
      return "http://$compIpAddress:3000/api";
    }
    if (kIsWeb) {
      return "http://localhost:3000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:3000/api";
    } else if (Platform.isIOS) {
      return "http://localhost:3000/api";
    } else {
      return "http://localhost:3000/api";
    }
  }

  static String get mediaServerUrl {
    final uri = Uri.parse(baseUrl);
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }

  // static String get baseUrl {
  //   if (_apiBaseUrlOverride.trim().isNotEmpty) {
  //     return _apiBaseUrlOverride.trim();
  //   }

  //   if (kIsWeb) return 'http://localhost:3000/api';

  //   if (Platform.isAndroid) {
  //     // Android emulator host mapping.
  //     // For physical devices, provide --dart-define=API_BASE_URL=http://<YOUR_PC_IP>:3000/api
  //     // or use adb reverse and API_BASE_URL=http://127.0.0.1:3000/api.
  //     return 'http://10.0.2.2:3000/api';
  //   }

  //   if (Platform.isIOS) {
  //     return 'http://localhost:3000/api';
  //   }

  //   return 'http://localhost:3000/api';
  // }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ User Endpoints ============
  static const String users = '/auth';
  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static String getCurrentUser = '/auth/whoami';
  static String userById(String id) => '/auth/$id';
  static String userPhoto(String id) => '/auth/$id/photo';
  static String updateProfile = "/auth/update-profile";
  static const String googleLogin = "/auth/google-login";
  static const String requestPasswordReset = "/auth/request-password-reset";
  static const String resetPassword = "/auth/reset-password";
  static const String changePassword = "/auth/change-password";

  static const String restaurants = '/restaurant';

  static const String getMenuByRestaurantId = "/menu/restaurant/";

  static const String addFavourites = "/favourite";
  static const String getFavourites = "/favourite/my";
  static const String removeFavourites = "/favourite";

  static const String getRestaurantReviews = "/review/restaurant";
  static const String createReview = "/review/create";
  static const String deleteReview = "/review/delete";
  static const String updateReview = "/review/update";
  static const String getOwnerReviews = "/review/owner/my-reviews";
}
