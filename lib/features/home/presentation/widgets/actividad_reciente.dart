import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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

              final double heightProgress = (progress / 0.5).clamp(0.0, 1.0);
              final double heightFactor = Curves.easeOutCubic.transform(heightProgress);

              final double slideProgress = ((progress - 0.1) / 0.6).clamp(0.0, 1.0);
              final double slideX = (1.0 - Curves.easeOutCubic.transform(slideProgress)) * 140.0;

              final double opacityProgress = ((progress - 0.1) / 0.5).clamp(0.0, 1.0);
              final double opacity = Curves.easeOut.transform(opacityProgress);

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
    final authState = context.watch<AuthCubit>().state;
    final double userBalance = (authState is Authenticated) ? (authState.user.balance ?? 0.0) : 0.0;
    final bool hasEnoughBalance = userBalance >= tx.amount;

    Color statusColor;
    IconData iconData;

    if (tx.isPending) {
      statusColor = hasEnoughBalance ? Colors.amber.shade800 : Colors.orange.shade800;
      iconData = Icons.pending_outlined;
    } else if (tx.isFailed) {
      statusColor = AppColors.error;
      iconData = Icons.error_outline_rounded;
    } else {
      statusColor = isExpense ? AppColors.error : AppColors.success;
      iconData = isExpense ? Icons.directions_car_filled_outlined : Icons.add_card_outlined;
    }

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
            color: borderColor ?? (tx.isPending ? Colors.orange.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05)),
            width: borderColor != null ? 1.5 : (tx.isPending ? 1.2 : 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "${tx.date} • ${tx.time}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (!tx.isCompleted) ...[
                            const SizedBox(width: 8),
                            Flexible(child: _buildBadge(tx, hasEnoughBalance)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${isExpense ? '-' : '+'} \$ ${tx.amount.toStringAsFixed(0)}",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: tx.isFailed
                        ? AppColors.textSecondary
                        : (tx.isPending ? statusColor : statusColor),
                    decoration: tx.isFailed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
            if (tx.isPending && isExpense) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasEnoughBalance ? const Color(0xFFE8F5E9) : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasEnoughBalance ? const Color(0xFFA5D6A7) : Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasEnoughBalance ? Icons.info_outline : Icons.warning_amber_rounded,
                      size: 15,
                      color: hasEnoughBalance ? const Color(0xFF2E7D32) : Colors.orange.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasEnoughBalance
                            ? "A la salida se cobrará el estacionamiento."
                            : "Cargá saldo para poder pagar.",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: hasEnoughBalance ? const Color(0xFF2E7D32) : Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Transaction tx, bool hasEnoughBalance) {
    if (tx.isPending) {
      final String label = tx.type == TransactionType.income
          ? (hasEnoughBalance ? "Pendiente de cobro" : "Saldo insuficiente")
          : "Acreditación pendiente";
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: hasEnoughBalance ? Colors.blue.shade50 : Colors.orange.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: hasEnoughBalance ? AppColors.primary : Colors.orange.shade900,
          ),
        ),
      );
    } else if (tx.isFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          "Carga fallida",
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error),
        ),
      );
    }
    return const SizedBox.shrink();
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
            child: _buildTransactionTileContent(context),
          ),
        );
      },
    );
  }

  Widget _buildTransactionTileContent(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final double userBalance = (authState is Authenticated) ? (authState.user.balance ?? 0.0) : 0.0;
    final bool hasEnoughBalance = userBalance >= tx.amount;

    Color statusColor;
    IconData iconData;

    if (tx.isPending) {
      statusColor = hasEnoughBalance ? Colors.amber.shade800 : Colors.orange.shade800;
      iconData = Icons.pending_outlined;
    } else if (tx.isFailed) {
      statusColor = AppColors.error;
      iconData = Icons.error_outline_rounded;
    } else {
      statusColor = isExpense ? AppColors.error : AppColors.success;
      iconData = isExpense ? Icons.directions_car_filled_outlined : Icons.add_card_outlined;
    }

    return InkWell(
      onTap: () => showTransactionDetail(context, tx),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: tx.isPending ? Colors.orange.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            width: tx.isPending ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "${tx.date} • ${tx.time}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (!tx.isCompleted) ...[
                            const SizedBox(width: 8),
                            Flexible(child: _buildBadge(tx, hasEnoughBalance)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${isExpense ? '-' : '+'} \$ ${tx.amount.toStringAsFixed(0)}",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: tx.isFailed
                        ? AppColors.textSecondary
                        : (tx.isPending ? statusColor : statusColor),
                    decoration: tx.isFailed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
            if (tx.isPending && isExpense) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasEnoughBalance ? const Color(0xFFE8F5E9) : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasEnoughBalance ? const Color(0xFFA5D6A7) : Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasEnoughBalance ? Icons.info_outline : Icons.warning_amber_rounded,
                      size: 15,
                      color: hasEnoughBalance ? const Color(0xFF2E7D32) : Colors.orange.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasEnoughBalance
                            ? "A la salida se cobrará el estacionamiento."
                            : "Cargá saldo para poder pagar.",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: hasEnoughBalance ? const Color(0xFF2E7D32) : Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Transaction tx, bool hasEnoughBalance) {
    if (tx.isPending) {
      final String label = tx.type == TransactionType.income
          ? (hasEnoughBalance ? "Pendiente de cobro" : "Saldo insuficiente")
          : "Acreditación pendiente";
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: hasEnoughBalance ? Colors.blue.shade50 : Colors.orange.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: hasEnoughBalance ? AppColors.primary : Colors.orange.shade900,
          ),
        ),
      );
    } else if (tx.isFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          "Carga fallida",
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
