class User {
  final String id;
  final String name;
  final String email;
  final String? legajo;
  final double? balance;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.legajo,
    this.balance = 0.0,
  });
}
