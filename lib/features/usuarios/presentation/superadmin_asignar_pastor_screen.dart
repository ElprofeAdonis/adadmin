import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_token_provider.dart';
import '../../pastores/presentation/providers/catalog_providers.dart';
import '../../../core/network/dio_client.dart';

class SuperAdminAsignarPastorScreen extends ConsumerStatefulWidget {
  const SuperAdminAsignarPastorScreen({super.key});

  @override
  ConsumerState<SuperAdminAsignarPastorScreen> createState() =>
      _SuperAdminAsignarPastorScreenState();
}

class _SuperAdminAsignarPastorScreenState
    extends ConsumerState<SuperAdminAsignarPastorScreen> {
  String? _asociacionId;
  String? _distritoId;

  bool _saving = false;

  List<Map<String, dynamic>> _filtrarDistritos(
    List<Map<String, dynamic>> distritos,
    String? asociacionId,
  ) {
    if (asociacionId == null || asociacionId.isEmpty) return [];
    return distritos
        .where((d) => (d["asociacionId"]?.toString() ?? "") == asociacionId)
        .toList();
  }

  Future<void> _crearYAsignarPastor({
    required String usuarioId,
    required String distritoId,
  }) async {
    final session = ref.read(authSessionProvider);
    final token = session.token;

    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesión expirada. Inicia sesión otra vez."),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      String pastorId = "";

      // 1) Intentar CREAR el Pastor
      try {
        final crearResp = await DioClient.dio.post(
          "/api/pastor",
          data: {
            "usuarioId": usuarioId,
            "licenciaPastoral": null,
            "fechaOrdenacion": null,
            "asociacionId": null,
            "distritoId": null,
          },
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );

        pastorId = crearResp.data?["data"]?["id"]?.toString() ?? "";
      } on DioException catch (e) {
        final backendMsg = e.response?.data is Map
            ? (e.response?.data["message"]?.toString() ?? "")
            : "";

        // Si ya existe, entonces lo buscamos por usuarioId
        if (backendMsg.contains("Ya existe un pastor asociado")) {
          final getResp = await DioClient.dio.get(
            "/api/pastor/by-usuario/$usuarioId",
            options: Options(headers: {"Authorization": "Bearer $token"}),
          );
          pastorId = getResp.data?["data"]?["id"]?.toString() ?? "";
        } else {
          rethrow; // otro error real
        }
      }

      if (pastorId.isEmpty) {
        throw Exception("No se pudo obtener pastorId (crear o buscar).");
      }

      // 2) Asignar distrito
      await DioClient.dio.post(
        "/api/pastor/asignar",
        data: {"usuarioId": usuarioId, "distritoId": distritoId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Pastor asignado correctamente")),
      );

      Navigator.pop(context, true);
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response?.data["message"] != null)
          ? e.response?.data["message"].toString()
          : "Error al crear/asignar pastor";
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $msg")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // ⚠️ Ideal: que aquí venga el pastorId (id del modelo Pastor)
    final usuarioId = args?["usuarioId"]?.toString() ?? "";

    final nombre = args?["nombre"]?.toString() ?? "";
    final apellidos = args?["apellidos"]?.toString() ?? "";
    final codigoUnico = args?["codigoUnico"]?.toString() ?? "";

    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Asignar Pastor")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: catalogAsync.when(
          data: (catalog) {
            final asociaciones = catalog.asociaciones;
            final distritosFiltrados = _filtrarDistritos(
              catalog.distritos,
              _asociacionId,
            );

            return ListView(
              children: [
                // Header
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(
                      "$nombre $apellidos".trim().isEmpty
                          ? "Pastor"
                          : "$nombre $apellidos",
                    ),
                    subtitle: Text(
                      codigoUnico.isEmpty ? "" : "Código: $codigoUnico",
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Asociación
                DropdownButtonFormField<String>(
                  value: _asociacionId,
                  decoration: const InputDecoration(
                    labelText: "Asociación",
                    border: OutlineInputBorder(),
                  ),
                  items: asociaciones.map((a) {
                    final id = a["id"]?.toString() ?? "";
                    final n = a["nombre"]?.toString() ?? "Sin nombre";
                    return DropdownMenuItem(value: id, child: Text(n));
                  }).toList(),
                  onChanged: (id) {
                    setState(() {
                      _asociacionId = id;
                      _distritoId = null; // reset
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Distrito (filtrado)
                DropdownButtonFormField<String>(
                  value: _distritoId,
                  decoration: const InputDecoration(
                    labelText: "Distrito",
                    border: OutlineInputBorder(),
                  ),
                  items: distritosFiltrados.map((d) {
                    final id = d["id"]?.toString() ?? "";
                    final n = d["nombre"]?.toString() ?? "Sin nombre";
                    return DropdownMenuItem(value: id, child: Text(n));
                  }).toList(),
                  onChanged: (_asociacionId == null)
                      ? null
                      : (id) => setState(() => _distritoId = id),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving
                        ? null
                        : () {
                            if (usuarioId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Falta usuarioId "),
                                ),
                              );
                              return;
                            }
                            if (_asociacionId == null ||
                                _asociacionId!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Selecciona una asociación."),
                                ),
                              );
                              return;
                            }
                            if (_distritoId == null || _distritoId!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Selecciona un distrito."),
                                ),
                              );
                              return;
                            }

                            _crearYAsignarPastor(
                              usuarioId: usuarioId,
                              distritoId: _distritoId!,
                            );
                          },
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Asignar"),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error cargando catálogo: $e")),
        ),
      ),
    );
  }
}
