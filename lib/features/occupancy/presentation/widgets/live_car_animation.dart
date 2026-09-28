import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';


class LiveCarAnimation extends StatefulWidget {
  final int count;

  const LiveCarAnimation({super.key, required this.count});

  @override
  State<LiveCarAnimation> createState() => _LiveCarAnimationState();
}

class _LiveCarAnimationState extends State<LiveCarAnimation>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 2000);

  late final AnimationController _controller;
  bool _isArriving = true;
  bool _isVisible = false;
  int? _lastCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animationDuration);
    // Sincronizamos la cantidad inicial sin reproducir ninguna animación
    _lastCount = widget.count;
  }

  @override
  void didUpdateWidget(LiveCarAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_lastCount == null) {
      _lastCount = widget.count;
      return;
    }

    if (widget.count == _lastCount) return;

    final arriving = widget.count > _lastCount!;
    _lastCount = widget.count;

    _triggerAnimation(arriving);
  }

  void _triggerAnimation(bool arriving) async {
    if (!mounted) return;

    if (_controller.isAnimating) {
      _controller.stop();
    }

    setState(() {
      _isArriving = arriving;
      _isVisible = true;
    });

    try {
      await _controller.forward(from: 0);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final Color themeColor = _isArriving ? AppColors.error : AppColors.success;
    final String statusText = _isArriving ? "Llegó un auto" : "Se fue un auto";

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        final double dx = _calculateHorizontalDisplacement(t, _isArriving);
        final double opacity = _calculateOpacity(t);
        final double badgeScale = _calculateBadgeScale(t);

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -46,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: badgeScale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: GoogleFonts.nunito(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Auto Azul animado
            Transform.translate(
              offset: Offset(dx, 0.0),
              child: Opacity(
                opacity: opacity,
                child: _buildBlueCar(_isArriving, t),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateHorizontalDisplacement(double t, bool isArriving) {
    if (isArriving) {
      final curved = Curves.easeOutCubic.transform(t);
      return -145.0 + (145.0 * curved);
    } else {
      final curved = Curves.easeInCubic.transform(t);
      return 145.0 * curved;
    }
  }

  double _calculateOpacity(double t) {
    if (t < 0.12) return t / 0.12;
    if (t > 0.88) return (1.0 - t) / 0.12;
    return 1.0;
  }

  double _calculateBadgeScale(double t) {
    if (t < 0.2) return 0.8 + (t / 0.2) * 0.2;
    if (t > 0.8) return 1.0 - ((t - 0.8) / 0.2) * 0.1;
    return 1.0;
  }

  Widget _buildBlueCar(bool isArriving, double t) {
    const Color carBodyColor = AppColors.primary;
    
    final bool isBraking = isArriving && t > 0.4;
    final Color tailLightColor = isBraking
        ? const Color(0xFFFF1744)
        : const Color(0xFFD32F2F);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Sombra proyectada
        Positioned(
          bottom: -5,
          child: Container(
            width: 44,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Haz de luz de los faros delanteros
        Positioned(
          right: -16,
          child: Container(
            width: 20,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFFFF59D).withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Cuerpo azul del auto
        Container(
          width: 46,
          height: 26,
          decoration: BoxDecoration(
            color: carBodyColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Stack(
            children: [
              // Techo / Parabrisas
              Center(
                child: Container(
                  width: 22,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Faros delanteros
              Positioned(
                right: 2,
                top: 3,
                bottom: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 3, height: 4, color: const Color(0xFFFFF59D)),
                    Container(width: 3, height: 4, color: const Color(0xFFFFF59D)),
                  ],
                ),
              ),

              // Faros traseros / Luz de freno
              Positioned(
                left: 2,
                top: 3,
                bottom: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 3,
                      height: 4,
                      decoration: BoxDecoration(
                        color: tailLightColor,
                        boxShadow: isBraking
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF1744).withValues(alpha: 0.9),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 4,
                      decoration: BoxDecoration(
                        color: tailLightColor,
                        boxShadow: isBraking
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF1744).withValues(alpha: 0.9),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
