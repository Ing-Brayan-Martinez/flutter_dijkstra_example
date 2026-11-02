import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dijkstra_example/domain/controllers/dijkstra_controller.dart';
import 'package:flutter_dijkstra_example/presentation/screens/dijkstra/dijkstra_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders the Dijkstra screen and its initial state', (
    tester,
  ) async {
    final controller = DijkstraController(
      rows: 3,
      cols: 3,
      startRow: 0,
      startCol: 0,
      endRow: 2,
      endCol: 2,
    );

    await tester.pumpWidget(
      Provider<DijkstraController>.value(
        value: controller,
        child: const MaterialApp(home: DijkstraScreen()),
      ),
    );

    expect(find.text('Algoritmo de Dijkstra'), findsOneWidget);
    expect(find.text('Listo para iniciar'), findsOneWidget);
    expect(find.text('INICIAR'), findsOneWidget);
    expect(find.text('Reiniciar algoritmo'), findsOneWidget);
  });

  testWidgets('starts the algorithm and displays the completed path', (
    tester,
  ) async {
    final controller = DijkstraController(
      rows: 3,
      cols: 3,
      startRow: 0,
      startCol: 0,
      endRow: 2,
      endCol: 2,
    )..setSpeed(0);

    await tester.pumpWidget(
      Provider<DijkstraController>.value(
        value: controller,
        child: const MaterialApp(home: DijkstraScreen()),
      ),
    );

    await tester.tap(find.text('INICIAR'));
    await tester.pumpAndSettle();

    expect(find.text('¡Camino encontrado!'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('INICIAR'), findsOneWidget);
    expect(controller.isRunningSignal.value, isFalse);
  });
}
