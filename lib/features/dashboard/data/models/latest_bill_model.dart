import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/latest_bill_entity.dart';

part 'latest_bill_model.g.dart';

@JsonSerializable()
class LatestBillModel extends Equatable {
  @JsonKey(fromJson: _idFromJson)
  final int id;

  @JsonKey(name: 'bill_no')
  final String billNo;

  @JsonKey(name: 'billing_month')
  final String billingMonth;

  @JsonKey(name: 'total_amount', fromJson: _stringFromDynamic)
  final String totalAmount;

  @JsonKey(name: 'due_date')
  final String dueDate;

  final String status;

  static int _idFromJson(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _stringFromDynamic(Object? value) =>
      value?.toString() ?? '0.00';

  const LatestBillModel({
    required this.id,
    required this.billNo,
    required this.billingMonth,
    required this.totalAmount,
    required this.dueDate,
    required this.status,
  });

  factory LatestBillModel.fromJson(Map<String, dynamic> json) =>
      _$LatestBillModelFromJson(json);

  Map<String, dynamic> toJson() => _$LatestBillModelToJson(this);

  LatestBillEntity toEntity() => LatestBillEntity(
        id: id,
        billNo: billNo,
        billingMonth: billingMonth,
        totalAmount: totalAmount,
        dueDate: dueDate,
        status: status,
      );

  @override
  List<Object?> get props => [
        id,
        billNo,
        billingMonth,
        totalAmount,
        dueDate,
        status,
      ];
}
