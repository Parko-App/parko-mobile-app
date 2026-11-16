import '../../domain/entities/occupancy.dart';
import '../../domain/repositories/occupancy_repository.dart';
import '../datasources/occupancy_remote_datasource.dart';

class OccupancyRepositoryImpl implements OccupancyRepository {
  final OccupancyRemoteDataSource remoteDataSource;

  OccupancyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Occupancy> getOccupancy({String? token}) async {
    return await remoteDataSource.getOccupancy(token: token);
  }
}
