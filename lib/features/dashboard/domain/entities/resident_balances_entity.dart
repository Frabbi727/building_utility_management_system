import 'package:equatable/equatable.dart';

class ResidentBalancesEntity extends Equatable {
  final String totalDue;
  final String advanceHeld;
  final String currentMonthCharges;
  final String arrears;

  const ResidentBalancesEntity({
    required this.totalDue,
    required this.advanceHeld,
    required this.currentMonthCharges,
    required this.arrears,
  });

  bool get hasOutstandingDue =>
      (double.tryParse(totalDue.replaceAll(',', '')) ?? 0.0) > 0;

  @override
  List<Object?> get props => [
        totalDue,
        advanceHeld,
        currentMonthCharges,
        arrears,
      ];
}
