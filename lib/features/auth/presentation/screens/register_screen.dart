import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Llave para el formulario de registro
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _legajoController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Estado para el checkbox de términos
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _legajoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -100,
            right: -50,
            child: _buildDecorativeCircle(250, AppColors.circulos.withValues(alpha: 0.5)),
          ),
          Positioned(
            top: 150,
            left: -80,
            child: _buildDecorativeCircle(200, AppColors.circulos.withValues(alpha: 0.5)),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    // Botón de volver
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Título de la pantalla
                    Text(
                      "Creá tu cuenta",
                      style: AppTheme.lightTheme.textTheme.displayLarge,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtítulo
                    Text(
                      "Usá tu correo institucional de la UTN FRC",
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Campo: Nombre completo
                    CustomTextField(
                      label: 'Nombre completo',
                      hintText: 'Perita Perazolo',
                      controller: _nameController,
                      validator: (value) => AppValidators.required(value, 'nombre completo'),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo: Correo institucional
                    CustomTextField(
                      label: 'Correo institucional',
                      hintText: 'legajo@carrera.frc.utn.edu.ar',
                      controller: _emailController,
                      helperText: 'Ej: legajo@sistemas.frc.utn.edu.ar',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => AppValidators.institutionalEmail(value),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo: Legajo (opcional pero con validación de número si pone algo)
                    CustomTextField(
                      label: 'Legajo (si tenés)',
                      hintText: 'Ej: 82412',
                      controller: _legajoController,
                      helperText: 'Solo si sos alumno con legajo asignado',
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo: Contraseña
                    CustomTextField(
                      label: 'Contraseña',
                      hintText: '••••••••',
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) => AppValidators.password(value),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Checkbox de términos y condiciones
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _acceptTerms,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Acepto los términos y condiciones',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de crear cuenta
                    ElevatedButton(
                      onPressed: (_isLoading || !_acceptTerms)
                        ? null 
                        : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            
                            // Mensajito de éxito (simulado por ahora)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Creando cuenta...'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            
                            // Simulamos demora
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                print("Registro exitoso!");
                              }
                            });
                          }
                        },
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Crear cuenta'),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Footer: ¿Ya tenés cuenta?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tenés cuenta? ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Iniciá sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // El mismo constructor de circulitos para que pegue con el Login
  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
