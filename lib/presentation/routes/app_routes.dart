import 'package:go_router/go_router.dart';
import '../screens/dijkstra/dijkstra_screen.dart';

/// Configuración de rutas y navegación declarativa con GoRouter.
abstract class AppRoutes {
  static const String initialRoute = '/';

  static final GoRouter router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: initialRoute,
        name: 'dijkstra',
        builder: (context, state) => const DijkstraScreen(),
      ),
    ],
  );
}
