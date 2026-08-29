import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _legajoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedDomain;
  bool _showDomainError = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _legajoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else if (state is AuthError) {
          setState(() => _isLoading = false);
          
          String message = state.message;
          if (message.contains('email-already-in-use')) {
            message = 'Este correo ya está registrado';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is Authenticated) {
          setState(() => _isLoading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta creada con éxito'),
              backgroundColor: AppColors.primary,
            ),
          );

          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Círculos decorativos
            Positioned(top: -100, right: -50, child: _buildDecorativeCircle(250, AppColors.circulos.withValues(alpha: 0.5))),
            Positioned(top: 150, left: -80, child: _buildDecorativeCircle(200, AppColors.circulos.withValues(alpha: 0.5))),
            
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
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primary),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      Text("Creá tu cuenta", style: AppTheme.lightTheme.textTheme.displayLarge),
                      const SizedBox(height: 8),
                      Text("Unite a la comunidad de Parko", style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 15)),
                      const SizedBox(height: 32),
                      
                      // Campo: Nombre completo
                      CustomTextField(
                        label: 'Nombre completo',
                        hintText: 'Perita Perazolo',
                        controller: _nameController,
                        validator: (value) => AppValidators.required(value, 'nombre completo'),
                      ),
                      const SizedBox(height: 20),
                      
                      // Campo: Legajo (ahora obligatorio para el mail)
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
                      
                      // Selector de Carrera / Dominio
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
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                              fixedSize: const WidgetStatePropertyAll(Size(300, 300)),
                            ),
                            menuChildren: AppValidators.institutionalDomains.map((String domain) {
                              return MenuItemButton(
                                onPressed: () => setState(() => _selectedDomain = domain),
                                child: Container(
                                  width: 250,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    domain.toUpperCase(),
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ),
                              );
                            }).toList(),
                            builder: (context, controller, child) {
                              return InkWell(
                                onTap: () => controller.isOpen ? controller.close() : controller.open(),
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
                                        _selectedDomain == null ? 'Seleccioná tu carrera' : _selectedDomain!.toUpperCase(),
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
                          if (_showDomainError && _selectedDomain == null)
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 8),
                              child: Text("Por favor, seleccioná un dominio", style: TextStyle(color: AppColors.error, fontSize: 12)),
                            ),
                        ],
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
                      const SizedBox(height: 20),

                      CustomTextField(
                        label: 'Confirmar contraseña',
                        hintText: '••••••••',
                        isPassword: true,
                        controller: _confirmPasswordController,
                        validator: (value) => AppValidators.confirmPassword(value, _passwordController.text),
                      ),
                      const SizedBox(height: 24),

                      // Checkbox de términos
                      Row(
                        children: [
                          SizedBox(
                            height: 24, width: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Acepto los términos y condiciones', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14))),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Botón de crear cuenta
                      ElevatedButton(
                        onPressed: (_isLoading || !_acceptTerms)
                          ? null
                          : () {
                            setState(() => _showDomainError = true);
                            if (!_formKey.currentState!.validate() || _selectedDomain == null) return;

                            // Armamos el email institucional
                            final fullEmail = '${_legajoController.text.trim()}@$_selectedDomain.frc.utn.edu.ar';

                            context.read<AuthCubit>().registerUser(
                              name: _nameController.text.trim(),
                              email: fullEmail,
                              password: _passwordController.text,
                              termsAccepted: _acceptTerms,
                              legajo: _legajoController.text.trim(),
                            );
                          },
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Crear cuenta'),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Ya tenés cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text('Iniciá sesión', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
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
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
