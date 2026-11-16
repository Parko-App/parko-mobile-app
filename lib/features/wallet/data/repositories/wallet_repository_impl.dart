import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createTopUpPreference({
    required String uuid,
    required String token,
    required double amount,
  }) async {
    return await remoteDataSource.createTopUpPreference(
      uuid: uuid,
      token: token,
      amount: amount,
    );
  }
}
