import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/validators.dart';
import 'register_screen.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // La GlobalKey nos permite acceder al estado del Form desde fuera (ej. desde el botón)
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto ingresado
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variable para manejar el estado de carga
  bool _isLoading = false;

  @override
  void dispose() {
    // limpiar los controladores cuando el widget se destruye
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Si el Cubit emite un error, lo mostramos acá
        if (state is AuthError) {
          setState(() => _isLoading = false);
          if(state.message.contains('incorrect, malformed or has expired') ||
              state.message.contains("invalid-credential'")){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('El email o la contraseña con incorrectos'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          if(state.message.contains('badly formatted')){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('El formato del correo no es correcto'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Círculillos decorativos
            Positioned(top: -100, right: -50, child: _buildDecorativeCircle(250, AppColors.circulos.withValues(alpha: 0.5))),
            Positioned(top: 150, left: -80, child: _buildDecorativeCircle(200, AppColors.circulos.withValues(alpha: 0.5))),
            
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Contenedor del logo
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: const Center(child: Image(image: AssetImage('assets/images/logo.png'), width: 70, height: 70, fit: BoxFit.contain)),
                      ),
                      const SizedBox(height: 24),
                      Text("Parko", style: AppTheme.lightTheme.textTheme.displayLarge),
                      Text("Encontrá y pagá tu estacionamiento", style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 15)),
                      const SizedBox(height: 48),
                      
                      CustomTextField(
                        label: 'Email o legajo',
                        hintText: 'legajo@dominio.frc.utn.edu.ar',
                        controller: _emailController,
                        validator: (value) => AppValidators.required(value, 'email o legajo'),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Contraseña',
                        hintText: '••••••••',
                        isPassword: true,
                        controller: _passwordController,
                        validator: (value) => AppValidators.required(value, 'contraseña'),
                      ),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () {}, child: Text('¿Olvidaste tu contraseña?', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.primary))),
                      ),
                      const SizedBox(height: 24),

                      /// Boton de login
                      ElevatedButton(
                        onPressed: _isLoading
                          ? null
                          : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isLoading = true);

                            // LLAMADO UNIFICADO AL CUBIT
                            await context.read<AuthCubit>().login(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );

                            if (mounted) setState(() => _isLoading = false);
                          },
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Iniciar sesión'),
                      ),
                      
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿No tenés cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                            child: const Text('Registrate', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
