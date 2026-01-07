import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../auth/presentation/providers/auth_token_provider.dart';

final usuariosResumenProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final session = ref.read(authSessionProvider);
  final token = session.token;

  if (token == null || token.trim().isEmpty) {
    throw Exception("Sesión expirada");
  }

  final resp = await DioClient.dio.get(
    "/api/usuario",
    options: Options(headers: {"Authorization": "Bearer $token"}),
  );
  final dynamic raw = resp.data is String ? jsonDecode(resp.data) : resp.data;
  final dynamic data = (raw is Map<String, dynamic>) ? raw["data"] : raw;

  final body = resp.data;
  if (body is Map<String, dynamic>) return body;

  throw Exception("Respuesta inválida del servidor.");
});
