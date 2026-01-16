
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  //static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);


  // ============ User Endpoints ============
  static const String users = '/auth';
  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static String userById(String id) => '/auth/$id';
  static String userPhoto(String id) => '/auth/$id/photo';
}
