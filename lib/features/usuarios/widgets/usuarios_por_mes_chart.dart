import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UsuariosPorMesChart extends StatelessWidget {
  final List<Map<String, dynamic>> nuevosPorMes;

  /// Si hay muchos meses, puedes mostrar solo últimos N
  final int maxMeses;

  const UsuariosPorMesChart({
    super.key,
    required this.nuevosPorMes,
    this.maxMeses = 12,
  });

  String _labelMes(String yyyyMm) {
    // "2026-01" -> "Ene"
    final parts = yyyyMm.split("-");
    if (parts.length != 2) return yyyyMm;

    final m = int.tryParse(parts[1]) ?? 0;
    const months = [
      "",
      "Ene",
      "Feb",
      "Mar",
      "Abr",
      "May",
      "Jun",
      "Jul",
      "Ago",
      "Sep",
      "Oct",
      "Nov",
      "Dic",
    ];
    if (m < 1 || m > 12) return yyyyMm;
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    if (nuevosPorMes.isEmpty) {
      return const Text("Sin datos para la gráfica.");
    }

    // tomar últimos N meses
    final data = nuevosPorMes.length > maxMeses
        ? nuevosPorMes.sublist(nuevosPorMes.length - maxMeses)
        : nuevosPorMes;

    final valores = data
        .map(
          (e) =>
              (e["cantidad"] is num) ? (e["cantidad"] as num).toDouble() : 0.0,
        )
        .toList();

    final maxY = (valores.reduce((a, b) => a > b ? a : b) + 2)
        .clamp(5, 999999)
        .toDouble();

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: valores[i],
              width: 18,
              borderRadius: BorderRadius.circular(8),
              // No especifico color para cumplir tu preferencia; usa el tema:
              color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nuevos usuarios por mes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY / 4).ceilToDouble(),
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.black12, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        interval: (maxY / 4).ceilToDouble(),
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length)
                            return const SizedBox.shrink();
                          final mes = data[idx]["mes"]?.toString() ?? "";
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _labelMes(mes),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 12,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final mes = data[group.x]["mes"]?.toString() ?? "";
                        final cant = rod.toY.toInt();
                        return BarTooltipItem(
                          "$mes\n$cant usuarios",
                          const TextStyle(fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
