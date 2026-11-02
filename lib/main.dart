import 'package:flutter/material.dart';

import 'domain/config/log.dart';
import 'presentation/provider/app_provider.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Log.i('Iniciando Aplicación Dijkstra Visualizer');
  runApp(const PortfolioDijkstraApp());
}

/// Punto de entrada principal de la aplicación.
class PortfolioDijkstraApp extends StatelessWidget {
  const PortfolioDijkstraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      child: MaterialApp.router(
        title: 'Dijkstra Portfolio Visualizer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
