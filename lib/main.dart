import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';

void main() {
  runApp(const PortfolioDijkstraApp());
}

// --- MÓDELO DE DATOS ---

/// Representa una celda en la cuadrícula
class Node {
  final int row;
  final int col;
  bool isWall;
  bool isVisited;
  bool isPath; // Parte del camino final
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

  // Reinicia el estado para una nueva búsqueda, manteniendo si es muro o no
  void reset() {
    isVisited = false;
    isPath = false;
    distance = double.infinity;
    parent = null;
  }
}

// --- APLICACIÓN PRINCIPAL ---

class PortfolioDijkstraApp extends StatelessWidget {
  const PortfolioDijkstraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dijkstra Portfolio Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const DijkstraVisualizer(),
    );
  }
}

class DijkstraVisualizer extends StatefulWidget {
  const DijkstraVisualizer({super.key});

  @override
  State<DijkstraVisualizer> createState() => _DijkstraVisualizerState();
}

class _DijkstraVisualizerState extends State<DijkstraVisualizer> {
  // Configuración de la cuadrícula
  static const int rows = 20;
  static const int cols = 15;
  late List<List<Node>> grid;

  // Posiciones de inicio y fin
  final int startRow = 2;
  final int startCol = 2;
  final int endRow = 17;
  final int endCol = 12;

  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    grid = List.generate(rows, (r) {
      return List.generate(cols, (c) {
        return Node(row: r, col: c);
      });
    });
  }

  void _resetAlgorithm() {
    if (isRunning) return;
    setState(() {
      for (var row in grid) {
        for (var node in row) {
          node.reset();
        }
      }
    });
  }

  void _clearWalls() {
    if (isRunning) return;
    setState(() {
      _initializeGrid();
    });
  }

  // --- LÓGICA DEL ALGORITMO DE DIJKSTRA ---

  Future<void> _runDijkstra() async {
    if (isRunning) return;

    // Limpiamos rastros anteriores pero dejamos los muros
    _resetAlgorithm();

    setState(() => isRunning = true);

    // Cola simple para nodos abiertos (no usamos PriorityQueue externa para evitar dependencias extra)
    List<Node> unvisitedNodes = [];

    // 1. Configurar nodo inicial
    Node startNode = grid[startRow][startCol];
    startNode.distance = 0;

    // Llenamos la lista de no visitados
    for (var row in grid) {
      for (var node in row) {
        unvisitedNodes.add(node);
      }
    }

    while (unvisitedNodes.isNotEmpty) {
      // Simular prioridad: ordenar por distancia
      unvisitedNodes.sort((a, b) => a.distance.compareTo(b.distance));

      // Sacar el nodo con menor distancia
      Node current = unvisitedNodes.removeAt(0);

      // Si la distancia es infinita, estamos atrapados o terminamos lo accesible
      if (current.distance == double.infinity) break;

      // Si es muro, lo ignoramos
      if (current.isWall) continue;

      // Marcar como visitado visualmente
      setState(() {
        current.isVisited = true;
      });

      // Pequeño delay para la animación
      if (current.distance > 0) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Si llegamos al destino
      if (current.row == endRow && current.col == endCol) {
        await _reconstructPath(current);
        setState(() => isRunning = false);
        return;
      }

      // Explorar vecinos
      _updateUnvisitedNeighbors(current);
    }

    setState(() => isRunning = false);
  }

  void _updateUnvisitedNeighbors(Node node) {
    List<Node> neighbors = _getNeighbors(node);
    for (Node neighbor in neighbors) {
      if (neighbor.isVisited) continue; // Ya procesado
      // En una grilla simple, el peso de arista es 1
      double newDist = node.distance + 1;

      if (newDist < neighbor.distance) {
        neighbor.distance = newDist;
        neighbor.parent = node;
      }
    }
  }

  List<Node> _getNeighbors(Node node) {
    List<Node> neighbors = [];
    // Arriba
    if (node.row > 0) neighbors.add(grid[node.row - 1][node.col]);
    // Abajo
    if (node.row < rows - 1) neighbors.add(grid[node.row + 1][node.col]);
    // Izquierda
    if (node.col > 0) neighbors.add(grid[node.row][node.col - 1]);
    // Derecha
    if (node.col < cols - 1) neighbors.add(grid[node.row][node.col + 1]);

    return neighbors;
  }

  Future<void> _reconstructPath(Node endNode) async {
    Node? current = endNode;
    while (current != null) {
      setState(() {
        current!.isPath = true;
      });
      await Future.delayed(const Duration(milliseconds: 30));
      current = current.parent;
    }
  }

  // --- INTERFAZ DE USUARIO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algoritmo de Dijkstra'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Panel de información
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.green, "Inicio"),
                _buildLegendItem(Colors.red, "Fin"),
                _buildLegendItem(Colors.grey[800]!, "Muro"),
                _buildLegendItem(Colors.amber, "Camino"),
              ],
            ),
          ),
          const Text(
            "Toca las celdas para crear muros",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // La Cuadrícula (Grid)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  int r = index ~/ cols;
                  int c = index % cols;
                  return _buildNodeWidget(grid[r][c]);
                },
              ),
            ),
          ),

          // Botones de control
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: isRunning ? null : _clearWalls,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Limpiar Muros"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                ),
                ElevatedButton.icon(
                  onPressed: isRunning ? null : _runDijkstra,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("INICIAR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(Node node) {
    // Determinar color
    Color color = Colors.grey[850]!; // Defecto

    if (node.row == startRow && node.col == startCol) {
      color = Colors.greenAccent;
    } else if (node.row == endRow && node.col == endCol) {
      color = Colors.redAccent;
    } else if (node.isWall) {
      color = Colors.black;
    } else if (node.isPath) {
      color = Colors.amber;
    } else if (node.isVisited) {
      color = Colors.blue.withOpacity(0.5);
    }

    return GestureDetector(
      onTap: () {
        if (isRunning) return;
        // Evitar tap en inicio o fin
        if ((node.row == startRow && node.col == startCol) ||
            (node.row == endRow && node.col == endCol)) return;

        setState(() {
          node.isWall = !node.isWall;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white10),
        ),
        child: node.isVisited && !node.isPath && !node.isWall &&
            !((node.row == startRow && node.col == startCol) || (node.row == endRow && node.col == endCol))
            ? const Center(
          child: Icon(Icons.check, size: 10, color: Colors.white24),
        )
            : null,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
