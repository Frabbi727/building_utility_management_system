import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_entity.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final int id;
  @JsonKey(name: 'receipt_no')
  final String receiptNo;
  final String amount;
  final String method;
  final String? reference;
  @JsonKey(name: 'received_on')
  final String receivedOn;
  @JsonKey(name: 'receipt_url')
  final String receiptUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const PaymentModel({
    required this.id,
    required this.receiptNo,
    required this.amount,
    required this.method,
    this.reference,
    required this.receivedOn,
    required this.receiptUrl,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  PaymentEntity toEntity() => PaymentEntity(
        id: id,
        receiptNo: receiptNo,
        amount: amount,
        method: method,
        reference: reference ?? '',
        receivedOn: receivedOn,
        receiptUrl: receiptUrl,
        createdAt: createdAt,
      );
}
