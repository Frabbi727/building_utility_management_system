import 'package:building_utility_management_system/core/constants/api_endpoints.dart';
import 'package:building_utility_management_system/core/error/exceptions.dart';
import 'package:building_utility_management_system/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:building_utility_management_system/features/auth/data/models/auth_response_model.dart';
import 'package:building_utility_management_system/features/auth/data/models/user_model.dart';
import 'package:building_utility_management_system/shared/data/models/flat_model.dart';
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

  final envelopeResponseData = <String, dynamic>{
    'success': true,
    'data': <String, dynamic>{
      'token': 'sanctum_token_123',
      'user': <String, dynamic>{
        'id': 'user-1',
        'name': 'Test User',
        'email': email,
      },
      'flats': [
        <String, dynamic>{
          'id': 1,
          'number': 'A-101',
          'floor': '1st',
          'building_id': 10,
          'building_name': 'Tower A',
        },
      ],
    },
  };

  test('login sends login key and parses nested data map from envelope', () async {
    when(
      () => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: any<dynamic>(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        statusCode: 200,
        data: envelopeResponseData,
      ),
    );

    final result = await dataSource.login(email: email, password: password);

    expect(
      result,
      equals(
        const AuthResponseModel(
          token: 'sanctum_token_123',
          user: UserModel(id: 'user-1', name: 'Test User', email: email),
          flats: [
            FlatModel(
              id: 1,
              number: 'A-101',
              floor: '1st',
              buildingId: 10,
              buildingName: 'Tower A',
            ),
          ],
        ),
      ),
    );

    verify(
      () => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: <String, dynamic>{'login': email, 'password': password},
      ),
    ).called(1);
  });

  test('login parses direct body when data key is not a map', () async {
    final rawResponse = <String, dynamic>{
      'token': 'raw_token_xyz',
      'user': <String, dynamic>{
        'id': 'user-2',
        'name': 'Raw User',
        'email': email,
      },
      'flats': <dynamic>[],
    };

    when(
      () => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: any<dynamic>(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        statusCode: 200,
        data: rawResponse,
      ),
    );

    final result = await dataSource.login(email: email, password: password);

    expect(result.token, equals('raw_token_xyz'));
    expect(result.user.name, equals('Raw User'));
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
