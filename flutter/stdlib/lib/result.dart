sealed class Result<T, E> {
  final T? _value;
  final E? _err;

  Result._(T? value, E? err)
      : _value = value,
        _err = err;

  bool get isOk => _err != null;

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
    final v = _err;
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
      return ef(_err!);
    }
  }


  static Result<void, Exception?> ok = Err(err: null) as Result<void, Exception?>;
}

class Ok<T> extends Result<T, Exception> {
  T get value => super._value!;

  Ok({required T value}) : super._(value, null);
}

class Err<E> extends Result {
  E get err => super._err!;

  Err({required E err}) : super._(null, err);
}

typedef SideEffect<E> = Result<void, E?>;


