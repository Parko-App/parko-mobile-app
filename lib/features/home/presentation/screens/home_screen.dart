import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parko_mobile_app/features/home/presentation/widgets/patentes_list.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import '../../../vehicles/presentation/widgets/vehicle_card.dart';
import '../../../vehicles/presentation/screens/add_vehicle_screen.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Creamos el Cubit y disparamos la carga inicial al nacer el widget
      // Sacamos el nombre y el ID del AuthCubit global para dárselo al HomeCubit
      create: (context) {
        String userId = "";
        String? token = "";
        final authState = context.read<AuthCubit>().state;
        if (authState is Authenticated) {
          userId = authState.user.id;
        }
        return HomeCubit(
          authRepository: context.read<AuthRepository>(), vehicleRepository: context.read<VehicleRepository>(),
        )..fetchHomeData(userId);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          // El BlocBuilder escucha al Cubit y redibuja según el estado
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {

              // 1. ESTADO DE CARGA: Mostramos un circulito mientras pedimos los datos
              if (state is HomeLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              // 2. ESTADO DE ERROR: Si algo falló, mostramos un mensaje y botón
              if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(state.message, style: GoogleFonts.inter()),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final authState = context.read<AuthCubit>().state;
                          if (authState is Authenticated) {
                            context.read<HomeCubit>().fetchHomeData(authState.user.id);
                          }
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              // Obtenemos el nombre y la inicial desde el estado del HomeCubit
              String userName = "Usuario";
              if (state is HomeLoaded) {
                userName = state.userName;
              }
              final String userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

              // 3. ESTADO DE ÉXITO (HomeLoaded): Mostramos la UI dinámica
              return RefreshIndicator(
                // Pull-to-refresh: al deslizar hacia abajo, vuelve a pedir todo
                onRefresh: () {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is Authenticated) {
                    return context.read<HomeCubit>().fetchHomeData(authState.user.id);
                  }
                  return Future.value();
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  // physics necesario para que el RefreshIndicator ande siempre
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Header Dinámico, por ahora no funciona ni la campanita ni la inicial
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hola,",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                userName.toUpperCase(),
                                style: GoogleFonts.nunito(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Campanita con badge (fija por ahora)
                              _buildNotificationBell(),
                              const SizedBox(width: 12),
                              // Inicial del perfil dinámica
                              _buildProfileInitial(userInitial),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Tarjeta de Saldo Dinámica
                      _buildSaldoCard(state),

                      const SizedBox(height: 32),

                      // Sección: Tus patentes Dinámica
                      _buildPatentesHeader(),
                      const SizedBox(height: 12),
                      //_buildPatentesList(state),
                      state is HomeLoaded ? PatentesList(vehicles: state.vehicles) : const SizedBox(),

                      const SizedBox(height: 32),

                      // Sección: Actividad reciente Dinámica
                      Text(
                        "Actividad reciente",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActividadList(state),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA LIMPIAR EL BUILD ---

  Widget _buildNotificationBell() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Stack(
        children: [
          Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary),
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              radius: 4,
              backgroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInitial(String initial) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSaldoCard(HomeState state) {
    // Si no cargó todavía, mostramos 0, si cargó mostramos el saldo real
    String balanceStr = "0";
    if (state is HomeLoaded) {
      balanceStr = state.balance.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.'
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saldo disponible",
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "\$ $balanceStr",
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(160, 48),
                  elevation: 0,
                ),
                child: const Text('Cargar saldo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatentesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Tus patentes",
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "Ver todas",
            style: GoogleFonts.inter(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildActividadList(HomeState state) {
    if (state is HomeLoaded && state.actividad.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Todavía no tenés movimientos",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "¡Tus estacionamientos aparecerán acá!",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          // Esto es hasta hacer el botón para cerrar sesión correctamente
          if (index == 3) _showLogoutDialog();
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary.withValues(alpha: 0.5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car_filled_rounded), label: 'Patentes'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que querés salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              // 1. Cerramos la sesión en el Cubit (esto ya limpia Firebase)
              await context.read<AuthCubit>().logout();
              
              if (mounted) {
                // 2. Cerramos el diálogo y cualquier pantalla que esté por encima.
                // Al volver a la "raíz", el main.dart verá que no hay sesión
                // y mostrará el Login solo.
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
