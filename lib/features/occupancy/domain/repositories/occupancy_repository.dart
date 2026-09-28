import '../entities/occupancy.dart';

abstract class OccupancyRepository {
  Future<Occupancy> getOccupancy({String? token});
}
