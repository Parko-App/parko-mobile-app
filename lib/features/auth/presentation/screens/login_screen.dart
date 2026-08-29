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

  final _formKey = GlobalKey<FormState>();

  final _legajoController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedDomain;
  bool _showDomainError = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _legajoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {

        if (state is AuthError) {
          setState(() => _isLoading = false);
          if(state.message.contains('incorrect, malformed or has expired') ||
              state.message.contains("invalid-credential'")){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El email o la contraseña con incorrectos'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          if(state.message.contains('badly formatted')){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
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
                      
                      // legajo numerico
                      CustomTextField(
                        label: 'Legajo',
                        hintText: '123456',
                        controller: _legajoController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final requiredErr = AppValidators.required(value, 'legajo');
                          if (requiredErr != null) return requiredErr;
                          return AppValidators.legajo(value);
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // dropdown dominios
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              "Carrera / Dominio",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          MenuAnchor(
                            style: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.white),
                              elevation: WidgetStateProperty.all(12),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              fixedSize: const WidgetStatePropertyAll(Size(300, 300)),
                            ),
                            menuChildren: AppValidators.institutionalDomains.map((String domain) {
                              return MenuItemButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedDomain = domain;
                                  });
                                },
                                child: Container(
                                  width: 250,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    domain.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            builder: (context, controller, child) {
                              return InkWell(
                                onTap: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFieldBackground,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: controller.isOpen ? AppColors.primary : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedDomain == null 
                                            ? 'Seleccioná tu carrera' 
                                            : _selectedDomain!.toUpperCase(),
                                        style: GoogleFonts.nunito(
                                          fontWeight: _selectedDomain == null ? FontWeight.w500 : FontWeight.w700,
                                          fontSize: 15,
                                          color: _selectedDomain == null ? AppColors.hintText : AppColors.textPrimary,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Mensaje de error manual para el dominio
                          if (_showDomainError && _selectedDomain == null)
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 8),
                              child: Text(
                                "Por favor, seleccioná un dominio",
                                style: TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ),
                        ],
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
                            setState(() => _showDomainError = true);

                            final isFormValid = _formKey.currentState!.validate();

                            final isDomainValid = _selectedDomain != null;

                            if (!isFormValid || !isDomainValid) {
                              return;
                            }

                            setState(() => _isLoading = true);

                            // Armamos el email completo
                            final fullEmail = '${_legajoController.text.trim()}@$_selectedDomain.frc.utn.edu.ar';

                            await context.read<AuthCubit>().login(
                              fullEmail,
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
