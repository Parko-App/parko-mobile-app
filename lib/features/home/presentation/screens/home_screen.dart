import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parko_mobile_app/features/home/presentation/widgets/patentes_list.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import '../../../vehicles/presentation/bloc/vehicles_cubit.dart';
import '../../../vehicles/presentation/bloc/vehicles_state.dart';
import '../../../vehicles/presentation/screens/my_vehicles_screen.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Sacamos el nombre y el ID del AuthCubit global para dárselo al HomeCubit
      create: (context) {
        String userId = "";
        final authState = context.read<AuthCubit>().state;
        if (authState is Authenticated) {
          userId = authState.user.id;
        }
        return HomeCubit(
          authRepository: context.read<AuthRepository>(), 
          vehicleRepository: context.read<VehicleRepository>(),
        )..fetchHomeData(userId);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {

              if (state is HomeLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
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
              String userName = "Usuario";
              if (state is HomeLoaded) {
                userName = state.userName;
              }
              final String userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";
              return RefreshIndicator(
                // Al deslizar para actualizar, refrescamos ambos: Home (saldo) y Vehículos
                onRefresh: () async {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is Authenticated) {
                    await Future.wait([
                      context.read<HomeCubit>().fetchHomeData(authState.user.id),
                      context.read<VehiclesCubit>().fetchVehicles(authState.user.id),
                    ]);
                  }
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

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

                      _buildSaldoCard(state),

                      const SizedBox(height: 32),

                      _buildPatentesHeader(context),
                      const SizedBox(height: 12),
                      
                      // ¡CLAVE! La lista de patentes ahora escucha al VehiclesCubit GLOBAL.
                      // Esto asegura sincronización total entre pantallas.
                      BlocBuilder<VehiclesCubit, VehiclesState>(
                        builder: (context, vehiclesState) {
                          if (vehiclesState is VehiclesLoaded) {
                            return PatentesList(vehicles: vehiclesState.vehicles);
                          }
                          // Si terminó de agregar con éxito, también mostramos la lista que trae el estado
                          if (vehiclesState is VehiclesSuccess) {
                            return PatentesList(vehicles: vehiclesState.vehicles);
                          }

                          return state is HomeLoaded 
                              ? PatentesList(vehicles: state.vehicles) 
                              : const SizedBox();
                        },
                      ),

                      const SizedBox(height: 32),

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
      ),
    );
  }

  // Builders de los widgets (los quiero sacar a archivos diferentes despué)

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

  Widget _buildPatentesHeader(BuildContext context) {
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
          onPressed: () async {
            // Navegamos a la gestión de patentes
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyVehiclesScreen()),
            );
            
            // Al volver, si es necesario, podemos refrescar (aunque ya estará sincronizado por el Cubit global)
            if (mounted) {
              final authState = context.read<AuthCubit>().state;
              if (authState is Authenticated) {
                context.read<HomeCubit>().fetchHomeData(authState.user.id);
              }
            }
          },
          child: const Text(
            "Ver todas",
            style: TextStyle(
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
}
