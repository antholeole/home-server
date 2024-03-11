import 'package:get_it/get_it.dart';
import 'package:stdlib/config.dart';

final getIt = GetIt.instance;

void setup(
  Config config,  
  [void Function(GetIt)? more]
) {
  if (more != null) {
    more(getIt);
  }

  getIt.registerSingleton<Config>(config);
}