import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/occupancy.dart';
import '../bloc/occupancy_cubit.dart';
import '../bloc/occupancy_state.dart';
import '../widgets/occupancy_chart.dart';
import '../widgets/live_car_animation.dart';

class OccupancyScreen extends StatefulWidget {
  const OccupancyScreen({super.key});

  @override
  State<OccupancyScreen> createState() => _OccupancyScreenState();
}

class _OccupancyScreenState extends State<OccupancyScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final cubit = context.read<OccupancyCubit>();
    cubit.startStream();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<OccupancyCubit>().stopStream();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final cubit = context.read<OccupancyCubit>();

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      cubit.stopStream();
    } else if (state == AppLifecycleState.resumed) {
      cubit.startStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Ocupación",
          style: GoogleFonts.nunito(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<OccupancyCubit, OccupancyState>(
        builder: (context, state) {
          if (state is OccupancyLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is OccupancyError) {
            return _buildElegantErrorView(context, state.message);
          }

          if (state is OccupancyLoaded) {
            final occupancy = state.occupancy;
            return RefreshIndicator(
              onRefresh: () => context.read<OccupancyCubit>().startStream(forceTokenRefresh: true),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildMainCard(
                      occupancy,
                      state.isLive,
                      state.isRefreshing,
                      state.isStale,
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        OccupancyChart(occupancy: occupancy),
                        LiveCarAnimation(count: occupancy.currentOccupancy),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildForecastSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildElegantErrorView(BuildContext context, String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.error,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Sin conexión con el estacionamiento",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.read<OccupancyCubit>().startStream(forceTokenRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                "Reintentar conexión",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(
    Occupancy occupancy,
    bool isLive,
    bool isRefreshing,
    bool isStale,
  ) {
    final String hourStr = occupancy.lastUpdated.hour.toString().padLeft(2, '0');
    final String minuteStr = occupancy.lastUpdated.minute.toString().padLeft(2, '0');
    final String lastUpdatedFormatted = "$hourStr:$minuteStr";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF062161)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Lugares disponibles ahora",
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildLiveBadge(isLive, isRefreshing, isStale),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${occupancy.availableSpaces}",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 68,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        "/${occupancy.totalCapacity}",
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isLive
                        ? "Actualizado en vivo (SSE)"
                        : "Sin conexión — Última lectura a las $lastUpdatedFormatted hs",
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: isLive ? 0.7 : 0.85),
                      fontSize: 12,
                      fontWeight: isLive ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBadge(bool isLive, bool isRefreshing, bool isStale) {
    if (isRefreshing && !isStale) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1),
        ),
        child: Text(
          "Actualizando...",
          style: GoogleFonts.inter(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      );
    }

    if (isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF00E676).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF00E676),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "En vivo",
              style: GoogleFonts.inter(color: const Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    if (isStale) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "Desconectado",
              style: GoogleFonts.inter(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ocupación estimada",
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Buen momento para llegar — hora pico estimada en 40 min",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
