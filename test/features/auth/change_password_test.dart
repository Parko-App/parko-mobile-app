import 'package:flutter_test/flutter_test.dart';
import 'package:parko_mobile_app/core/utils/validators.dart';

void main() {
  group('ChangePassword Validation Tests', () {
    test('debe validar que la contraseña actual sea requerida', () {
      expect(AppValidators.required('', 'tu contraseña actual'), isNotNull);
      expect(AppValidators.required('  ', 'tu contraseña actual'), isNotNull);
      expect(AppValidators.required('Pass1234', 'tu contraseña actual'), isNull);
    });

    test('debe validar requisitos de nueva contraseña (mínimo 8 caracteres, 1 mayúscula, 1 número)', () {
      expect(AppValidators.password('short1A'), isNotNull); // muy corta
      expect(AppValidators.password('password123'), isNotNull); // sin mayúscula
      expect(AppValidators.password('PASSWORDABC'), isNotNull); // sin números
      expect(AppValidators.password('Password123'), isNull); // válida
    });

    test('debe validar coincidencia entre nueva contraseña y confirmación', () {
      expect(AppValidators.confirmPassword('Password123', 'Password999'), isNotNull);
      expect(AppValidators.confirmPassword('Password123', 'Password123'), isNull);
    });
  });
}
