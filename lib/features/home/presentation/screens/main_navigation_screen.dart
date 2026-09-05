import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicles/presentation/bloc/vehicles_cubit.dart';
import '../../../vehicles/presentation/screens/my_vehicles_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../transactions/presentation/screens/history_screen.dart';
import '../bloc/home_cubit.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressTime;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Las 4 pantallas principales de la barra
  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(), // ¡Activada la pantalla de Historial real!
    const MyVehiclesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    final String status = uri.host;

    if (status == 'success') {
      _showPaymentFeedback(
        title: "¡Pago Exitoso!",
        message: "Tu saldo se acreditará en unos instantes.",
        isSuccess: true,
      );
      context.read<AuthCubit>().refreshProfile();
    } else if (status == 'failure') {
      _showPaymentFeedback(
        title: "Pago Fallido",
        message: "Hubo un error al procesar el pago. Intentá de nuevo.",
        isSuccess: false,
      );
    } else if (status == 'pending') {
      _showPaymentFeedback(
        title: "Pago Pendiente",
        message: "Estamos esperando la confirmación de Mercado Pago.",
        isSuccess: true,
      );
    }
  }

  void _showPaymentFeedback({required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(color: isSuccess ? Colors.green : Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressTime == null || 
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          
          _lastBackPressTime = now;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Presioná de nuevo para salir de Parko'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
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
        ),
      ),
    );
  }
}
