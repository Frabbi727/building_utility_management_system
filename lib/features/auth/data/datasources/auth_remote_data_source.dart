import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  const AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> login({required String email, required String password}) async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: <String, dynamic>{'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data!);
  }
}
