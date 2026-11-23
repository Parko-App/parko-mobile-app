import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/screens/history_screen.dart';
import '../widgets/patentes_list.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicles/presentation/bloc/vehicles_cubit.dart';
import '../../../vehicles/presentation/bloc/vehicles_state.dart';
import '../../../vehicles/presentation/screens/my_vehicles_screen.dart';
import '../../../wallet/presentation/screens/top_up_screen.dart';
import '../../../transactions/presentation/bloc/transaction_cubit.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../bloc/home_cubit.dart';
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
                  builder: (context, authState) {
                    double balance = 0;
                    if (authState is Authenticated) balance = authState.user.balance ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BalanceCard(
                          balance: balance,
                          onTopUp: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TopUpScreen(initialBalance: balance),
                              ),
                            );
                          },
                        ),
                        BlocBuilder<TransactionCubit, TransactionState>(
                          builder: (context, txState) {
                            final pendingIndex = txState.recentTransactions.indexWhere(
                              (tx) => tx.type == TransactionType.income && tx.isPending,
                            );
                            if (pendingIndex != -1) {
                              final pendingTx = txState.recentTransactions[pendingIndex];
                              return _buildPendingParkingWarning(context, balance, pendingTx.amount);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),
                _buildPatentesHeader(),
                const SizedBox(height: 12),

                BlocBuilder<VehiclesCubit, VehiclesState>(
                  builder: (context, state) {
                    return PatentesList(
                      vehicles: state.vehicles,
                      isLoading: state is VehiclesLoading,
                    );
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

  Widget _buildPendingParkingWarning(BuildContext context, double balance, double pendingAmount) {
    final bool hasEnoughBalance = balance >= pendingAmount;

    final Color bgColor = hasEnoughBalance ? const Color(0xFFE8F5E9) : Colors.amber.shade50;
    final Color borderColor = hasEnoughBalance ? const Color(0xFFA5D6A7) : Colors.amber.shade300;
    final Color iconBgColor = hasEnoughBalance ? const Color(0xFFC8E6C9) : Colors.amber.shade100;
    final Color textColor = hasEnoughBalance ? const Color(0xFF2E7D32) : Colors.amber.shade900;
    final IconData icon = hasEnoughBalance ? Icons.info_outline_rounded : Icons.warning_amber_rounded;

    final String message = hasEnoughBalance
        ? "A la salida se cobrará el estacionamiento."
        : "Cargá saldo para poder pagar.";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Estacionamiento pendiente",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (!hasEnoughBalance) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopUpScreen(initialBalance: balance),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Cargar",
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ],
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
