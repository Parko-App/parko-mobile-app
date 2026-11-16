import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.legajo,
    super.balance,
    super.rol
  });

  // Crea un UserModel a partir de un Map (JSON) que viene del backend.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['fullName'] ?? '',
      email: json['email'] ?? '',
      legajo: json['studentId'],
      balance: json['balance'],
      rol: json["role"],
    );
  }

  // Convierte el modelo a un Map para enviarlo al backend si fuera necesario.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'legajo': legajo,
    };
  }
}
