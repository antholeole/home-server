abstract class Config {
  bool get isDebug;
}

class LocalConfig extends Config {
  @override
  bool get isDebug => true;
}