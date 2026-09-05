import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? legajo;
  final double? balance;
  final bool notificationsEnabled;
  final String? rol;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.rol,
    this.legajo,
    this.balance = 0.0,
    this.notificationsEnabled = true,
  });

  @override
  List<Object?> get props => [id, name, email, legajo, balance, notificationsEnabled, rol];
}
