# Parko Mobile

## Estado del Proyecto
Actualmente estamos en la fase de **Maquetado y UI**, terminando de pulir el flujo de autenticación (Login y Registro) con validaciones robustas y un diseño bien moderno.

## Arquitectura
Estamos usando **Clean Architecture** para que el código sea escalable y fácil de mantener. La estructura por cada **feature** (como `auth`) se organiza de la siguiente manera:

```text
lib/features/auth/
├── data/                  # CAPA DE DATOS (
│   ├── datasources/       # Llamadas a la API (auth_remote_datasource.dart)
│   ├── models/            # Modelos de datos (user_model.dart) 
├── domain/                # CAPA DE NEGOCIO (Reglas puras)
│   ├── entities/          # Clases simples de Dart (User)
│   ├── repositories/      # Definiciones (interfaces) de lo que el repositorio debe hacer
│   └── usecases/          # Lógica específica (login_usecase.dart)
└── presentation/          # CAPA DE UI
    ├── bloc/ o provider/  # Manejo de estados (Cubit/Bloc)
    ├── screens/           # Tus pantallas (login_screen.dart, register_screen.dart)
    └── widgets/           # Componentes pequeños (text_field.dart)
```

La idea es separar bien las cosas:
- **Core:** Todo lo compartido como el tema, colores y utilidades de validación.
- **Features:** Cada funcionalidad tiene su propia lógica de presentación, dominio y datos siguiendo el esquema de arriba.
- **Presentación:** UI reactiva usando Widgets personalizados y validadores centralizados.

## Funcionalidades Actuales
- **Login:** Validación de campos obligatorios y feedback visual de carga.
- **Registro:**
  - Validación de correo institucional específico por carrera (`@sistemas.frc.utn.edu.ar`, etc.).
  - Validación de contraseña segura (mínimo 8 caracteres, mayúscula y número).
  - Manejo de legajos numéricos.
  - Diseño fiel al Figma con elementos decorativos.

## Tecnologías
- **Flutter & Dart**
- **Google Fonts**: Usando *Nunito* para títulos y *Inter* para el cuerpo de texto.
- **Clean Architecture**: Organización por capas.

## Cómo probar la app (Android)
Si querés ver cómo viene quedando:
1. Cloná el repo: `git clone https://github.com/Parko-App/parko-mobile-app.git`
2. Instalá las dependencias: `flutter pub get`
3. Corré la app: `flutter run`

