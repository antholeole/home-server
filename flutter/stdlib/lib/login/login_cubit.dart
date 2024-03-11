import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:stdlib/result.dart';

import 'login_state.dart';

/// We intentionally do not defer to hydrated cubit
/// because we want to "self" hydrate.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(super.initialState);


  Result<String, Exception> blah() {
    return Ok("hi");
  }

  SideEffect<Exception> login() {
    switch (blah()) {
      case Err(err: Exception some): 
        print(some);
      case Ok(value: String someString):
        print(someString);
      case Ok<dynamic>(value: dynamic o):
        print(o);
      case Err<dynamic>(err: dynamic s):
        print(s);
    }

    return Result.ok;
  }
}
