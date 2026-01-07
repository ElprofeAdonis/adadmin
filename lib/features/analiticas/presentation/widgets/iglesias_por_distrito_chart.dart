import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IglesiasPorDistritoChart extends StatelessWidget {
  final List<Map<String, dynamic>> distritos;

  const IglesiasPorDistritoChart({super.key, required this.distritos});

  @override
  Widget build(BuildContext context) {
    if (distritos.isEmpty) {
      return const Text("No hay datos de distritos.");
    }

    // Max para el eje Y
    final maxCount = distritos
        .map((d) => (d["_count"]?["iglesias"] ?? 0) as int)
        .fold<int>(0, (prev, v) => v > prev ? v : prev);

    final maxY = (maxCount == 0) ? 1.0 : (maxCount + 1).toDouble();

    // Altura dinámica (mínimo 260 para que no quede aplastado)
    final chartHeight = (distritos.length * 52).toDouble();
    final safeHeight = chartHeight < 260.0
        ? 260.0
        : (chartHeight > 900.0 ? 900.0 : chartHeight);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Iglesias por distrito",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: safeHeight,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),

                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    // ✅ Eje Y: números (cantidad)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          // Solo enteros
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),

                    // ✅ Eje X: nombres (categorías)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1, // 0,1,2,3...
                        reservedSize: 70,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= distritos.length) {
                            return const SizedBox.shrink();
                          }
                          // Solo cuando sea exactamente entero
                          if (value != i.toDouble()) {
                            return const SizedBox.shrink();
                          }

                          final nombre =
                              (distritos[i]["nombre"] ?? "Sin nombre")
                                  .toString();

                          // Rotar para que no se monten
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 10,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: SizedBox(
                                width: 110,
                                child: Text(
                                  nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  barGroups: List.generate(distritos.length, (i) {
                    final count = (distritos[i]["_count"]?["iglesias"] ?? 0);

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (count as int).toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          // ✅ si quieres dejarlo sin color fijo, quítalo.
                          // color: Colors.blueAccent,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
