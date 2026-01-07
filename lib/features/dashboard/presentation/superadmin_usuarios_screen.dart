import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../usuarios/widgets/usuarios_por_mes_chart.dart'; // ajusta ruta
import '../../usuarios/providers/usuarios_provider.dart';
// 👆 aquí debe estar el provider: usuariosResumenProvider

class SuperAdminUsuariosScreen extends ConsumerStatefulWidget {
  const SuperAdminUsuariosScreen({super.key});

  @override
  ConsumerState<SuperAdminUsuariosScreen> createState() =>
      _SuperAdminUsuariosScreenState();
}

class _SuperAdminUsuariosScreenState
    extends ConsumerState<SuperAdminUsuariosScreen> {
  final _searchCtrl = TextEditingController();
  String _rolFiltro = "TODOS";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtrarUsuarios(
    List<Map<String, dynamic>> users,
  ) {
    final q = _searchCtrl.text.trim().toLowerCase();

    final filtered = users.where((u) {
      final nombre = (u["nombre"] ?? "").toString().toLowerCase();
      final apellidos = (u["apellidos"] ?? "").toString().toLowerCase();
      final email = (u["email"] ?? "").toString().toLowerCase();
      final rol = (u["rol"] ?? "").toString();

      final matchSearch =
          q.isEmpty ||
          nombre.contains(q) ||
          apellidos.contains(q) ||
          email.contains(q);

      final matchRol = _rolFiltro == "TODOS" || rol == _rolFiltro;

      return matchSearch && matchRol;
    }).toList();

    // ✅ opcional: que el más nuevo aparezca arriba
    filtered.sort((a, b) {
      final da = DateTime.tryParse((a["creadoEn"] ?? "").toString());
      final db = DateTime.tryParse((b["creadoEn"] ?? "").toString());
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final asyncBody = ref.watch(usuariosResumenProvider);

    return Scaffold(
      body: asyncBody.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (body) {
          final dataList = (body["data"] as List? ?? []);
          final stats = (body["stats"] as Map<String, dynamic>? ?? {});

          final usuarios = dataList.cast<Map<String, dynamic>>();
          final nuevosPorMes = (stats["nuevosPorMes"] as List? ?? [])
              .cast<Map<String, dynamic>>();

          final usuariosFiltrados = _filtrarUsuarios(usuarios);

          return RefreshIndicator(
            onRefresh: () async {
              // ✅ recargar manual (pull to refresh)
              await ref.refresh(usuariosResumenProvider.future);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 420,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: "Buscar por nombre o email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 420,
                        child: DropdownButtonFormField<String>(
                          value: _rolFiltro,
                          decoration: const InputDecoration(
                            labelText: "Rol",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "TODOS",
                              child: Text("Todos"),
                            ),
                            DropdownMenuItem(
                              value: "SuperADMIN",
                              child: Text("SuperADMIN"),
                            ),
                            DropdownMenuItem(
                              value: "SECRETARIAAsociacion",
                              child: Text("Secret. Asociación"),
                            ),
                            DropdownMenuItem(
                              value: "SECRETARIAIglesia",
                              child: Text("Secret. Iglesia"),
                            ),
                            DropdownMenuItem(
                              value: "PASTOR",
                              child: Text("Pastor"),
                            ),
                            DropdownMenuItem(
                              value: "MIEMBRO",
                              child: Text("Miembro"),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _rolFiltro = v ?? "TODOS"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  UsuariosPorMesChart(nuevosPorMes: nuevosPorMes),

                  const SizedBox(height: 16),
                  Text(
                    "Usuarios: ${usuariosFiltrados.length} / ${usuarios.length}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  ...usuariosFiltrados.map(_userTile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _userTile(Map<String, dynamic> u) {
    final nombre = (u["nombre"] ?? "").toString();
    final apellidos = (u["apellidos"] ?? "").toString();
    final email = (u["email"] ?? "").toString();
    final telefono = (u["telefono"] ?? "").toString();
    final rol = (u["rol"] ?? "").toString();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text("$nombre $apellidos".trim()),
        subtitle: Text("$email\n$telefono"),
        isThreeLine: true,
        trailing: Chip(label: Text(rol)),
      ),
    );
  }
}
