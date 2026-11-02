import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/controllers/dijkstra_controller.dart';

/// Contenedor MultiProvider para inyectar controladores de dominio a la UI.
class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DijkstraController>(create: (_) => DijkstraController()),
      ],
      child: child,
    );
  }
}
