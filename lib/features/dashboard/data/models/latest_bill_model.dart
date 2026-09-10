import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/latest_bill_entity.dart';

part 'latest_bill_model.g.dart';

@JsonSerializable()
class LatestBillModel extends Equatable {
  final int id;

  @JsonKey(name: 'bill_no')
  final String billNo;

  @JsonKey(name: 'billing_month')
  final String billingMonth;

  @JsonKey(name: 'total_amount')
  final String totalAmount;

  @JsonKey(name: 'due_date')
  final String dueDate;

  final String status;

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
