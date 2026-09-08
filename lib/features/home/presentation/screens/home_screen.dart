import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../transactions/presentation/screens/history_screen.dart';
import '../widgets/patentes_list.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicles/presentation/bloc/vehicles_cubit.dart';
import '../../../vehicles/presentation/bloc/vehicles_state.dart';
import '../../../vehicles/presentation/screens/my_vehicles_screen.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../wallet/presentation/screens/top_up_screen.dart';
import '../../../transactions/presentation/bloc/transaction_cubit.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/actividad_reciente.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      await Future.wait([
        context.read<AuthCubit>().refreshProfile(),
        context.read<VehiclesCubit>().fetchVehicles(authState.user.id),
        context.read<TransactionCubit>().fetchRecentTransactions(authState.user.id),
        context.read<HomeCubit>().fetchHomeData(authState.user.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAllData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    double balance = 0;
                    if (state is Authenticated) balance = state.user.balance ?? 0;
                    return BalanceCard(
                      balance: balance,
                      onTopUp: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopUpScreen(initialBalance: balance),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 32),
                _buildPatentesHeader(),
                const SizedBox(height: 12),
                
                BlocBuilder<VehiclesCubit, VehiclesState>(
                  builder: (context, state) {
                    if (state is VehiclesLoaded) {
                      return PatentesList(vehicles: state.vehicles);
                    } else if (state is VehiclesSuccess) {
                      return PatentesList(vehicles: state.vehicles);
                    }
                    return const PatentesList(vehicles: []);
                  },
                ),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Actividad reciente",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                      child: const Text(
                        "Ver todos",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                BlocBuilder<TransactionCubit, TransactionState>(
                  builder: (context, state) {
                    if (state.isLoadingRecent) return const Center(child: CircularProgressIndicator());
                    if (state.errorMessage != null && state.recentTransactions.isEmpty) {
                      return Text(state.errorMessage!);
                    }
                    return ActividadReciente(actividad: state.recentTransactions);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = "Usuario";
        if (state is Authenticated) name = state.user.name;
        final String initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hola,", style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                Text(
                  name,
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
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Center(child: Text(initial, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationBell() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: const Stack(
        children: [
          Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary),
          Positioned(right: 0, top: 0, child: CircleAvatar(radius: 4, backgroundColor: AppColors.error)),
        ],
      ),
    );
  }

  Widget _buildPatentesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Tus patentes", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyVehiclesScreen())),
          child: const Text("Ver todas", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
