import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/text_field.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Círculillos bien de molesto Canter de fondo decorativos
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // Contenedor del logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Image(
                        image: AssetImage('assets/images/logo.png'),
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Parko Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Parko",

                      // Acá uso el esilo de texto definido en AppTheme
                      style: AppTheme.lightTheme.textTheme.displayLarge!.copyWith(
                      /*GoogleFonts.nunito(
                        color: const Color.fromRGBO(11, 61, 145, 1),
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        height: 1.0,*/
                      ),
                    ),
                  ),
                  
                  // textito
                  Text(
                    "Encontrá y pagá tu estacionamiento",
                    style: GoogleFonts.inter(
                      color: const Color.fromRGBO(102, 102, 102, 1),
                      fontSize: 15,
                      height: 1.0,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Campos
                  const CustomTextField(
                    label: 'Email o legajo',
                    hintText: 'legajo@dominio.frc.utn.edu.ar',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const CustomTextField(
                    label: 'Contraseña',
                    hintText: '••••••••',
                    isPassword: true,
                  ),
                  
                  // Si se olvidó la clave el wachín
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login Button
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Iniciar sesión'),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón para registrarse
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tenés cuenta? ',
                        style: TextStyle(
                          // fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Registrate',
                          style: TextStyle(
                            // fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // constructor de los circulos

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
