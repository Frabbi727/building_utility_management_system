import 'package:equatable/equatable.dart';

class RecentActivityEntity extends Equatable {
  final int id;
  final String type;
  final String title;
  final String amount;
  final String date;
  final String status;

  const RecentActivityEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        amount,
        date,
        status,
      ];
}
