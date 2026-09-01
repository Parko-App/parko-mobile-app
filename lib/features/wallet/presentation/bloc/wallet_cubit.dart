import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _walletRepository;
  final firebase.FirebaseAuth _firebaseAuth;

  WalletCubit({
    required WalletRepository walletRepository,
    firebase.FirebaseAuth? firebaseAuth,
  })  : _walletRepository = walletRepository,
        _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        super(WalletInitial());

  Future<void> prepareTopUp(String uuid, double amount) async {
    if (amount <= 0) {
      emit(const WalletError("El monto debe ser mayor a 0"));
      return;
    }

    emit(WalletLoading());

    try {
      final user = _firebaseAuth.currentUser;
      final token = await user?.getIdToken();

      if (user == null || token == null) {
        throw Exception("Sesión no válida");
      }

      final initPoint = await _walletRepository.createTopUpPreference(
        uuid: uuid,
        token: token,
        amount: amount,
      );

      emit(WalletSuccess(initPoint));
    } catch (e) {
      emit(WalletError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
