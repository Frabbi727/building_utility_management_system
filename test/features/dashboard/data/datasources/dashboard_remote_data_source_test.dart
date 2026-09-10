import 'package:building_utility_management_system/core/constants/api_endpoints.dart';
import 'package:building_utility_management_system/core/error/exceptions.dart';
import 'package:building_utility_management_system/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DashboardRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = DashboardRemoteDataSourceImpl(dio: mockDio);
  });

  const flatJson = <String, dynamic>{
    'id': 1,
    'number': 'A-101',
    'floor': '1st',
    'building_id': 10,
    'building_name': 'Tower A',
  };

  const balancesJson = <String, dynamic>{
    'total_due': '5000.00',
    'advance_held': '0.00',
    'current_month_charges': '5000.00',
    'arrears': '0.00',
  };

  final dashboardEnvelope = <String, dynamic>{
    'success': true,
    'data': <String, dynamic>{
      'flat': flatJson,
      'balances': balancesJson,
      'latest_bill': null,
      'active_notices': <dynamic>[],
      'recent_activity': <dynamic>[],
    },
  };

  final flatsEnvelope = <String, dynamic>{
    'success': true,
    'data': <dynamic>[flatJson],
  };

  group('getDashboardData', () {
    test('calls Dio.get with flat_id queryParam and parses response envelope', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          ApiEndpoints.residentDashboard,
          queryParameters: {'flat_id': 1},
        ),
      ).thenAnswer(
        (_) async => Response(
          data: dashboardEnvelope,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.residentDashboard),
        ),
      );

      final result = await dataSource.getDashboardData(flatId: 1);

      expect(result.flat.id, 1);
      expect(result.balances.totalDue, '5000.00');
      verify(
        () => mockDio.get<Map<String, dynamic>>(
          ApiEndpoints.residentDashboard,
          queryParameters: {'flat_id': 1},
        ),
      ).called(1);
    });

    test('parses direct body when data key is not a map', () async {
      final directBody = <String, dynamic>{
        'flat': flatJson,
        'balances': balancesJson,
        'latest_bill': null,
        'active_notices': <dynamic>[],
        'recent_activity': <dynamic>[],
      };
      when(
        () => mockDio.get<Map<String, dynamic>>(
          ApiEndpoints.residentDashboard,
          queryParameters: {'flat_id': 1},
        ),
      ).thenAnswer(
        (_) async => Response(
          data: directBody,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.residentDashboard),
        ),
      );

      final result = await dataSource.getDashboardData(flatId: 1);

      expect(result.flat.id, 1);
    });

    test('throws ServerException when response body is null', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          ApiEndpoints.residentDashboard,
          queryParameters: {'flat_id': 1},
        ),
      ).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.residentDashboard),
        ),
      );

      expect(
        () => dataSource.getDashboardData(flatId: 1),
        throwsA(isA<ServerException>()),
      );
    });

    test('propagates DioException when network fails', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          ApiEndpoints.residentDashboard,
          queryParameters: {'flat_id': 1},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.residentDashboard),
        ),
      );

      expect(
        () => dataSource.getDashboardData(flatId: 1),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('getResidentFlats', () {
    test('calls Dio.get and parses flats list from envelope', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(ApiEndpoints.residentFlats),
      ).thenAnswer(
        (_) async => Response(
          data: flatsEnvelope,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.residentFlats),
        ),
      );

      final result = await dataSource.getResidentFlats();

      expect(result.length, 1);
      expect(result.first.id, 1);
      verify(() => mockDio.get<Map<String, dynamic>>(ApiEndpoints.residentFlats)).called(1);
    });

    test('throws ServerException when flats response body is null', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(ApiEndpoints.residentFlats),
      ).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.residentFlats),
        ),
      );

      expect(
        () => dataSource.getResidentFlats(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
