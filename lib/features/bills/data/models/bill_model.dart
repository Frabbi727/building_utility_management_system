import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bill_entity.dart';
import 'bill_item_model.dart';

part 'bill_model.g.dart';

@JsonSerializable()
class BillModel {
  final int id;
  @JsonKey(name: 'bill_no')
  final String billNo;
  @JsonKey(name: 'billing_month')
  final String billingMonth;
  @JsonKey(name: 'total_amount')
  final dynamic totalAmount;
  @JsonKey(name: 'month_charges')
  final dynamic monthCharges;
  final dynamic arrears;
  @JsonKey(name: 'due_date')
  final String dueDate;
  final String status;
  final List<BillItemModel>? items;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const BillModel({
    required this.id,
    required this.billNo,
    required this.billingMonth,
    required this.totalAmount,
    this.monthCharges,
    this.arrears,
    required this.dueDate,
    required this.status,
    this.items,
    required this.createdAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) =>
      _$BillModelFromJson(json);

  Map<String, dynamic> toJson() => _$BillModelToJson(this);

  BillEntity toEntity() => BillEntity(
        id: id,
        billNo: billNo,
        billingMonth: billingMonth,
        totalAmount: totalAmount?.toString() ?? '0.00',
        monthCharges: monthCharges?.toString(),
        arrears: arrears?.toString(),
        dueDate: dueDate,
        status: BillStatus.fromString(status),
        items: items?.map((i) => i.toEntity()).toList() ?? const [],
        createdAt: createdAt,
      );
}
