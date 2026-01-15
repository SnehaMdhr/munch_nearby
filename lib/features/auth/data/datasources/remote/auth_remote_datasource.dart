import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/api/api_client.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/features/auth/data/datasources/auth_datasource.dart';
import 'package:munch_nearby/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider), 
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource{

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }): _apiClient = apiClient,
      _userSessionService = userSessionService;
      
        @override
        Future<bool> isEmailExists(String email) {
          // TODO: implement isEmailExists
          throw UnimplementedError();
        }
      
        @override
        Future<AuthApiModel?> login(String email, String password) async {
          final response = await _apiClient.post(
              ApiEndpoints.userLogin,
              data: {"email": email, "password": password},
            );

            if(response.data["success"]== true){
              final data = response.data["data"] as Map<String, dynamic>;
              final user = AuthApiModel.fromJson(data);

              //save the session
              if (user.id != null) {
                await _userSessionService.saveUserSession(
                    userId: user.id!,
                    email: user.email,
                    name: user.name,
                    username: user.username,
                    role: user.role,
                );
              } else {
                // Handle the case where user.id is null
              }
              return user;
            }
            return null;
        }
        
          @override
          Future<AuthApiModel?> register(AuthApiModel model) async {
            final response = await _apiClient.post(
              ApiEndpoints.userRegister,
              data: model.toJson(),
            );
            if(response.data["success"]==true){
              final data = response.data["data"] as Map<String, dynamic>;
              final registeredUser = AuthApiModel.fromJson(data);
              return registeredUser;
            }
            return model;
          }
        
          
}