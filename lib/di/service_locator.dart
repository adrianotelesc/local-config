// TODO: Use GetIt instead of this.
abstract final class ServiceLocator {
  static final _instances = <Type, Object>{};

  static void register<T extends Object>(T instance) {
    _instances[T] = instance;
  }

  static T locate<T>() {
    final instance = _instances[T];

    return instance as T;
  }

  static void reset() {
    _instances.clear();
  }
}
