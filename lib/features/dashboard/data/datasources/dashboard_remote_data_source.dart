import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/models/flat_model.dart';
import '../models/dashboard_data_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData({required int flatId});
  Future<List<FlatModel>> getResidentFlats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  const DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardDataModel> getDashboardData({required int flatId}) async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.residentDashboard,
      queryParameters: {'flat_id': flatId},
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Received empty response from server');
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return DashboardDataModel.fromJson(data);
    }
    return DashboardDataModel.fromJson(body);
  }

  @override
  Future<List<FlatModel>> getResidentFlats() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.residentFlats,
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Received empty response from server');
    }

    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => FlatModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }
}
