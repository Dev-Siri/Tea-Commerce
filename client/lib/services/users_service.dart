import "dart:convert";

import "package:http/http.dart" as http;
import "package:jwt_decoder/jwt_decoder.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:tea_commerce/constants.dart";
import "package:tea_commerce/models/user_model.dart";

class UsersServiceResponse<T> {
  T? data;
  String? errorMessage;

  final bool successful;

  UsersServiceResponse({
    this.errorMessage,
    this.data,
    required this.successful,
  });
}

class UsersService {
  final Map<String, String> _headers = {
    "Content-Type": "application/json"
  };

  Future<UserModel?> get user async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String? authToken = sharedPreferences.getString("auth_token");

    if (authToken != null) {
      final Map<String, dynamic> userMap = JwtDecoder.decode(authToken);
      return UserModel.fromJson(userMap);
    }

    return null;
  }

  Future<UsersServiceResponse> signup({
    required String username,
    required String email,
    required String password,
    required bool isSeller,
  }) async {
    final http.Response response = await http.post(
      Uri.parse("$backendUrl/users/signup"),
      headers: _headers,
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "is_seller": isSeller
      }),
    );

    if (response.statusCode == 400 || response.statusCode == 500) {
      return UsersServiceResponse<void>(
        successful: false,
        errorMessage: response.body
      );      
    }

    return UsersServiceResponse<String>(
      successful: true,
      data: response.body,
    );
  }

  Future<UsersServiceResponse> login({
    required String email,
    required String password,
  }) async {
    final http.Response response = await http.post(
      Uri.parse("$backendUrl/users/login"),
      headers: _headers,
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 400 || response.statusCode == 500) {
      return UsersServiceResponse<void>(
        successful: false,
        errorMessage: response.body
      );
    }

    return UsersServiceResponse<String>(
      successful: true,
      data: response.body
    );
  }
}