import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

  Map<String, List<String>> _carMakesModels = {};
  String? _selectedBrand;
  String? _selectedModel;
  bool _showBrandError = false;
  bool _showModelError = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.initialPlate);
    _loadCarMakesModels();
  }

  Future<void> _loadCarMakesModels() async {
    final raw = await rootBundle.loadString('assets/data/car_makes_models.json');
    final Map<String, dynamic> decoded = jsonDecode(raw);
    setState(() {
      _carMakesModels = decoded.map((brand, models) => MapEntry(brand, List<String>.from(models)));
    });
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brands = _carMakesModels.keys.toList()..sort();
    final models = _selectedBrand == null ? <String>[] : (_carMakesModels[_selectedBrand] ?? []);

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

                _SelectField(
                  label: 'Marca',
                  hint: 'Seleccioná la marca',
                  value: _selectedBrand,
                  options: brands,
                  onChanged: (brand) => setState(() {
                    _selectedBrand = brand;
                    _selectedModel = null; // cambia la marca => se pierde el modelo elegido antes
                    _showBrandError = false;
                  }),
                  showError: _showBrandError,
                  errorText: 'Por favor, seleccioná una marca',
                ),
                const SizedBox(height: 24),

                _SelectField(
                  label: 'Modelo',
                  hint: _selectedBrand == null ? 'Elegí primero la marca' : 'Seleccioná el modelo',
                  value: _selectedModel,
                  options: models,
                  onChanged: (model) => setState(() {
                    _selectedModel = model;
                    _showModelError = false;
                  }),
                  showError: _showModelError,
                  errorText: 'Por favor, seleccioná un modelo',
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
    final isPlateValid = _formKey.currentState!.validate();

    setState(() {
      _showBrandError = _selectedBrand == null;
      _showModelError = _selectedModel == null;
    });

    if (isPlateValid && _selectedBrand != null && _selectedModel != null) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        context.read<VehiclesCubit>().addVehicle(
          uuid: authState.user.id,
          plate: _plateController.text.trim().toUpperCase(),
          brand: _selectedBrand!,
          model: _selectedModel!,
        );
      }
    }
  }
}

/// Dropdown con el mismo look & feel que el selector de "Carrera / Dominio" del login.
class _SelectField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool showError;
  final String errorText;

  const _SelectField({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.showError,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
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
          menuChildren: options.map((option) {
            return MenuItemButton(
              onPressed: () => onChanged(option),
              child: Container(
                width: 250,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  option,
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
              onTap: options.isEmpty
                  ? null
                  : () {
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
                      value ?? hint,
                      style: GoogleFonts.nunito(
                        fontWeight: value == null ? FontWeight.w500 : FontWeight.w700,
                        fontSize: 15,
                        color: value == null ? AppColors.hintText : AppColors.textPrimary,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            );
          },
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              errorText,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
