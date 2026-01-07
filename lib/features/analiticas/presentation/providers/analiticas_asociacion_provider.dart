import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_token_provider.dart';

final analiticasAsociacionProvider =
    FutureProvider.family<Map<String, dynamic>, String>((
      ref,
      asociacionId,
    ) async {
      final session = ref.read(authSessionProvider);
      final token = session.token;

      if (token == null || token.isEmpty) {
        throw Exception("Sesión expirada");
      }

      final resp = await DioClient.dio.get(
        "/api/estadisticas/dashboard-asociacion",
        queryParameters: {"asociacionId": asociacionId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return resp.data as Map<String, dynamic>;
    });
