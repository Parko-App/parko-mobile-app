class AppValidators {
  /// Validador para campos que no pueden estar vacíos.
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresá tu $fieldName';
    }
    return null;
  }

  static const institutionalDomains = [
    'cbasicas', 'civil', 'computos', 'decanato', 'egresado', 'electrica',
    'electronica', 'extension', 'industrial', 'licenciatura', 'mecanica',
    'metalurgica', 'org', 'posgrado', 'punilla', 'quimica', 'radio', 'sa',
    'sae', 'scdt', 'sistemas', 'tecnicatura', 'virtual',
  ];

  static final _institutionalEmailRegExp =
      RegExp(r'^([1-9][0-9]{0,4})@(?:([a-z]+)\.)?frc\.utn\.edu\.ar$');

  /// Validador de correo institucional de la UTN FRC
  /// Soporta dominios tipo @carrera.frc.utn.edu.ar
  static String? institutionalEmail(String? value) {
    if (value == null || value.isEmpty) return 'Por favor, ingresá tu correo';

    final match = _institutionalEmailRegExp.firstMatch(value.toLowerCase());
    if (match == null) {
      return 'Debe ser un correo legajo@carrera.frc.utn.edu.ar';
    }

    final domain = match.group(2);
    if (domain != null && !institutionalDomains.contains(domain)) {
      return 'Carrera no reconocida. Ej: sistemas, civil, etc.';
    }

    return null;
  }

  static String studentIdFromEmail(String email) {
    return _institutionalEmailRegExp.firstMatch(email.toLowerCase())!.group(1)!;
  }

  static String institutionalDomainFromEmail(String email) {
    final domain = _institutionalEmailRegExp.firstMatch(email.toLowerCase())!.group(2);
    return (domain ?? 'frc').toUpperCase();
  }

  static String? legajo(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value.trim()) == null) {
      return 'El legajo debe ser un número';
    }
    return null;
  }

  /// Validador de formato de email genérico
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Por favor, ingresá tu email';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Ingresá un email válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Por favor, ingresá tu contraseña';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirmá tu contraseña';
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
