import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../analiticas/presentation/providers/analiticas_asociacion_provider.dart';
import '../../analiticas/presentation/widgets/bautismos_por_anio_chart.dart';
import '../../analiticas/presentation/widgets/iglesias_por_distrito_chart.dart';

class SuperAdminAnaliticasAsociacionScreen extends ConsumerWidget {
  final String asociacionId;

  const SuperAdminAnaliticasAsociacionScreen({
    super.key,
    required this.asociacionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(analiticasAsociacionProvider(asociacionId));

    return Scaffold(
      appBar: AppBar(title: const Text("Análisis de Asociación")),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (data) {
          final resumen = data["resumen"] as Map<String, dynamic>;
          final bautismosPorAnio = (data["bautismosPorAnio"] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final iglesiasPorDistrito =
              (data["iglesiasPorDistrito"] as List? ?? [])
                  .cast<Map<String, dynamic>>();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _statCard("Distritos", resumen["totalDistritos"]),
              _statCard("Iglesias", resumen["totalIglesias"]),
              _statCard("Pastores", resumen["totalPastores"]),
              _statCard("Miembros", resumen["totalMiembros"]),
              _statCard("Bautismos", resumen["totalBautismos"]),

              const SizedBox(height: 16),

              // ✅ Gráfica 1
              BautismosPorAnioChart(bautismosPorAnio: bautismosPorAnio),

              IglesiasPorDistritoChart(distritos: iglesiasPorDistrito),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String label, int value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
