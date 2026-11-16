import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/transaction_cubit.dart';
import '../bloc/transaction_state.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/transaction_detail_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadTransactions();
  }

  void _loadTransactions({int page = 0}) {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<TransactionCubit>().fetchMonthlyTransactions(
        authState.user.id,
        _selectedMonth,
        _selectedYear,
        page: page,
      );
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
          "Mi Actividad",
          style: GoogleFonts.nunito(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: Navigator.of(context).canPop() 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state.isLoadingMonthly) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (state.errorMessage != null && state.monthlyTransactions.isEmpty) {
                  return Center(child: Text(state.errorMessage!));
                }

                return Column(
                  children: [
                    Expanded(
                      child: _TransactionListView(
                        key: ValueKey("history_${state.selectedMonth}_${state.selectedYear}_${state.monthlyPage}"),
                        transactions: state.monthlyTransactions,
                      ),
                    ),
                    _buildPager(state),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Filtrar por mes",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(_months[index]),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMonth = value;
                    });
                    _loadTransactions();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPager(TransactionState state) {
    if (state.monthlyTotalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.primary,
            onPressed: state.monthlyPage > 0 ? () => _loadTransactions(page: state.monthlyPage - 1) : null,
          ),
          Text(
            "Página ${state.monthlyPage + 1} de ${state.monthlyTotalPages}",
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.primary,
            onPressed: state.monthlyPage + 1 < state.monthlyTotalPages
                ? () => _loadTransactions(page: state.monthlyPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _TransactionListView extends StatefulWidget {
  final List<Transaction> transactions;

  const _TransactionListView({super.key, required this.transactions});

  @override
  State<_TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<_TransactionListView>
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
    if (widget.transactions.isNotEmpty) {
      _newestTxId = widget.transactions.first.id;
    }
  }

  @override
  void didUpdateWidget(_TransactionListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isInitialLoad = false;

    if (widget.transactions.isNotEmpty) {
      final currentTopId = widget.transactions.first.id;
      if (oldWidget.transactions.isNotEmpty &&
          oldWidget.transactions.first.id != currentTopId) {
        setState(() {
          _newestTxId = currentTopId;
        });
        _newItemController.forward(from: 0);
      } else if (oldWidget.transactions.isEmpty && widget.transactions.isNotEmpty) {
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
    if (widget.transactions.isEmpty) {
      return Center(
        child: Text(
          "No hay movimientos en este mes",
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: widget.transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = widget.transactions[index];
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
            delayMs: index * 50,
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
