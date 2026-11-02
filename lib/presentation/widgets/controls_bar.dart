import 'package:flutter/material.dart';
import '../../domain/controllers/dijkstra_controller.dart';

/// Barra de controles con botones de acción (Iniciar, Detener, Limpiar) y slider de velocidad.
class ControlsBar extends StatelessWidget {
  final DijkstraController controller;
  final bool isRunning;
  final int currentSpeed;
  final GridEditMode editMode;

  const ControlsBar({
    super.key,
    required this.controller,
    required this.isRunning,
    required this.currentSpeed,
    required this.editMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<GridEditMode>(
            segments: const [
              ButtonSegment(
                value: GridEditMode.wall,
                icon: Icon(Icons.grid_on),
                label: Text('Muro'),
              ),
              ButtonSegment(
                value: GridEditMode.start,
                icon: Icon(Icons.flag),
                label: Text('Inicio'),
              ),
              ButtonSegment(
                value: GridEditMode.end,
                icon: Icon(Icons.place),
                label: Text('Fin'),
              ),
            ],
            selected: {editMode},
            onSelectionChanged: isRunning
                ? null
                : (selection) => controller.setEditMode(selection.first),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: isRunning ? null : controller.clearWalls,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Limpiar muros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: isRunning ? null : controller.resetAlgorithm,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reiniciar algoritmo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: isRunning
                    ? controller.stopExecution
                    : controller.runDijkstra,
                icon: Icon(isRunning ? Icons.stop : Icons.play_arrow, size: 20),
                label: Text(isRunning ? 'DETENER' : 'INICIAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning
                      ? Colors.redAccent[700]
                      : Colors.tealAccent[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Velocidad: ',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Expanded(
                child: Slider(
                  value: (100 - currentSpeed).toDouble().clamp(0.0, 100.0),
                  min: 0,
                  max: 100,
                  activeColor: Colors.tealAccent[400],
                  onChanged: isRunning
                      ? null
                      : (val) => controller.setSpeed(100 - val.toInt()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
