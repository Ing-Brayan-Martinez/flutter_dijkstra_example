/// Representa una celda en la cuadrícula para la simulación del algoritmo de Dijkstra.
class Node {
  final int row;
  final int col;
  bool isWall;
  bool isVisited;
  bool isPath;
  double distance;
  Node? parent;

  Node({
    required this.row,
    required this.col,
    this.isWall = false,
    this.isVisited = false,
    this.isPath = false,
    this.distance = double.infinity,
    this.parent,
  });

  /// Reinicia el estado de búsqueda manteniendo si la celda es muro o no.
  void reset() {
    isVisited = false;
    isPath = false;
    distance = double.infinity;
    parent = null;
  }

  /// Genera una copia independiente de la celda.
  Node copy() {
    return Node(
      row: row,
      col: col,
      isWall: isWall,
      isVisited: isVisited,
      isPath: isPath,
      distance: distance,
      parent: parent,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
