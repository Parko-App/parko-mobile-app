import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final VoidCallback? onTopUp;
  final bool showButton;

  const BalanceCard({
    super.key,
    required this.balance,
    this.onTopUp,
    this.showButton = true,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late double _previousBalance;
  double? _diff;
  late final AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _previousBalance = widget.balance;
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void didUpdateWidget(BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      final diff = widget.balance - oldWidget.balance;
      if (diff.abs() > 0.01) {
        setState(() {
          _diff = diff;
          _previousBalance = oldWidget.balance;
        });
        _badgeController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Saldo disponible",
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      if (_diff != null)
                        AnimatedBuilder(
                          animation: _badgeController,
                          builder: (context, child) {
                            final progress = _badgeController.value;
                            if (progress >= 1.0 || !_badgeController.isAnimating) {
                              return const SizedBox.shrink();
                            }
                            final isPositive = _diff! > 0;
                            final String diffText = isPositive
                                ? "+ \$ ${_formatCurrency(_diff!)}"
                                : "- \$ ${_formatCurrency(_diff!.abs())}";
                            final Color badgeBg = isPositive
                                ? const Color(0xFF00E676)
                                : const Color(0xFFFF5252);

                            final double translateY = -10.0 * progress;
                            final double opacity = progress < 0.15
                                ? progress / 0.15
                                : (progress > 0.85
                                    ? (1.0 - progress) / 0.15
                                    : 1.0);

                            return Opacity(
                              opacity: opacity.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, translateY),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: badgeBg.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    diffText,
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _previousBalance,
                      end: widget.balance,
                    ),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return Text(
                        "\$ ${_formatCurrency(animatedValue)}",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    },
                  ),

                  if (widget.showButton) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onTopUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(160, 48),
                        elevation: 0,
                      ),
                      child: const Text('Cargar saldo'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
