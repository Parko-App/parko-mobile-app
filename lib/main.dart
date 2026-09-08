import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import 'features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'features/vehicles/domain/repositories/vehicle_repository.dart';
import 'features/vehicles/presentation/bloc/vehicles_cubit.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';
import 'features/home/presentation/bloc/home_cubit.dart';
import 'features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';
import 'features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/presentation/bloc/transaction_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ParkoApp());
}

class ParkoApp extends StatelessWidget {
  const ParkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();
    
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(client: httpClient),
    );
    final vehicleRepository = VehicleRepositoryImpl(
      remoteDataSource: VehicleRemoteDataSourceImpl(client: httpClient),
    );
    final walletRepository = WalletRepositoryImpl(
      remoteDataSource: WalletRemoteDataSourceImpl(client: httpClient),
    );
    final transactionRepository = TransactionRepositoryImpl(
      remoteDataSource: TransactionRemoteDataSourceImpl(client: httpClient),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => authRepository),
        RepositoryProvider<VehicleRepository>(create: (_) => vehicleRepository),
        RepositoryProvider<WalletRepository>(create: (_) => walletRepository),
        RepositoryProvider<TransactionRepository>(create: (_) => transactionRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(authRepository: authRepository)..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) => VehiclesCubit(vehicleRepository: vehicleRepository),
          ),
          BlocProvider(
            create: (context) => HomeCubit(),
          ),
          BlocProvider(
            create: (context) => TransactionCubit(transactionRepository: transactionRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Parko',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return const MainNavigationScreen();
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
