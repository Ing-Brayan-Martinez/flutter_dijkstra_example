import 'package:flutter/material.dart';
import '../../domain/controllers/dijkstra_controller.dart';
import '../../domain/model/node.dart';
import 'node_widget.dart';

/// Cuadrícula interactiva que renderiza las celdas del tablero.
class GridViewWidget extends StatelessWidget {
  final List<List<Node>> grid;
  final DijkstraController controller;

  const GridViewWidget({
    super.key,
    required this.grid,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final rows = controller.rows;
    final cols = controller.cols;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final boardWidth = width < height * cols / rows
            ? width
            : height * cols / rows;
        final boardHeight = boardWidth * rows / cols;

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                final r = index ~/ cols;
                final c = index % cols;
                final node = grid[r][c];

                final isStart =
                    r == controller.startRow && c == controller.startCol;
                final isEnd = r == controller.endRow && c == controller.endCol;

                return NodeWidget(
                  node: node,
                  isStart: isStart,
                  isEnd: isEnd,
                  onTap: () => controller.handleCellTap(r, c),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
