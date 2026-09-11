import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bill_item_entity.dart';

part 'bill_item_model.g.dart';

@JsonSerializable()
class BillItemModel {
  final int id;
  final String description;
  final dynamic amount;
  final dynamic quantity;
  @JsonKey(name: 'unit_rate')
  final dynamic unitRate;
  @JsonKey(name: 'unit_label')
  final String? unitLabel;

  const BillItemModel({
    required this.id,
    required this.description,
    required this.amount,
    this.quantity,
    this.unitRate,
    this.unitLabel,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) =>
      _$BillItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$BillItemModelToJson(this);

  BillItemEntity toEntity() => BillItemEntity(
        id: id,
        description: description,
        amount: amount?.toString() ?? '0.00',
        quantity: quantity?.toString(),
        unitRate: unitRate?.toString(),
        unitLabel: unitLabel,
      );
}
