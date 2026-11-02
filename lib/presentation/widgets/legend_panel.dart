import 'package:flutter/material.dart';

/// Panel con la simbología explicativa de colores para las celdas.
class LegendPanel extends StatelessWidget {
  const LegendPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(Colors.greenAccent, "Inicio"),
              _buildLegendItem(Colors.redAccent, "Fin"),
              _buildLegendItem(Colors.black, "Muro"),
              _buildLegendItem(Colors.blue.withValues(alpha: 0.5), "Visitado"),
              _buildLegendItem(Colors.amber, "Camino"),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Toca las celdas para agregar o quitar muros",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white24),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
