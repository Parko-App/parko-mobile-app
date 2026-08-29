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
import '../widgets/balance_card.dart';
import '../widgets/actividad_reciente.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

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
                                userName,
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
                              _buildNotificationBell(),
                              const SizedBox(width: 12),
                              // Inicial del perfil conectada con la ProfileScreen
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                  );
                                },
                                child: _buildProfileInitial(userInitial),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      if (state is HomeLoaded) BalanceCard(balance: state.balance),

                      const SizedBox(height: 32),

                      _buildPatentesHeader(context),
                      const SizedBox(height: 12),
                      
                      BlocBuilder<VehiclesCubit, VehiclesState>(
                        builder: (context, vehiclesState) {
                          if (vehiclesState is VehiclesLoaded) {
                            return PatentesList(vehicles: vehiclesState.vehicles);
                          }
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
                      
                      // Actividad Reciente Mockeada para la Demo con tarjetas y iconos
                      if (state is HomeLoaded) ActividadReciente(actividad: state.actividad),

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
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyVehiclesScreen()),
            );
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
}
