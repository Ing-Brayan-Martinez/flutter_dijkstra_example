import 'package:flutter/material.dart';
import '../../domain/model/node.dart';

/// Widget visual para representar individualmente una celda de la cuadrícula.
class NodeWidget extends StatelessWidget {
  final Node node;
  final bool isStart;
  final bool isEnd;
  final VoidCallback onTap;

  const NodeWidget({
    super.key,
    required this.node,
    required this.isStart,
    required this.isEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey[850]!;

    if (isStart) {
      color = Colors.greenAccent;
    } else if (isEnd) {
      color = Colors.redAccent;
    } else if (node.isWall) {
      color = Colors.black;
    } else if (node.isPath) {
      color = Colors.amber;
    } else if (node.isVisited) {
      color = Colors.blue.withValues(alpha: 0.5);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white10),
        ),
        child:
            node.isVisited && !node.isPath && !node.isWall && !isStart && !isEnd
            ? const Center(
                child: Icon(Icons.check, size: 10, color: Colors.white24),
              )
            : null,
      ),
    );
  }
}
