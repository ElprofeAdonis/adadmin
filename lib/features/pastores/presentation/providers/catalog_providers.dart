import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/catalog_service.dart';
import '../../../auth/presentation/providers/auth_token_provider.dart';

final catalogServiceProvider = Provider((ref) => CatalogService());

class CatalogData {
  final List<Map<String, dynamic>> asociaciones;
  final List<Map<String, dynamic>> distritos;

  CatalogData({required this.asociaciones, required this.distritos});
}

final catalogProvider = FutureProvider<CatalogData>((ref) async {
  final session = ref.read(authSessionProvider);
  final token = session.token;

  if (token == null || token.trim().isEmpty) {
    return CatalogData(asociaciones: [], distritos: []);
  }

  final service = ref.read(catalogServiceProvider);
  final asociaciones = await service.getAsociaciones(token);
  final distritos = await service.getDistritos(token);

  return CatalogData(asociaciones: asociaciones, distritos: distritos);
});
