import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.time,
    required super.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      type: _parseType(json['type']),
    );
  }

  static TransactionType _parseType(String? type) {
    switch (type) {
      case 'carga':
        return TransactionType.charge;
      case 'ingreso':
        return TransactionType.income;
      default:
        return TransactionType.expense;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'time': time,
      'type': type.name,
    };
  }
}
