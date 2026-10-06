import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/widgets/transaction_detail_dialog.dart';

class ActividadReciente extends StatefulWidget {
  final List<Transaction> actividad;

  const ActividadReciente({super.key, required this.actividad});

  @override
  State<ActividadReciente> createState() => _ActividadRecienteState();
}

class _ActividadRecienteState extends State<ActividadReciente>
    with SingleTickerProviderStateMixin {
  String? _newestTxId;
  late final AnimationController _newItemController;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _newItemController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.actividad.isNotEmpty) {
      _newestTxId = widget.actividad.first.id;
    }
  }

  @override
  void didUpdateWidget(ActividadReciente oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isInitialLoad = false;

    if (widget.actividad.isNotEmpty) {
      final currentTopId = widget.actividad.first.id;
      if (oldWidget.actividad.isNotEmpty &&
          oldWidget.actividad.first.id != currentTopId) {
        setState(() {
          _newestTxId = currentTopId;
        });
        _newItemController.forward(from: 0);
      } else if (oldWidget.actividad.isEmpty && widget.actividad.isNotEmpty) {
        setState(() {
          _newestTxId = currentTopId;
        });
        _newItemController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actividad.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Todavía no tenés movimientos",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "¡Tus estacionamientos aparecerán acá!",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayCount = widget.actividad.length > 5 ? 5 : widget.actividad.length;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = widget.actividad[index];
        final bool isExpense = tx.type == TransactionType.income;
        final bool isNewestItem = index == 0 && tx.id == _newestTxId;

        if (isNewestItem && _newItemController.isAnimating) {
          return AnimatedBuilder(
            animation: _newItemController,
            builder: (context, child) {
              final progress = _newItemController.value;

              // 1. Expansión vertical segura (garantiza t entre 0.0 y 1.0)
              final double heightProgress = (progress / 0.5).clamp(0.0, 1.0);
              final double heightFactor = Curves.easeOutCubic.transform(heightProgress);

              // 2. Entrada deslizante desde el costado derecho sin exceder rangos
              final double slideProgress = ((progress - 0.1) / 0.6).clamp(0.0, 1.0);
              final double slideX = (1.0 - Curves.easeOutCubic.transform(slideProgress)) * 140.0;

              final double opacityProgress = ((progress - 0.1) / 0.5).clamp(0.0, 1.0);
              final double opacity = Curves.easeOut.transform(opacityProgress);

              // 3. Destello de color
              final Color highlightColor = isExpense ? AppColors.error : AppColors.success;
              final double glowProgress = (1.0 - progress).clamp(0.0, 1.0);
              final Color cardBgColor = Color.lerp(
                Colors.white,
                highlightColor.withValues(alpha: 0.14),
                glowProgress,
              )!;

              return SizeTransition(
                sizeFactor: AlwaysStoppedAnimation(heightFactor),
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(slideX, 0),
                    child: _buildTransactionTile(
                      context,
                      tx: tx,
                      isExpense: isExpense,
                      backgroundColor: cardBgColor,
                      borderColor: Color.lerp(
                        Colors.black.withValues(alpha: 0.05),
                        highlightColor.withValues(alpha: 0.4),
                        glowProgress,
                      )!,
                    ),
                  ),
                ),
              );
            },
          );
        }

        if (_isInitialLoad) {
          return _AnimatedTransactionItem(
            key: ValueKey(tx.id),
            delayMs: index * 60,
            tx: tx,
            isExpense: isExpense,
          );
        }

        return _buildTransactionTile(
          context,
          tx: tx,
          isExpense: isExpense,
        );
      },
    );
  }

  Widget _buildTransactionTile(
    BuildContext context, {
    required Transaction tx,
    required bool isExpense,
    Color backgroundColor = Colors.white,
    Color? borderColor,
  }) {
    return InkWell(
      key: ValueKey(tx.id),
      onTap: () => showTransactionDetail(context, tx),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor ?? Colors.black.withValues(alpha: 0.05),
            width: borderColor != null ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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
                color: (isExpense ? AppColors.error : AppColors.success)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense
                    ? Icons.directions_car_filled_outlined
                    : Icons.add_card_outlined,
                color: isExpense ? AppColors.error : AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "${tx.date} • ${tx.time}",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${isExpense ? '-' : '+'} \$ ${tx.amount}",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isExpense ? AppColors.error : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTransactionItem extends StatelessWidget {
  final int delayMs;
  final Transaction tx;
  final bool isExpense;

  const _AnimatedTransactionItem({
    super.key,
    required this.delayMs,
    required this.tx,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delayMs)),
      builder: (context, snapshot) {
        final bool isReady = snapshot.connectionState == ConnectionState.done;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          opacity: isReady ? 1.0 : 0.0,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(top: isReady ? 0.0 : 12.0),
            child: InkWell(
              onTap: () => showTransactionDetail(context, tx),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
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
                        color: (isExpense ? AppColors.error : AppColors.success)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpense
                            ? Icons.directions_car_filled_outlined
                            : Icons.add_card_outlined,
                        color: isExpense ? AppColors.error : AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            "${tx.date} • ${tx.time}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${isExpense ? '-' : '+'} \$ ${tx.amount}",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isExpense ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
