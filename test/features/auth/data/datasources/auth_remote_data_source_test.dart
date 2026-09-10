import 'package:building_utility_management_system/core/constants/api_endpoints.dart';
import 'package:building_utility_management_system/core/error/exceptions.dart';
import 'package:building_utility_management_system/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:building_utility_management_system/features/auth/data/models/auth_response_model.dart';
import 'package:building_utility_management_system/features/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio: mockDio);
  });

  const email = 'user@example.com';
  const password = 'secretPassword1';

  final responseData = <String, dynamic>{
    'accessToken': 'jwt_access_123',
    'refreshToken': 'jwt_refresh_123',
    'user': <String, dynamic>{
      'id': 'user-1',
      'name': 'Test User',
      'email': email,
    },
  };

  test('login calls Dio.post with login endpoint and returns AuthResponseModel', () async {
    when(
      () => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: any<dynamic>(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        statusCode: 200,
        data: responseData,
      ),
    );

    final result = await dataSource.login(email: email, password: password);

    expect(
      result,
      equals(
        const AuthResponseModel(
          accessToken: 'jwt_access_123',
          refreshToken: 'jwt_refresh_123',
          user: UserModel(id: 'user-1', name: 'Test User', email: email),
        ),
      ),
    );

    verify(
      () => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: <String, dynamic>{'email': email, 'password': password},
      ),
    ).called(1);
  });

  test('login propagates DioException when request fails', () async {
    final dioException = DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.login),
      response: Response(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

    when(
      () => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: any<dynamic>(named: 'data'),
      ),
    ).thenThrow(dioException);

    expect(
      () => dataSource.login(email: email, password: password),
      throwsA(isA<DioException>()),
    );
  });

  test('login throws ServerException when response data is null', () async {
    when(
      () => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: any<dynamic>(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        statusCode: 200,
        data: null,
      ),
    );

    expect(
      () => dataSource.login(email: email, password: password),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Received empty response from server',
        ),
      ),
    );
  });
}
