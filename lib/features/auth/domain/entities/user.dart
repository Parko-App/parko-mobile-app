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

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? legajo,
    double? balance,
    bool? notificationsEnabled,
    String? rol,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      legajo: legajo ?? this.legajo,
      balance: balance ?? this.balance,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      rol: rol ?? this.rol,
    );
  }

  @override
  List<Object?> get props => [id, name, email, legajo, balance, notificationsEnabled, rol];
}
