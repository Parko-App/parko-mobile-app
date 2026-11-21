import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_config.dart';
import '../models/occupancy_model.dart';

class OccupancyAuthException implements Exception {
  final String message;
  OccupancyAuthException([this.message = "Token vencido o no autorizado (401)"]);
  @override
  String toString() => message;
}

abstract class OccupancyRemoteDataSource {
  Future<OccupancyModel> getSnapshot({required String idToken});
  Stream<OccupancyModel> watchStream({
    required String idToken,
    required VoidCallback onHeartbeat,
  });
  Future<OccupancyModel> getOccupancy({String? token});
}

class OccupancyRemoteDataSourceImpl implements OccupancyRemoteDataSource {
  final http.Client client;

  OccupancyRemoteDataSourceImpl({required this.client});

  @override
  Future<OccupancyModel> getSnapshot({required String idToken}) async {
    final url = Uri.parse(ApiConfig.getOccupancySnapshot());

    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return OccupancyModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw OccupancyAuthException();
      } else {
        throw Exception('Error al obtener snapshot de ocupación (${response.statusCode})');
      }
    } catch (e) {
      if (e is OccupancyAuthException) rethrow;
      if (e is Exception) rethrow;
      throw Exception('Error de conexión al obtener snapshot de ocupación');
    }
  }

  @override
  Future<OccupancyModel> getOccupancy({String? token}) async {
    if (token != null && token.isNotEmpty) {
      return await getSnapshot(idToken: token);
    }
    return OccupancyModel(
      occupied: 42,
      capacity: 100,
      available: 58,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Stream<OccupancyModel> watchStream({
    required String idToken,
    required VoidCallback onHeartbeat,
  }) {
    final controller = StreamController<OccupancyModel>();
    http.StreamedResponse? streamedResponse;

    void startStream() async {
      try {
        final url = Uri.parse(ApiConfig.getOccupancyStream());
        final request = http.Request('GET', url);
        request.headers['Accept'] = 'text/event-stream';
        request.headers['Authorization'] = 'Bearer $idToken';

        streamedResponse = await client.send(request);

        if (streamedResponse!.statusCode == 401) {
          controller.addError(OccupancyAuthException());
          await controller.close();
          return;
        }

        if (streamedResponse!.statusCode != 200) {
          controller.addError(
            Exception('Error al conectar SSE stream (${streamedResponse!.statusCode})'),
          );
          await controller.close();
          return;
        }

        streamedResponse!.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (line) {
            final trimmed = line.trim();

            // Heartbeat: comentario SSE (empieza con ':')
            if (trimmed.startsWith(':')) {
              onHeartbeat();
              return;
            }

            if (trimmed.startsWith('data:')) {
              final dataStr = trimmed.substring(5).trim();
              if (dataStr.isEmpty) return;

              try {
                final json = jsonDecode(dataStr);
                if (json is Map<String, dynamic>) {
                  final model = OccupancyModel.fromJson(json);
                  if (!controller.isClosed) {
                    controller.add(model);
                  }
                  onHeartbeat();
                }
              } catch (_) {}
            }
          },
          onError: (error) {
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
          cancelOnError: true,
        );
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
          controller.close();
        }
      }
    }

    startStream();

    controller.onCancel = () {};

    return controller.stream;
  }
}
