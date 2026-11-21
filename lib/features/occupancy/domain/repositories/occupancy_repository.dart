import 'package:flutter/foundation.dart';
import '../entities/occupancy.dart';

abstract class OccupancyRepository {
  Future<Occupancy> getSnapshot({required String idToken});
  Stream<Occupancy> watchStream({
    required String idToken,
    required VoidCallback onHeartbeat,
  });

  Future<Occupancy> getOccupancy({String? token});
}
