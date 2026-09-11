import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/maintenance_request_model.dart';

abstract class MaintenanceRemoteDataSource {
  Future<List<MaintenanceRequestModel>> getRequests({
    required int flatId,
    String? status,
    int page = 1,
  });

  Future<MaintenanceRequestModel> getRequestDetails(int id);

  Future<MaintenanceRequestModel> createRequest({
    required int flatId,
    required String title,
    required String description,
    required String category,
    required String priority,
  });
}

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  final Dio dio;

  const MaintenanceRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MaintenanceRequestModel>> getRequests({
    required int flatId,
    String? status,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'flat_id': flatId,
      'page': page,
    };
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status;
    }

    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.residentMaintenance,
      queryParameters: queryParams,
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Received empty response from server');
    }

    dynamic rawList;
    final data = body['data'];
    if (data is Map && data['data'] is List) {
      rawList = data['data'];
    } else if (data is List) {
      rawList = data;
    } else {
      rawList = const [];
    }

    return (rawList as List)
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => MaintenanceRequestModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<MaintenanceRequestModel> getRequestDetails(int id) async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.residentMaintenanceDetails(id),
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Received empty response from server');
    }

    final data = body['data'];
    if (data is Map<dynamic, dynamic>) {
      return MaintenanceRequestModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ServerException('Invalid maintenance request details structure');
  }

  @override
  Future<MaintenanceRequestModel> createRequest({
    required int flatId,
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.residentMaintenance,
      data: {
        'flat_id': flatId,
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Received empty response from server');
    }

    final data = body['data'];
    if (data is Map<dynamic, dynamic>) {
      return MaintenanceRequestModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ServerException('Failed to create maintenance request');
  }
}
