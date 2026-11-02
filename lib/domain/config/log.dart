import 'package:signale/signale.dart' as signale;

/// Logger unificado de la aplicación utilizando signale.
abstract class Log {
  static void i(Object? message) {
    signale.Log.i(message);
  }

  static void e(Object? error, [StackTrace? stackTrace]) {
    signale.Log.e('${error.toString()} ${stackTrace ?? ''}');
  }

  static void d(Object? message) {
    signale.Log.d(message);
  }

  static void w(Object? message) {
    signale.Log.w(message);
  }

  static void success(Object? message) {
    signale.Log.i('[ÉXITO] $message');
  }
}
