import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../domain/controllers/dijkstra_controller.dart';
import '../../widgets/controls_bar.dart';
import '../../widgets/grid_view_widget.dart';
import '../../widgets/legend_panel.dart';
import '../../widgets/stats_panel.dart';

/// Pantalla principal de visualización del algoritmo de Dijkstra.
class DijkstraScreen extends StatelessWidget {
  static const String routeName = '/';

  const DijkstraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DijkstraController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Algoritmo de Dijkstra')),
      body: Watch((context) {
        final grid = controller.gridSignal.value;
        final isRunning = controller.isRunningSignal.value;
        final stats = controller.statsSignal.value;
        final delayMs = controller.stepDelayMsSignal.value;
        final editMode = controller.editModeSignal.value;

        return Column(
          children: [
            const LegendPanel(),
            Expanded(
              child: GridViewWidget(grid: grid, controller: controller),
            ),
            StatsPanel(stats: stats),
            ControlsBar(
              controller: controller,
              isRunning: isRunning,
              currentSpeed: delayMs,
              editMode: editMode,
            ),
          ],
        );
      }),
    );
  }
}
