import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicles/presentation/screens/my_vehicles_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String userName = "Usuario";
        String userEmail = "";
        if (state is Authenticated) {
          userName = state.user.name;
          userEmail = state.user.email;
        }
        final String userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Mi perfil",
              style: GoogleFonts.nunito(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Avatar e Info de Perfil
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                userInitial,
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_outlined, size: 20, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Cambiar foto de perfil",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Sección CUENTA
                _buildSectionHeader("CUENTA"),
                _buildMenuContainer([
                  _buildMenuItem(Icons.person_outline, "Editar datos personales", onTap: () {}),
                  _buildMenuItem(Icons.lock_outline, "Cambiar contraseña", onTap: () {}),
                  _buildMenuItem(Icons.directions_car_outlined, "Mis patentes", onTap: () {
                    // Navegamos a la pantalla de patentes
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyVehiclesScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.payment_outlined, "Métodos de pago", onTap: () {}),
                ]),

                const SizedBox(height: 32),

                // Sección PREFERENCIAS
                _buildSectionHeader("PREFERENCIAS"),
                _buildMenuContainer([
                  _buildMenuItem(
                    Icons.notifications_none_outlined, 
                    "Notificaciones", 
                    trailing: Switch(
                      value: true, 
                      onChanged: (v) {},
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _buildMenuItem(Icons.help_outline, "Ayuda y soporte", onTap: () {}),
                  _buildMenuItem(Icons.description_outlined, "Términos y condiciones", onTap: () {}),
                ]),

                const SizedBox(height: 32),

                // Botón de Cerrar Sesión
                ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    elevation: 0,
                  ),
                  child: const Text("Cerrar sesión"),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que querés salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text('Salir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
