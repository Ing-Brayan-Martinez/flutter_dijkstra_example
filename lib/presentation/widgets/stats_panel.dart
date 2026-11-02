import 'package:flutter/material.dart';
import '../../domain/model/dijkstra_stats.dart';

/// Panel de indicadores con métricas en tiempo real de la simulación.
class StatsPanel extends StatelessWidget {
  final DijkstraStats stats;

  const StatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final String statusText = switch (stats.state) {
      AlgorithmState.idle => "Listo para iniciar",
      AlgorithmState.running => "Buscando camino...",
      AlgorithmState.completed => "¡Camino encontrado!",
      AlgorithmState.noPathFound => "No hay camino posible",
      AlgorithmState.cancelled => "Ejecución detenida",
    };

    final Color statusColor = switch (stats.state) {
      AlgorithmState.idle => Colors.grey,
      AlgorithmState.running => Colors.blueAccent,
      AlgorithmState.completed => Colors.greenAccent,
      AlgorithmState.noPathFound => Colors.redAccent,
      AlgorithmState.cancelled => Colors.orangeAccent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 20,
        runSpacing: 8,
        children: [
          _buildStatCard("Estado", statusText, color: statusColor),
          _buildStatCard("Visitados", "${stats.visitedNodesCount}"),
          _buildStatCard(
            "Camino",
            stats.pathLength > 0 ? "${stats.pathLength}" : "-",
          ),
          _buildStatCard("Tiempo", "${stats.executionTimeMs} ms"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
