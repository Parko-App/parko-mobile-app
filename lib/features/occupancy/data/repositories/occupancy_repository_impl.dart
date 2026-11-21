import 'package:flutter/foundation.dart';
import '../../domain/entities/occupancy.dart';
import '../../domain/repositories/occupancy_repository.dart';
import '../datasources/occupancy_remote_datasource.dart';

class OccupancyRepositoryImpl implements OccupancyRepository {
  final OccupancyRemoteDataSource remoteDataSource;

  OccupancyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Occupancy> getSnapshot({required String idToken}) async {
    return await remoteDataSource.getSnapshot(idToken: idToken);
  }

  @override
  Stream<Occupancy> watchStream({
    required String idToken,
    required VoidCallback onHeartbeat,
  }) {
    return remoteDataSource.watchStream(
      idToken: idToken,
      onHeartbeat: onHeartbeat,
    );
  }

  @override
  Future<Occupancy> getOccupancy({String? token}) async {
    if (token != null && token.isNotEmpty) {
      return await getSnapshot(idToken: token);
    }
    return Occupancy(
      occupied: 42,
      capacity: 100,
      available: 58,
      lastUpdated: DateTime.now(),
    );
  }
}
