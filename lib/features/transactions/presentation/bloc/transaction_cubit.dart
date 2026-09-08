import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _transactionRepository;
  final firebase.FirebaseAuth _firebaseAuth;
  Timer? _pollingTimer;

  TransactionCubit({
    required TransactionRepository transactionRepository,
    firebase.FirebaseAuth? firebaseAuth,
  })  : _transactionRepository = transactionRepository,
        _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        super(TransactionState(
          selectedMonth: DateTime.now().month,
          selectedYear: DateTime.now().year,
        ));

  /// Inicia el polling cada 5 segundos. [onTick] permite enganchar refrescos
  /// adicionales (ej. balance) a la misma cadencia sin abrir un timer aparte.
  void startPolling(String userId, {void Function()? onTick}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshAll(userId);
      onTick?.call();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _refreshAll(String userId) async {
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken();
      if (token == null) return;

      // Se disparan juntas para que corran en paralelo; se esperan por separado
      // porque devuelven tipos distintos (List<Transaction> vs TransactionPage).
      final recentFuture = _transactionRepository.getRecentTransactions(userId, token);
      final monthlyFuture = _transactionRepository.getMonthlyTransactions(
        userId,
        token,
        state.selectedMonth,
        state.selectedYear,
        page: state.monthlyPage,
      );

      final recent = await recentFuture;
      final monthly = await monthlyFuture;

      if (!isClosed) {
        emit(state.copyWith(
          recentTransactions: recent,
          monthlyTransactions: monthly.items,
          monthlyPage: monthly.page,
          monthlyTotalPages: monthly.totalPages,
          isLoadingRecent: false,
          isLoadingMonthly: false,
        ));
      }
    } catch (_) {
    }
  }

  Future<void> fetchRecentTransactions(String userId) async {
    emit(state.copyWith(isLoadingRecent: true, errorMessage: null));
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken();
      if (token == null) throw Exception("Sesión expirada");

      final transactions = await _transactionRepository.getRecentTransactions(userId, token);

      emit(state.copyWith(
        recentTransactions: transactions,
        isLoadingRecent: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingRecent: false, errorMessage: e.toString()));
    }
  }

  Future<void> fetchMonthlyTransactions(String userId, int month, int year, {int page = 0}) async {
    emit(state.copyWith(
      isLoadingMonthly: true,
      selectedMonth: month,
      selectedYear: year,
      errorMessage: null,
    ));
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken();
      if (token == null) throw Exception("Sesión expirada");

      final result = await _transactionRepository.getMonthlyTransactions(userId, token, month, year, page: page);

      emit(state.copyWith(
        monthlyTransactions: result.items,
        monthlyPage: result.page,
        monthlyTotalPages: result.totalPages,
        isLoadingMonthly: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMonthly: false, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
