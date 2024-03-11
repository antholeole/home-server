class VoidCapture {
  int _ranNTimes = 0;

  void run() {
    _ranNTimes++;
  }

  void runA(dynamic arg) {
    _ranNTimes++;
  }

  bool get didRun => _ranNTimes > 0;
}