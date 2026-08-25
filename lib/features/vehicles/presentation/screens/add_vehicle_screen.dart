import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/text_field.dart';
import '../../data/datasources/car_info_remote_datasource.dart';
import '../../domain/entities/car_brand.dart';
import '../../domain/entities/car_model.dart';
import '../bloc/car_info_cubit.dart';
import '../bloc/car_info_state.dart';
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
  
  // Variables para los selectores
  CarBrand? _selectedBrand;
  CarModel? _selectedModel;
  bool _showFormErrors = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador con la patente que viene
    _plateController = TextEditingController(text: widget.initialPlate);
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Envolvemos la pantalla en el CarInfoCubit para cargar marcas/modelos
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CarInfoCubit(
            dataSource: CarInfoRemoteDataSourceImpl(client: http.Client()),
          )..fetchBrands(),
        ),
      ],
      child: BlocListener<VehiclesCubit, VehiclesState>(
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
                    hintText: 'Ej: AB123CD',
                    controller: _plateController,
                    validator: (value) => AppValidators.required(value, 'la patente'),
                  ),
                  const SizedBox(height: 24),
                  
                  // Selector de Marca
                  _buildBrandSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Selector de Modelo
                  _buildModelSelector(),
                  
                  const SizedBox(height: 48),
                  
                  // El botón ahora reacciona al estado del Cubit GLOBAL
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
      ),
    );
  }

  Widget _buildBrandSelector() {
    return BlocBuilder<CarInfoCubit, CarInfoState>(
      builder: (context, state) {
        bool isLoading = state.isLoadingBrands;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Marca",
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
                fixedSize: const WidgetStatePropertyAll(Size(320, 300)),
              ),
              menuChildren: state.brands.map((brand) {
                return MenuItemButton(
                  onPressed: () {
                    setState(() {
                      _selectedBrand = brand;
                      _selectedModel = null; // Reseteamos el modelo al cambiar de marca
                    });
                    // Cargamos los modelos de la marca elegida
                    context.read<CarInfoCubit>().fetchModels(brand.id);
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      brand.name,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                );
              }).toList(),
              builder: (context, controller, child) {
                return InkWell(
                  onTap: isLoading ? null : () {
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
                        if (isLoading)
                          const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          Text(
                            _selectedBrand?.name ?? 'Seleccioná la marca',
                            style: GoogleFonts.nunito(
                              fontWeight: _selectedBrand == null ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 15,
                              color: _selectedBrand == null ? AppColors.hintText : AppColors.textPrimary,
                            ),
                          ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_showFormErrors && _selectedBrand == null)
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text("Por favor, seleccioná una marca", style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModelSelector() {
    return BlocBuilder<CarInfoCubit, CarInfoState>(
      builder: (context, state) {
        bool isLoading = state.isLoadingModels;
        bool isEnabled = _selectedBrand != null;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Modelo",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isEnabled ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
                ),
              ),
            ),
            MenuAnchor(
              style: MenuStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                elevation: WidgetStateProperty.all(12),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                fixedSize: const WidgetStatePropertyAll(Size(320, 300)),
              ),
              menuChildren: state.models.map((model) {
                return MenuItemButton(
                  onPressed: () {
                    setState(() {
                      _selectedModel = model;
                    });
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      model.name,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                );
              }).toList(),
              builder: (context, controller, child) {
                return InkWell(
                  onTap: (!isEnabled || isLoading) ? null : () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isEnabled ? AppColors.inputFieldBackground : AppColors.inputFieldBackground.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.isOpen ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isLoading)
                          const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          Text(
                            _selectedModel?.name ?? 'Seleccioná el modelo',
                            style: GoogleFonts.nunito(
                              fontWeight: _selectedModel == null ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 15,
                              color: _selectedModel == null ? AppColors.hintText : AppColors.textPrimary,
                            ),
                          ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_showFormErrors && _selectedModel == null && isEnabled)
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text("Por favor, seleccioná un modelo", style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }

  void _submitForm(BuildContext context) {
    setState(() => _showFormErrors = true);

    final isFormValid = _formKey.currentState!.validate();
    final isBrandValid = _selectedBrand != null;
    final isModelValid = _selectedModel != null;

    if (isFormValid && isBrandValid && isModelValid) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        context.read<VehiclesCubit>().addVehicle(
          uuid: authState.user.id,
          plate: _plateController.text.trim().toUpperCase(),
          brand: _selectedBrand!.name,
          model: _selectedModel!.name,
        );
      }
    }
  }
}
