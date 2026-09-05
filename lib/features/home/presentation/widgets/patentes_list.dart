import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/widgets/vehicle_card.dart';
import '../../../vehicles/presentation/screens/add_vehicle_screen.dart';
import '../../../vehicles/presentation/bloc/vehicles_cubit.dart';
import '../bloc/home_cubit.dart';

class PatentesList extends StatelessWidget {
  final List<Vehicle> vehicles;

  const PatentesList({
    super.key,
    required this.vehicles,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> onAddTap() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
      );
      
      if (result == true && context.mounted) {
        final authState = context.read<AuthCubit>().state;
        if (authState is Authenticated) {
          // Refrescamos autos y actividad después de agregar uno nuevo
          context.read<VehiclesCubit>().fetchVehicles(authState.user.id);
          context.read<HomeCubit>().fetchHomeData(authState.user.id);
        }
      }
    }

    if (vehicles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.inputFieldBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
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
              onPressed: onAddTap,
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
          ...vehicles.map((vehicle) => vehicle.active ? VehicleCard(vehicle: vehicle) : const SizedBox()),
          if (vehicles.length < 3)
            GestureDetector(
              onTap: onAddTap,
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
