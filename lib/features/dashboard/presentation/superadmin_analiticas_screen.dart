import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'superadmin_analiticas_asociacion_screen.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class SuperAdminAnaliticasScreen extends ConsumerWidget {
  const SuperAdminAnaliticasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (data) {
        final asociaciones = (data["asociaciones"] ?? []) as List;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: asociaciones.length,
          itemBuilder: (context, i) {
            final a = asociaciones[i] as Map<String, dynamic>;

            final id = a["id"];
            final nombre = a["nombre"];
            final distritos = a["cantidadDistritos"] ?? 0;
            final pastores = a["cantidadPastores"] ?? 0;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                title: Text(
                  nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text("Distritos: $distritos • Pastores: $pastores"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SuperAdminAnaliticasAsociacionScreen(
                        asociacionId: id,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
