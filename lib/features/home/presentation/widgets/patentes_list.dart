import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/widgets/vehicle_card.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../vehicles/presentation/screens/add_vehicle_screen.dart';
import '../../presentation/bloc/home_cubit.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatentesList extends StatelessWidget {
  final List<Vehicle> vehicles;

  const PatentesList({
    super.key,
    required this.vehicles,
  });

  @override
  Widget build(BuildContext context) {
    // Función auxiliar para navegar y refrescar
    Future<void> _onAddTap() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
      );
      
      if (result == true && context.mounted) {
        final authState = context.read<AuthCubit>().state;
        if (authState is Authenticated) {
          context.read<HomeCubit>().fetchHomeData(authState.user.id);
        }
      }
    }

    // Si no hay patentes, mostramos el diseño de "vacío"
    if (vehicles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.inputFieldBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined, color: AppColors.textSecondary, size: 32),
            const SizedBox(height: 12),
            Text(
              "No tenés patentes registradas",
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
            ),
            TextButton(
              onPressed: _onAddTap,
              child: const Text("+ Agregar mi primera patente"),
            ),
          ],
        ),
      );
    }

    // Si hay patentes, mostramos el scroll horizontal
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          ...vehicles.map((vehicle) => vehicle.active ? VehicleCard(vehicle: vehicle) : const SizedBox()),
          // Solo mostramos el botoncito de "+" si tiene menos de 3 vehículos
          if (vehicles.length < 3)
            GestureDetector(
              onTap: _onAddTap,
              child: Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.inputFieldBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}


/*  VIEJO BUILDER EN EL HOME_SCREEN

  Widget _buildPatentesList(HomeState state) {
    if (state is HomeLoaded) {
      if (state.vehicles.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              const Icon(Icons.directions_car_outlined, color: AppColors.textSecondary, size: 32),
              const SizedBox(height: 12),
              Text(
                "No tenés patentes registradas",
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("+ Agregar mi primera patente"),
              ),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            ...state.vehicles.map((vehicle) => vehicle.active ? VehicleCard(vehicle: vehicle) : const SizedBox()),

            // Solo mostramos el botoncito de "+" si tiene menos de 3 vehículos
            if (state.vehicles.length < 3)
              GestureDetector(
                onTap: () {}, // TODO: Navegar a pantalla de agregar patente
                child: Container(
                  width: 60,
                  height: 80, // Ajustado para que pegue con el alto de la card
                  decoration: BoxDecoration(
                    color: AppColors.inputFieldBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.add, color: AppColors.primary),
                ),
              ),
          ],
        ),
      );
    }
    return const SizedBox();
  }
 */