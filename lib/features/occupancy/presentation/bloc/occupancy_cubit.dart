import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/occupancy_remote_datasource.dart';
import '../../domain/entities/occupancy.dart';
import '../../domain/repositories/occupancy_repository.dart';
import 'occupancy_state.dart';

class OccupancyCubit extends Cubit<OccupancyState> {
  final OccupancyRepository? occupancyRepository;
  final firebase.FirebaseAuth _firebaseAuth;

  StreamSubscription<Occupancy>? _streamSubscription;
  Timer? _watchdogTimer;
  Timer? _retryTimer;
  Timer? _simulationTimer;

  int _backoffSeconds = 1;
  static const int _maxBackoffSeconds = 30;
  static const int _watchdogTimeoutSeconds = 60;

  Occupancy? _lastValidOccupancy;
  int _currentCount = 120;
  bool _isConnecting = false;

  OccupancyCubit({
    this.occupancyRepository,
    firebase.FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        super(OccupancyInitial());

  /// Consulta inicial y conexión al stream en tiempo real (Regla de oro)
  Future<void> fetchOccupancy() async {
    await startStream();
  }

  /// Inicia el flujo: Snapshot REST primero, SSE Stream después
  Future<void> startStream({bool forceTokenRefresh = false}) async {
    if (_isConnecting) return;
    _isConnecting = true;

    _stopAllTimersAndStream(keepData: true);

    // Si ya teníamos una lectura válida anterior en memoria, la preservamos
    if (_lastValidOccupancy != null) {
      emit(OccupancyLoaded(
        _lastValidOccupancy!,
        isLive: false,
        isRefreshing: true,
        isStale: true,
      ));
    } else if (state is OccupancyLoaded) {
      final current = (state as OccupancyLoaded);
      emit(current.copyWith(isRefreshing: true, isStale: true, isLive: false));
    } else {
      emit(OccupancyLoading());
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && occupancyRepository != null) {
        final idToken = await user.getIdToken(forceTokenRefresh);
        if (idToken != null) {
          // 1. REGLA DE ORO: Snapshot REST primero
          try {
            final snapshot = await occupancyRepository!.getSnapshot(idToken: idToken);
            _currentCount = snapshot.currentOccupancy;
            _lastValidOccupancy = snapshot;
            _backoffSeconds = 1;
            emit(OccupancyLoaded(
              snapshot,
              isLive: false,
              isRefreshing: false,
              isStale: false,
            ));
          } catch (e) {
            if (e is OccupancyAuthException) {
              _isConnecting = false;
              _scheduleRetry(forceTokenRefresh: true);
              return;
            }
            if (_lastValidOccupancy == null && state is! OccupancyLoaded) {
              _isConnecting = false;
              emit(const OccupancyError(
                "No pudimos conectar con el servidor de ocupación. Verificá que el servicio esté activo o reintentá nuevamente.",
              ));
              return;
            }
          }

          // 2. REGLA DE ORO: Abrir SSE Stream después
          _startSseSubscription(idToken);
          _backoffSeconds = 1;
          _isConnecting = false;
          return;
        }
      }
    } catch (e) {
      if (e is OccupancyAuthException) {
        _isConnecting = false;
        _scheduleRetry(forceTokenRefresh: true);
        return;
      }
    }

    _isConnecting = false;

    // Si falló la conexión y nunca se cargó un dato válido en memoria, emitimos error
    if (_lastValidOccupancy == null && state is! OccupancyLoaded) {
      emit(const OccupancyError(
        "No pudimos conectar con el servidor de ocupación. Verificá tu conexión a internet o reintentá en unos momentos.",
      ));
    } else {
      _scheduleRetry();
    }
  }

  void _startSseSubscription(String idToken) {
    _resetWatchdog();

    _streamSubscription = occupancyRepository!
        .watchStream(
      idToken: idToken,
      onHeartbeat: _resetWatchdog,
    )
        .listen(
      (occupancy) {
        _resetWatchdog();
        _currentCount = occupancy.currentOccupancy;
        _lastValidOccupancy = occupancy;
        _backoffSeconds = 1;

        emit(OccupancyLoaded(
          occupancy,
          isLive: true,
          isRefreshing: false,
          isStale: false,
        ));
      },
      onError: (error) {
        final isAuthError = error is OccupancyAuthException;
        _scheduleRetry(forceTokenRefresh: isAuthError);
      },
      onDone: () {
        _scheduleRetry();
      },
      cancelOnError: true,
    );
  }

  void _resetWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(const Duration(seconds: _watchdogTimeoutSeconds), () {
      startStream(forceTokenRefresh: false);
    });
  }

  void _scheduleRetry({bool forceTokenRefresh = false}) {
    _stopAllTimersAndStream(keepData: true);

    if (_lastValidOccupancy != null) {
      emit(OccupancyLoaded(
        _lastValidOccupancy!,
        isLive: false,
        isRefreshing: true,
        isStale: true,
      ));
    } else if (state is OccupancyLoaded) {
      emit((state as OccupancyLoaded).copyWith(isLive: false, isRefreshing: true, isStale: true));
    } else {
      emit(const OccupancyError(
        "No pudimos conectar con el servidor de ocupación. Verificá tu conexión o reintentá en unos momentos.",
      ));
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: _backoffSeconds), () {
      _backoffSeconds = min(_backoffSeconds * 2, _maxBackoffSeconds);
      startStream(forceTokenRefresh: forceTokenRefresh);
    });
  }

  void stopStream() {
    _stopAllTimersAndStream(keepData: true);
    if (state is OccupancyLoaded) {
      emit((state as OccupancyLoaded).copyWith(isLive: false, isRefreshing: false));
    }
  }

  void startPolling() => startStream();
  void stopPolling() => stopStream();
  void startSimulation() => startStream();
  void stopSimulation() => stopStream();

  void updateOccupancy(int newCount) {
    _currentCount = newCount;
    final mockOccupancy = Occupancy(
      occupied: _currentCount,
      capacity: 300,
      available: 300 - _currentCount,
      lastUpdated: DateTime.now(),
    );
    _lastValidOccupancy = mockOccupancy;
    emit(OccupancyLoaded(mockOccupancy, isLive: false, isRefreshing: false, isStale: false));
  }

  void _stopAllTimersAndStream({bool keepData = false}) {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  @override
  Future<void> close() {
    _stopAllTimersAndStream(keepData: false);
    return super.close();
  }
}
