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
import 'features/home/presentation/screens/home_screen.dart';
import 'features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import 'features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'features/vehicles/domain/repositories/vehicle_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await FirebaseAuth.instance.signOut(); // forzar login si ya habia una sesion abierta
  runApp(const ParkoApp());
}

class ParkoApp extends StatelessWidget {
  const ParkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();
    
    // Instanciamos los repositorios
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(client: httpClient),
    );
    final vehicleRepository = VehicleRepositoryImpl(
      remoteDataSource: VehicleRemoteDataSourceImpl(client: httpClient),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => authRepository),
        RepositoryProvider<VehicleRepository>(create: (_) => vehicleRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(authRepository: authRepository)..checkAuthStatus(),
        child: MaterialApp(
          title: 'Parko',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
