import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

class TransactionState extends Equatable {
  final List<Transaction> recentTransactions;
  final List<Transaction> monthlyTransactions;
  final bool isLoadingRecent;
  final bool isLoadingMonthly;
  final int selectedMonth;
  final int selectedYear;
  final int monthlyPage;
  final int monthlyTotalPages;
  final String? errorMessage;

  const TransactionState({
    this.recentTransactions = const [],
    this.monthlyTransactions = const [],
    this.isLoadingRecent = false,
    this.isLoadingMonthly = false,
    this.selectedMonth = 1,
    this.selectedYear = 2026,
    this.monthlyPage = 0,
    this.monthlyTotalPages = 1,
    this.errorMessage,
  });

  TransactionState copyWith({
    List<Transaction>? recentTransactions,
    List<Transaction>? monthlyTransactions,
    bool? isLoadingRecent,
    bool? isLoadingMonthly,
    int? selectedMonth,
    int? selectedYear,
    int? monthlyPage,
    int? monthlyTotalPages,
    String? errorMessage,
  }) {
    return TransactionState(
      recentTransactions: recentTransactions ?? this.recentTransactions,
      monthlyTransactions: monthlyTransactions ?? this.monthlyTransactions,
      isLoadingRecent: isLoadingRecent ?? this.isLoadingRecent,
      isLoadingMonthly: isLoadingMonthly ?? this.isLoadingMonthly,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      monthlyPage: monthlyPage ?? this.monthlyPage,
      monthlyTotalPages: monthlyTotalPages ?? this.monthlyTotalPages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        recentTransactions,
        monthlyTransactions,
        isLoadingRecent,
        isLoadingMonthly,
        selectedMonth,
        selectedYear,
        monthlyPage,
        monthlyTotalPages,
        errorMessage,
      ];
}
