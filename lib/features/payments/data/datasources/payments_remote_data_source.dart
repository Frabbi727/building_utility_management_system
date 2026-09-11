import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/payment_model.dart';
import '../models/payment_submission_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<PaymentModel>> getPayments({
    required int flatId,
    int page = 1,
  });

  Future<String> getReceipt(int paymentId);

  Future<List<PaymentSubmissionModel>> getSubmissions({
    required int flatId,
    String? status,
    int page = 1,
  });

  Future<PaymentSubmissionModel> submitPayment({
    required int flatId,
    required String amount,
    required String method,
    required String referenceNumber,
    required String paymentDate,
    String? notes,
    String? slipFilePath,
  });
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final Dio dio;

  const PaymentsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PaymentModel>> getPayments({
    required int flatId,
    int page = 1,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.residentPayments,
      queryParameters: {
        'flat_id': flatId,
        'page': page,
      },
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
        .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<String> getReceipt(int paymentId) async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.residentPaymentReceipt(paymentId),
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Received empty response from server');
    }

    final data = body['data'];
    if (data is Map<dynamic, dynamic> && data['receipt_url'] != null) {
      return data['receipt_url'].toString();
    }

    throw const ServerException('Receipt URL not found');
  }

  @override
  Future<List<PaymentSubmissionModel>> getSubmissions({
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
      ApiEndpoints.residentPaymentSubmissions,
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
        .map((e) => PaymentSubmissionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<PaymentSubmissionModel> submitPayment({
    required int flatId,
    required String amount,
    required String method,
    required String referenceNumber,
    required String paymentDate,
    String? notes,
    String? slipFilePath,
  }) async {
    final map = <String, dynamic>{
      'flat_id': flatId,
      'amount': amount,
      'payment_method': method,
      'reference_number': referenceNumber,
      'payment_date': paymentDate,
    };

    if (notes != null && notes.isNotEmpty) {
      map['resident_notes'] = notes;
    }

    if (slipFilePath != null && slipFilePath.isNotEmpty) {
      map['slip'] = await MultipartFile.fromFile(slipFilePath);
    }

    final formData = FormData.fromMap(map);

    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.residentPaymentSubmissions,
      data: formData,
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Received empty response from server');
    }

    final data = body['data'];
    if (data is Map<dynamic, dynamic>) {
      return PaymentSubmissionModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ServerException('Failed to submit payment proof');
  }
}
