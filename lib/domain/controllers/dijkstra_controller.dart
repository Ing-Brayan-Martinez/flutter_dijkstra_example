import 'dart:async';
import 'package:signals/signals.dart';

import '../config/log.dart';
import '../model/dijkstra_stats.dart';
import '../model/node.dart';

/// Controlador de dominio puro en Dart encargado de la gestión de la cuadrícula
/// y la simulación del algoritmo de Dijkstra utilizando Signals para el estado.
enum GridEditMode { wall, start, end }

class DijkstraController {
  static const int defaultRows = 20;
  static const int defaultCols = 15;

  final int rows;
  final int cols;

  int startRow;
  int startCol;
  int endRow;
  int endCol;

  // Señales de estado
  late final Signal<List<List<Node>>> gridSignal;
  final isRunningSignal = signal<bool>(false);
  final stepDelayMsSignal = signal<int>(10);
  final statsSignal = signal<DijkstraStats>(const DijkstraStats());
  final editModeSignal = signal<GridEditMode>(GridEditMode.wall);

  bool _cancelRequested = false;

  DijkstraController({
    this.rows = defaultRows,
    this.cols = defaultCols,
    this.startRow = 2,
    this.startCol = 2,
    this.endRow = 17,
    this.endCol = 12,
  }) {
    gridSignal = signal<List<List<Node>>>(_createGrid());
    Log.i('DijkstraController inicializado ($rows x $cols)');
  }

  List<List<Node>> _createGrid() {
    return List.generate(rows, (r) {
      return List.generate(cols, (c) {
        return Node(row: r, col: c);
      });
    });
  }

  /// Reinicia toda la cuadrícula eliminando muros y rastros.
  void initializeGrid() {
    gridSignal.value = _createGrid();
    statsSignal.value = const DijkstraStats();
    Log.i('Cuadrícula reiniciada por completo');
  }

  /// Reinicia la simulación del algoritmo manteniendo los muros colocados.
  void resetAlgorithm() {
    if (isRunningSignal.value) return;
    final currentGrid = gridSignal.value;
    for (var row in currentGrid) {
      for (var node in row) {
        node.reset();
      }
    }
    gridSignal.value = List.of(currentGrid);
    statsSignal.value = const DijkstraStats();
    Log.i('Rastros del algoritmo limpiados');
  }

  /// Elimina los muros colocados por el usuario.
  void clearWalls() {
    if (isRunningSignal.value) return;
    initializeGrid();
  }

  /// Selecciona qué elemento se modificará al tocar una celda.
  void setEditMode(GridEditMode mode) {
    if (isRunningSignal.value) return;
    editModeSignal.value = mode;
  }

  /// Aplica la herramienta seleccionada a una celda de la cuadrícula.
  void handleCellTap(int row, int col) {
    switch (editModeSignal.value) {
      case GridEditMode.wall:
        toggleWall(row, col);
      case GridEditMode.start:
        setStartNode(row, col);
      case GridEditMode.end:
        setEndNode(row, col);
    }
  }

  /// Cambia el estado de muro de una celda específica.
  void toggleWall(int row, int col) {
    if (isRunningSignal.value) return;
    _validatePosition(row, col);
    if ((row == startRow && col == startCol) ||
        (row == endRow && col == endCol)) {
      return;
    }

    final currentGrid = gridSignal.value;
    currentGrid[row][col].isWall = !currentGrid[row][col].isWall;
    gridSignal.value = List.of(currentGrid);
  }

  /// Mueve el nodo de inicio y elimina el muro que hubiera en la nueva celda.
  void setStartNode(int row, int col) {
    if (isRunningSignal.value) return;
    _validatePosition(row, col);
    if ((row == startRow && col == startCol) ||
        (row == endRow && col == endCol)) {
      return;
    }

    resetAlgorithm();
    startRow = row;
    startCol = col;
    final grid = gridSignal.value;
    grid[row][col].isWall = false;
    gridSignal.value = List.of(grid);
  }

  /// Mueve el nodo de destino y elimina el muro que hubiera en la nueva celda.
  void setEndNode(int row, int col) {
    if (isRunningSignal.value) return;
    _validatePosition(row, col);
    if ((row == endRow && col == endCol) ||
        (row == startRow && col == startCol)) {
      return;
    }

    resetAlgorithm();
    endRow = row;
    endCol = col;
    final grid = gridSignal.value;
    grid[row][col].isWall = false;
    gridSignal.value = List.of(grid);
  }

  /// Modifica la velocidad de la animación en milisegundos por paso.
  void setSpeed(int delayMs) {
    stepDelayMsSignal.value = delayMs.clamp(0, 100);
  }

  /// Solicita la cancelación de la ejecución del algoritmo.
  void stopExecution() {
    if (isRunningSignal.value) {
      _cancelRequested = true;
    }
  }

  /// Ejecuta el algoritmo de Dijkstra de forma asíncrona notificando avances en la señal.
  Future<void> runDijkstra() async {
    if (isRunningSignal.value) return;

    Log.i('Ejecutando algoritmo de Dijkstra...');
    _cancelRequested = false;
    resetAlgorithm();

    isRunningSignal.value = true;
    statsSignal.value = statsSignal.value.copyWith(
      state: AlgorithmState.running,
    );

    final stopwatch = Stopwatch()..start();
    final grid = gridSignal.value;

    final unvisitedNodes = <Node>[];
    final startNode = grid[startRow][startCol];
    startNode.distance = 0;

    for (var row in grid) {
      for (var node in row) {
        unvisitedNodes.add(node);
      }
    }

    int visitedCount = 0;

    while (unvisitedNodes.isNotEmpty) {
      if (_cancelRequested) {
        Log.w('Ejecución cancelada');
        stopwatch.stop();
        isRunningSignal.value = false;
        statsSignal.value = statsSignal.value.copyWith(
          state: AlgorithmState.cancelled,
          visitedNodesCount: visitedCount,
          executionTimeMs: stopwatch.elapsedMilliseconds,
        );
        return;
      }

      unvisitedNodes.sort((a, b) => a.distance.compareTo(b.distance));
      final current = unvisitedNodes.removeAt(0);

      if (current.distance == double.infinity) {
        Log.w('No existe un camino posible hasta el destino');
        stopwatch.stop();
        isRunningSignal.value = false;
        statsSignal.value = statsSignal.value.copyWith(
          state: AlgorithmState.noPathFound,
          visitedNodesCount: visitedCount,
          executionTimeMs: stopwatch.elapsedMilliseconds,
        );
        return;
      }

      if (current.isWall) continue;

      current.isVisited = true;
      visitedCount++;

      gridSignal.value = List.of(grid);
      statsSignal.value = statsSignal.value.copyWith(
        visitedNodesCount: visitedCount,
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );

      final delay = stepDelayMsSignal.value;
      if (delay > 0 && current.distance > 0) {
        await Future.delayed(Duration(milliseconds: delay));
      }

      if (current.row == endRow && current.col == endCol) {
        final pathLength = await _reconstructPath(current, stopwatch);
        stopwatch.stop();
        isRunningSignal.value = false;
        statsSignal.value = statsSignal.value.copyWith(
          state: _cancelRequested
              ? AlgorithmState.cancelled
              : AlgorithmState.completed,
          visitedNodesCount: visitedCount,
          pathLength: pathLength,
          executionTimeMs: stopwatch.elapsedMilliseconds,
        );
        if (_cancelRequested) {
          Log.w('Ejecución cancelada durante la reconstrucción del camino');
        } else {
          Log.success(
            'Camino encontrado. Longitud: $pathLength, Nodos visitados: $visitedCount, Tiempo: ${stopwatch.elapsedMilliseconds}ms',
          );
        }
        return;
      }

      _updateUnvisitedNeighbors(current, grid);
    }

    stopwatch.stop();
    isRunningSignal.value = false;
    statsSignal.value = statsSignal.value.copyWith(
      state: AlgorithmState.noPathFound,
      visitedNodesCount: visitedCount,
      executionTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  void _updateUnvisitedNeighbors(Node node, List<List<Node>> grid) {
    final neighbors = _getNeighbors(node, grid);
    for (final neighbor in neighbors) {
      if (neighbor.isVisited) continue;
      final newDist = node.distance + 1;
      if (newDist < neighbor.distance) {
        neighbor.distance = newDist;
        neighbor.parent = node;
      }
    }
  }

  List<Node> _getNeighbors(Node node, List<List<Node>> grid) {
    final neighbors = <Node>[];
    if (node.row > 0) neighbors.add(grid[node.row - 1][node.col]);
    if (node.row < rows - 1) neighbors.add(grid[node.row + 1][node.col]);
    if (node.col > 0) neighbors.add(grid[node.row][node.col - 1]);
    if (node.col < cols - 1) neighbors.add(grid[node.row][node.col + 1]);
    return neighbors;
  }

  void _validatePosition(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      throw RangeError('Posición fuera de la cuadrícula: ($row, $col)');
    }
  }

  Future<int> _reconstructPath(Node endNode, Stopwatch stopwatch) async {
    Node? current = endNode;
    int pathLength = 0;

    while (current != null) {
      if (_cancelRequested) break;
      current.isPath = true;
      pathLength++;
      gridSignal.value = List.of(gridSignal.value);

      final delay = stepDelayMsSignal.value;
      if (delay > 0) {
        await Future.delayed(Duration(milliseconds: delay * 2));
      }
      current = current.parent;
    }

    return pathLength;
  }
}
