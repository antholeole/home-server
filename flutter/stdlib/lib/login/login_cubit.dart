import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:stdlib/result.dart';

import 'login_state.dart';

/// We intentionally do not defer to hydrated cubit
/// because we want to "self" hydrate.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(super.initialState);

  SideEffect<Throwable> login() {
    
  }
}
