import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.time,
    required super.type,
    super.status = TransactionStatus.completed,
    super.paymentProvider,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final parsedType = _parseType(json['type']);
    final defaultProvider = parsedType == TransactionType.income ? 'Saldo Parko' : 'Mercado Pago';

    return TransactionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      type: parsedType,
      status: _parseStatus(json['status']),
      paymentProvider: _parseProvider(json['paymentProvider'] ?? json['payment_provider']) ?? defaultProvider,
    );
  }

  static String? _parseProvider(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty) return null;
    return _formatProviderName(str);
  }

  static String _formatProviderName(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'cash' || lower == 'efectivo') return 'Efectivo';
    if (lower == 'mercado_pago' || lower == 'mercadopago' || lower == 'mp' || lower == 'mercado pago') {
      return 'Mercado Pago';
    }
    if (lower == 'internal_balance' ||
        lower == 'internalbalance' ||
        lower == 'saldo_parko' ||
        lower == 'saldoparko' ||
        lower == 'parko_balance' ||
        lower == 'balance' ||
        lower == 'saldo parko' ||
        lower == 'saldo de parko') {
      return 'Saldo Parko';
    }
    if (raw.isNotEmpty) {
      return raw[0].toUpperCase() + raw.substring(1);
    }
    return raw;
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

  static TransactionStatus _parseStatus(String? status) {
    switch (status) {
      case 'pendiente':
        return TransactionStatus.pending;
      case 'fallido':
        return TransactionStatus.failed;
      case 'completado':
      default:
        return TransactionStatus.completed;
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
      'status': _statusToString(status),
      'paymentProvider': paymentProvider,
    };
  }

  static String _statusToString(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'pendiente';
      case TransactionStatus.failed:
        return 'fallido';
      case TransactionStatus.completed:
        return 'completado';
    }
  }
}
