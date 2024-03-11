class Result<T, E> {
  final T? _value;
  final E? _error;

  Result._internal(T? value, E? error)
      : _value = value,
        _error = error;

  factory Result.value(T value) => Result._internal(value, null);
  factory Result.error(E err) => Result._internal(null, err);

  void tap<O>(Function<Result<T, E> O> f) {
    f()
  }
}
