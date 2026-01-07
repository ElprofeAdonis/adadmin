import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BautismosPorAnioChart extends StatelessWidget {
  final List<Map<String, dynamic>> bautismosPorAnio;

  const BautismosPorAnioChart({super.key, required this.bautismosPorAnio});

  @override
  Widget build(BuildContext context) {
    if (bautismosPorAnio.isEmpty) {
      return _card(child: const Text("Sin datos de bautismos por año."));
    }

    // Ordenar por año (por si viene desordenado)
    final items = [...bautismosPorAnio]
      ..sort((a, b) => (a["year"] as int).compareTo(b["year"] as int));

    final years = items.map((e) => (e["year"] as int)).toList();
    final values = items.map((e) => (e["cantidad"] as int?) ?? 0).toList();

    final maxY = _niceMax(values);
    final barGroups = List.generate(items.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i].toDouble(),
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bautismos por año",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                maxY: maxY.toDouble(),
                minY: 0,
                barGroups: barGroups,
                gridData: FlGridData(show: true, drawVerticalLine: false),
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
                      interval: _leftInterval(maxY).toDouble(),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= years.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            years[idx].toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final year = years[group.x.toInt()];
                      final val = rod.toY.toInt();
                      return BarTooltipItem(
                        "$year\n$val bautismos",
                        const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Total: ${values.fold<int>(0, (a, b) => a + b)}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  int _niceMax(List<int> values) {
    final maxVal = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 5) return 5;
    if (maxVal <= 10) return 10;
    if (maxVal <= 20) return 20;
    if (maxVal <= 50) return 50;
    if (maxVal <= 100) return 100;

    // redondear al siguiente múltiplo de 50
    final r = ((maxVal / 50).ceil()) * 50;
    return r;
  }

  int _leftInterval(int maxY) {
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    return 50;
  }
}
