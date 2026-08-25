import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/vehicles_cubit.dart';
import '../bloc/vehicles_state.dart';
import 'add_vehicle_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  final _plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Al entrar, pedimos los datos al Cubit Global (definido en main.dart)
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<VehiclesCubit>().fetchVehicles(authState.user.id);
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos al VehiclesCubit GLOBAL (el que vive en main.dart)
    return BlocConsumer<VehiclesCubit, VehiclesState>(
      listener: (context, state) {
        if (state is VehiclesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        if (state is VehiclesLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Definimos la lista de vehículos según el estado (Loaded o Success)
        List vehicles = [];
        if (state is VehiclesLoaded) {
          vehicles = state.vehicles;
        } else if (state is VehiclesSuccess) {
          vehicles = state.vehicles;
        }

        final int count = vehicles.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.of(context).canPop() 
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
            title: Text(
              "Mis patentes",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Indicador de patentes vinculadas
                Row(
                  children: [
                    Row(
                      children: List.generate(3, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < count ? AppColors.primary : AppColors.circulos,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$count de 3 patentes vinculadas",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Lista de patentes
                ...vehicles.map((v) => _buildVehicleItem(context, v)),

                const SizedBox(height: 32),

                Text(
                  "Vincular nueva patente",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.inputFieldBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _plateController,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: "Ej: AA111AA",
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "Aceptamos formato viejo (AAA111) y Mercosur (AA111AA)",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Botón Vincular
                ElevatedButton(
                  onPressed: count >= 3 
                    ? null 
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddVehicleScreen(
                              initialPlate: _plateController.text.trim(),
                            ),
                          ),
                        );
                        
                        if (result == true && mounted) {
                          _plateController.clear();
                          // No hace falta llamar a fetchVehicles acá, 
                          // porque el propio Cubit se actualiza al agregar con éxito.
                        }
                      },
                  child: const Text("Vincular patente"),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleItem(BuildContext context, dynamic vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.plate.toUpperCase(),
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${vehicle.brand} ${vehicle.model}",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _confirmDelete(context, vehicle),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic vehicle) {
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: const Text("¿Eliminar vehículo?"),
        content: Text("Se desvinculará la patente ${vehicle.plate} de tu cuenta."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(diagContext);
              final authState = context.read<AuthCubit>().state;
              if (authState is Authenticated) {
                context.read<VehiclesCubit>().deleteVehicle(vehicle.id, authState.user.id);
              }
            },
            child: const Text("Eliminar", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
