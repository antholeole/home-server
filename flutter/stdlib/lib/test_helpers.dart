class VoidCapture {
  int _ranNTimes = 0;

  void run() {
    _ranNTimes++;
  }

  bool get didRun => _ranNTimes > 0;
}