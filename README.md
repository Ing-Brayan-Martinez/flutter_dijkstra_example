# Flutter Dijkstra Visualizer

Aplicación multiplataforma de Flutter para visualizar el algoritmo de Dijkstra
en una cuadrícula interactiva. La lógica del algoritmo está separada de la UI y
expone su estado mediante Signals.

## Características

- Ejecutar o detener la búsqueda de un camino mínimo.
- Editar la cuadrícula con herramientas para muros, inicio y destino.
- Reiniciar el algoritmo sin eliminar muros o limpiar toda la cuadrícula.
- Ajustar la velocidad de la animación.
- Consultar el estado, los nodos visitados, la longitud del camino y el tiempo.
- Navegación con GoRouter e inyección del controlador con MultiProvider.

## Arquitectura

```text
lib/
├── domain/
│   ├── config/       # Logging
│   ├── controllers/  # Algoritmo y estado reactivo con Signals
│   └── model/        # Nodos y estadísticas
└── presentation/
    ├── provider/     # Inyección de dependencias con Provider
    ├── routes/       # Configuración de GoRouter
    ├── screens/      # Pantalla principal
    ├── theme/        # Tema Material 3 oscuro
    └── widgets/      # Cuadrícula, controles, leyenda y estadísticas
```

El controlador de dominio solo utiliza Dart y Signals; no depende de Flutter ni
de GetX. La capa de presentación consume sus señales y llama sus operaciones.

## Requisitos

- Flutter 3.38.9
- Dart ^3.10

## Desarrollo

```bash
flutter pub get
dart format lib/ test/
flutter analyze
flutter test
```

Para iniciar la aplicación:

```bash
flutter run
```
