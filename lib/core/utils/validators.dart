class AppValidators {
  /// Validador para campos que no pueden estar vacíos.
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresá tu $fieldName';
    }
    return null;
  }

  /// Validador de correo institucional de la UTN FRC
  /// Soporta dominios tipo @carrera.frc.utn.edu.ar
  static String? institutionalEmail(String? value) {
    if (value == null || value.isEmpty) return 'Por favor, ingresá tu correo';

    // Carreroidas
    const validCareers = [
      'sistemas',
      'industrial',
      'civil',
      'mecanica',
      'electronica'
      'electrica'
      'metalurgica'
    ];

    // Expresión regular para validar el formato legajo@carrera.frc.utn.edu.ar
    // Captura lo que está entre el @ y el .frc
    final emailRegExp = RegExp(r'^([\w-\.]+)@([\w-]+)\.frc\.utn\.edu\.ar$');
    final match = emailRegExp.firstMatch(value);

    if (match == null) {
      return 'Debe ser un correo legajo@carrera.frc.utn.edu.ar';
    }
    // Extraemos la carrera del match (grupo 1)
    final legajo = match.group(1)!;
    final career = match.group(2)!.toLowerCase();

    if(int.tryParse(legajo) == null){
      return 'El legajo debe ser un número';
    }

    if (!validCareers.contains(career)) {
      return 'Carrera no reconocida. Ej: sistemas, civil, etc.';
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

  /// Validador de contraseña (mínimo 8 caracteres, una mayúscula y un número)
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Por favor, ingresá tu contraseña';
    
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe tener al menos una mayúscula';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe tener al menos un número';
    }

    return null;
  }
}
