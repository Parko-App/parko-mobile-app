class User {
  final String id;
  final String name;
  final String email;
  final String? legajo;
  final double? balance;
  final bool notificationsEnabled; // local hasta que esté en el back
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
}
