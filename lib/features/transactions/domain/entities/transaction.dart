import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, charge }

enum TransactionStatus { completed, pending, failed }

class Transaction extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String date;
  final String time;
  final TransactionType type;
  final TransactionStatus status;
  final String? paymentProvider;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.time,
    required this.type,
    this.status = TransactionStatus.completed,
    this.paymentProvider,
  });

  bool get isPending => status == TransactionStatus.pending;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isCompleted => status == TransactionStatus.completed;

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        date,
        time,
        type,
        status,
        paymentProvider,
      ];
}
