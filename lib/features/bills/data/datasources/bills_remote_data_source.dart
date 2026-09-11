import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/bill_model.dart';

abstract class BillsRemoteDataSource {
  Future<List<BillModel>> getBills({
    required int flatId,
    String? status,
    int? year,
    int? month,
    int page = 1,
  });

  Future<BillModel> getBillDetails(int billId);
}

class BillsRemoteDataSourceImpl implements BillsRemoteDataSource {
  final Dio dio;

  const BillsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BillModel>> getBills({
    required int flatId,
    String? status,
    int? year,
    int? month,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'flat_id': flatId,
      'page': page,
    };
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status;
    }
    if (year != null) {
      queryParams['year'] = year;
    }
    if (month != null) {
      queryParams['month'] = month;
    }

    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.residentBills,
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
      rawList = const <dynamic>[];
    }

    return (rawList as List)
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => BillModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<BillModel> getBillDetails(int billId) async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.residentBillDetails(billId),
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Received empty response from server');
    }

    final data = body['data'];
    if (data is Map<dynamic, dynamic>) {
      return BillModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ServerException('Invalid bill details response');
  }
}
