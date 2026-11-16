import 'package:equatable/equatable.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}
class WalletLoading extends WalletState {}
class WalletSuccess extends WalletState {
  final String initPoint; // URL de Mercado Pago
  const WalletSuccess(this.initPoint);
  @override
  List<Object?> get props => [initPoint];
}
class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object?> get props => [message];
}
