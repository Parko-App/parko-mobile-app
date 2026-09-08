import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/text_field.dart';
import '../bloc/vehicles_cubit.dart';
import '../bloc/vehicles_state.dart';

class AddVehicleScreen extends StatefulWidget {
  final String? initialPlate; // Patente opcional que puede venir de la pantalla anterior

  const AddVehicleScreen({super.key, this.initialPlate});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.initialPlate);
    _brandController = TextEditingController();
    _modelController = TextEditingController();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiclesCubit, VehiclesState>(
      listener: (context, state) {
        if (state is VehiclesSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo registrado con éxito'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is VehiclesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Nueva patente", style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ingresá los datos de tu vehículo",
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),

                CustomTextField(
                  label: 'Patente / Dominio',
                  hintText: 'AB123CD | AAA123',
                  controller: _plateController,
                  validator: (value) => AppValidators.required(value, 'la patente'),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Marca',
                  hintText: 'Ej: Volkswagen',
                  controller: _brandController,
                  validator: (value) => AppValidators.required(value, 'la marca'),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Modelo',
                  hintText: 'Ej: Gol',
                  controller: _modelController,
                  validator: (value) => AppValidators.required(value, 'el modelo'),
                ),

                const SizedBox(height: 48),

                BlocBuilder<VehiclesCubit, VehiclesState>(
                  builder: (context, state) {
                    final isLoading = state is VehiclesLoading;

                    return ElevatedButton(
                      onPressed: isLoading ? null : () => _submitForm(context),
                      child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Registrar vehículo'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    final isFormValid = _formKey.currentState!.validate();

    if (isFormValid) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        context.read<VehiclesCubit>().addVehicle(
          uuid: authState.user.id,
          plate: _plateController.text.trim().toUpperCase(),
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
        );
      }
    }
  }
}
