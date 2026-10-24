import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicles/presentation/screens/my_vehicles_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../transactions/presentation/screens/history_screen.dart';
import '../../../transactions/presentation/bloc/transaction_cubit.dart';
import '../../../occupancy/presentation/bloc/occupancy_cubit.dart';
import '../../../occupancy/presentation/bloc/occupancy_state.dart';
import '../../../occupancy/presentation/screens/occupancy_screen.dart';
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const OccupancyScreen(),
    const HistoryScreen(),
    const MyVehiclesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _startGlobalListeners();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    context.read<TransactionCubit>().stopPolling();
    context.read<OccupancyCubit>().stopPolling();
    super.dispose();
  }

  void _startGlobalListeners() {
    final authCubit = context.read<AuthCubit>();
    final transactionCubit = context.read<TransactionCubit>();

    final authState = authCubit.state;
    if (authState is Authenticated) {
      // Polling unico para actualizar el monto y movimientos (ojala lo podamos cambiar mas adelante pollo)
      transactionCubit.startPolling(
        authState.user.id,
        onTick: () => authCubit.refreshProfile(),
      );
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    final occupancyCubit = context.read<OccupancyCubit>();

    if (index == 1) {
      if (occupancyCubit.state is! OccupancyLoaded) {
        occupancyCubit.fetchOccupancy();
      }
      occupancyCubit.startPolling();
    } else {
      occupancyCubit.stopPolling();
    }
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
      _showPaymentFeedback(title: "¡Pago Exitoso!", message: "Tu saldo se acreditará en unos instantes.", isSuccess: true);
      context.read<AuthCubit>().refreshProfile();
    } else if (status == 'failure') {
      _showPaymentFeedback(title: "Pago Fallido", message: "Hubo un error al procesar el pago. Intentá de nuevo.", isSuccess: false);
    } else if (status == 'pending') {
      _showPaymentFeedback(title: "Pago Pendiente", message: "Estamos esperando la confirmación de Mercado Pago.", isSuccess: true);
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Entendido")),
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
          _onItemTapped(0);
          return;
        }
        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Presioná de nuevo para salir de Parko'),
              duration: Duration(seconds: 2),
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary.withValues(alpha: 0.5),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Ocupación'),
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
