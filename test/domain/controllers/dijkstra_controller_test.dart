import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dijkstra_example/domain/controllers/dijkstra_controller.dart';
import 'package:flutter_dijkstra_example/domain/model/dijkstra_stats.dart';

void main() {
  group('DijkstraController', () {
    test('finds a shortest path and reports its metrics', () async {
      final controller = DijkstraController(
        rows: 5,
        cols: 5,
        startRow: 0,
        startCol: 0,
        endRow: 2,
        endCol: 2,
      );
      controller.setSpeed(0);

      await controller.runDijkstra();

      expect(controller.statsSignal.value.state, AlgorithmState.completed);
      expect(controller.statsSignal.value.pathLength, 5);
      expect(controller.gridSignal.value[0][0].isPath, isTrue);
      expect(controller.gridSignal.value[2][2].isPath, isTrue);
      expect(controller.isRunningSignal.value, isFalse);
    });

    test('reports when walls make the destination unreachable', () async {
      final controller = DijkstraController(
        rows: 3,
        cols: 3,
        startRow: 0,
        startCol: 0,
        endRow: 2,
        endCol: 2,
      );
      controller.setSpeed(0);
      for (var col = 0; col < controller.cols; col++) {
        controller.toggleWall(1, col);
      }

      await controller.runDijkstra();

      expect(controller.statsSignal.value.state, AlgorithmState.noPathFound);
      expect(controller.statsSignal.value.pathLength, 0);
      expect(controller.isRunningSignal.value, isFalse);
    });

    test('finds a shortest path around a wall without crossing it', () async {
      final controller = DijkstraController(
        rows: 3,
        cols: 3,
        startRow: 1,
        startCol: 0,
        endRow: 1,
        endCol: 2,
      );
      controller.setSpeed(0);
      controller.toggleWall(1, 1);

      await controller.runDijkstra();

      final grid = controller.gridSignal.value;
      final pathNodes = grid.expand((row) => row).where((node) => node.isPath);

      expect(controller.statsSignal.value.state, AlgorithmState.completed);
      expect(controller.statsSignal.value.pathLength, 5);
      expect(pathNodes.length, 5);
      expect(grid[1][1].isWall, isTrue);
      expect(grid[1][1].isPath, isFalse);
    });

    test('keeps endpoints clear and rejects positions outside the grid', () {
      final controller = DijkstraController(
        rows: 3,
        cols: 3,
        startRow: 0,
        startCol: 0,
        endRow: 2,
        endCol: 2,
      );

      controller.toggleWall(0, 0);
      controller.toggleWall(2, 2);

      expect(controller.gridSignal.value[0][0].isWall, isFalse);
      expect(controller.gridSignal.value[2][2].isWall, isFalse);
      expect(() => controller.toggleWall(-1, 0), throwsRangeError);
      expect(() => controller.setEndNode(3, 0), throwsRangeError);
    });

    test('clamps the animation speed to its supported range', () {
      final controller = DijkstraController(rows: 3, cols: 3);

      controller.setSpeed(-1);
      expect(controller.stepDelayMsSignal.value, 0);

      controller.setSpeed(101);
      expect(controller.stepDelayMsSignal.value, 100);
    });

    test('moves endpoints, removes a wall, and resets search state', () async {
      final controller = DijkstraController(
        rows: 3,
        cols: 3,
        startRow: 0,
        startCol: 0,
        endRow: 2,
        endCol: 2,
      );
      controller.setSpeed(0);
      await controller.runDijkstra();
      expect(controller.statsSignal.value.state, AlgorithmState.completed);

      controller.toggleWall(1, 1);
      controller.setStartNode(1, 1);

      expect(controller.startRow, 1);
      expect(controller.startCol, 1);
      expect(controller.gridSignal.value[1][1].isWall, isFalse);
      expect(controller.gridSignal.value[0][0].isPath, isFalse);
      expect(controller.statsSignal.value.state, AlgorithmState.idle);

      controller.setEditMode(GridEditMode.end);
      controller.handleCellTap(0, 2);

      expect(controller.endRow, 0);
      expect(controller.endCol, 2);
    });

    test('marks a stopped run as cancelled', () async {
      final controller = DijkstraController(
        rows: 5,
        cols: 5,
        startRow: 0,
        startCol: 0,
        endRow: 4,
        endCol: 4,
      );
      controller.setSpeed(10);

      final run = controller.runDijkstra();
      controller.stopExecution();
      await run;

      expect(controller.statsSignal.value.state, AlgorithmState.cancelled);
      expect(controller.isRunningSignal.value, isFalse);
    });
  });
}
