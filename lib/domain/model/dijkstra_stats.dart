/// Estado actual del proceso de ejecución del algoritmo.
enum AlgorithmState { idle, running, completed, noPathFound, cancelled }

/// Contiene las métricas en tiempo real de la simulación del algoritmo de Dijkstra.
class DijkstraStats {
  final int visitedNodesCount;
  final int pathLength;
  final int executionTimeMs;
  final AlgorithmState state;

  const DijkstraStats({
    this.visitedNodesCount = 0,
    this.pathLength = 0,
    this.executionTimeMs = 0,
    this.state = AlgorithmState.idle,
  });

  DijkstraStats copyWith({
    int? visitedNodesCount,
    int? pathLength,
    int? executionTimeMs,
    AlgorithmState? state,
  }) {
    return DijkstraStats(
      visitedNodesCount: visitedNodesCount ?? this.visitedNodesCount,
      pathLength: pathLength ?? this.pathLength,
      executionTimeMs: executionTimeMs ?? this.executionTimeMs,
      state: state ?? this.state,
    );
  }
}
