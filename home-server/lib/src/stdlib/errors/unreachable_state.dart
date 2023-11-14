class UnreachableStateError extends Error {
  Object state;

  UnreachableStateError(this.state);

  @override
  String toString() {
    return 'unreachable state: ${state.toString()}';
  }
}
