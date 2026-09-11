import 'package:equatable/equatable.dart';

class BillItemEntity extends Equatable {
  final int id;
  final String description;
  final String amount;
  final String? quantity;
  final String? unitRate;
  final String? unitLabel;

  const BillItemEntity({
    required this.id,
    required this.description,
    required this.amount,
    this.quantity,
    this.unitRate,
    this.unitLabel,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        quantity,
        unitRate,
        unitLabel,
      ];
}
