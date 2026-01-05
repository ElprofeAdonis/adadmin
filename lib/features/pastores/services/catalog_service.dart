import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class CatalogService {
  Future<List<Map<String, dynamic>>> getAsociaciones(String token) async {
    final resp = await DioClient.dio.get(
      "/api/asociacion/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (resp.data is List) {
      return List<Map<String, dynamic>>.from(resp.data as List);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getDistritos(String token) async {
    final resp = await DioClient.dio.get(
      "/api/distrito/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (resp.data is List) {
      return List<Map<String, dynamic>>.from(resp.data as List);
    }
    return [];
  }
}
