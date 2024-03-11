class Result<T, E> {
  final T? _value;
  final E? _error;

  Result._internal(T? value, E? error)
      : _value = value,
        _error = error;

  factory Result.value(T value) => Result._internal(value, null);
  factory Result.error(E err) => Result._internal(null, err);

  Result<T, E> tap(Function(Result<T, E>) f) {
    f(this);
    return this;
  }

  H? onValue<H>(H? Function(T) f) {
    final v = _value;
    if (v != null) {
      return f(v);
    }

    return null;
  }

  H? onErr<H>(H? Function(E) f) {
    final v = _error;
    if (v != null) {
      return f(v);
    }

    return null;
  }

  H on<H>(
    H Function(T) vf,
    H Function(E) ef,
  ) {
    final v = _value;
    if (v != null) {
      return vf(v);
    } else {
      // ignore: null_check_on_nullable_type_parameter
      return ef(_error!);
    }
  }
}

typedef SideEffect<E> = Result<void, E>;
