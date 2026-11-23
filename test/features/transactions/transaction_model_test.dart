import 'package:flutter_test/flutter_test.dart';
import 'package:parko_mobile_app/features/transactions/data/models/transaction_model.dart';
import 'package:parko_mobile_app/features/transactions/domain/entities/transaction.dart';

void main() {
  group('TransactionModel Tests', () {
    test('debe deserializar correctamente status "completado"', () {
      final json = {
        'id': 'tx-100',
        'title': 'Estacionamiento Central',
        'amount': 1500.0,
        'date': '21/11/2026',
        'time': '08:30 PM',
        'type': 'ingreso',
        'status': 'completado',
        'paymentProvider': 'Saldo Parko',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.id, equals('tx-100'));
      expect(model.title, equals('Estacionamiento Central'));
      expect(model.amount, equals(1500.0));
      expect(model.type, equals(TransactionType.income));
      expect(model.status, equals(TransactionStatus.completed));
      expect(model.isCompleted, isTrue);
      expect(model.isPending, isFalse);
      expect(model.isFailed, isFalse);
      expect(model.paymentProvider, equals('Saldo Parko'));
    });

    test('debe deserializar correctamente status "pendiente"', () {
      final json = {
        'id': 'tx-101',
        'title': 'Estacionamiento Campus',
        'amount': 2000.0,
        'date': '22/11/2026',
        'time': '10:15 AM',
        'type': 'ingreso',
        'status': 'pendiente',
        'paymentProvider': 'Saldo Parko',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.status, equals(TransactionStatus.pending));
      expect(model.isPending, isTrue);
      expect(model.isCompleted, isFalse);
      expect(model.isFailed, isFalse);
    });

    test('debe deserializar correctamente status "fallido"', () {
      final json = {
        'id': 'tx-102',
        'title': 'Carga de Saldo MP',
        'amount': 5000.0,
        'date': '22/11/2026',
        'time': '11:00 AM',
        'type': 'carga',
        'status': 'fallido',
        'paymentProvider': 'Mercado Pago',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.status, equals(TransactionStatus.failed));
      expect(model.isFailed, isTrue);
      expect(model.isPending, isFalse);
      expect(model.isCompleted, isFalse);
      expect(model.paymentProvider, equals('Mercado Pago'));
    });

    test('debe asumir "completado" por retrocompatibilidad si status viene nulo', () {
      final json = {
        'id': 'tx-103',
        'title': 'Estacionamiento Antiguo',
        'amount': 800.0,
        'date': '20/11/2026',
        'time': '07:00 PM',
        'type': 'ingreso',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.status, equals(TransactionStatus.completed));
      expect(model.isCompleted, isTrue);
      expect(model.paymentProvider, equals('Saldo Parko'));
    });

    test('debe inferir "Efectivo" si la carga menciona efectivo en el título o proveedor', () {
      final json = {
        'id': 'tx-105',
        'title': 'Carga de saldo en efectivo',
        'amount': 4000.0,
        'date': '24/11/2026',
        'time': '03:00 PM',
        'type': 'carga',
        'status': 'completado',
        'paymentProvider': 'efectivo',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.paymentProvider, equals('Efectivo'));
    });

    test('debe serializar correctamente a JSON', () {
      const model = TransactionModel(
        id: 'tx-104',
        title: 'Carga de Saldo',
        amount: 3000.0,
        date: '23/11/2026',
        time: '02:00 PM',
        type: TransactionType.charge,
        status: TransactionStatus.completed,
        paymentProvider: 'Mercado Pago',
      );

      final json = model.toJson();

      expect(json['id'], equals('tx-104'));
      expect(json['type'], equals('charge'));
      expect(json['status'], equals('completado'));
      expect(json['paymentProvider'], equals('Mercado Pago'));
    });
  });
}
