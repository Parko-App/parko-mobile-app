import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _transactionRepository;
  final firebase.FirebaseAuth _firebaseAuth;

  TransactionCubit({
    required TransactionRepository transactionRepository,
    firebase.FirebaseAuth? firebaseAuth,
  })  : _transactionRepository = transactionRepository,
        _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        super(TransactionState(
          selectedMonth: DateTime.now().month,
          selectedYear: DateTime.now().year,
        ));

  /// Trae los últimos 5 movimientos para la Home
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

  /// Trae todos los movimientos de un mes específico para el Historial
  Future<void> fetchMonthlyTransactions(String userId, int month, int year) async {
    emit(state.copyWith(
      isLoadingMonthly: true, 
      selectedMonth: month, 
      selectedYear: year,
      errorMessage: null,
    ));
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken();
      if (token == null) throw Exception("Sesión expirada");

      final transactions = await _transactionRepository.getMonthlyTransactions(userId, token, month, year);
      
      emit(state.copyWith(
        monthlyTransactions: transactions,
        isLoadingMonthly: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMonthly: false, errorMessage: e.toString()));
    }
  }
}
