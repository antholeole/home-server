import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stdlib/uuid_type.dart';

part 'login_state.freezed.dart';
part 'login_state.g.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.loggedIn({
    @CustomUuidConverter() required UuidType userId,
  }) = _LoggedInLoginState;

  const factory LoginState.loading() = _LoadingLoginState;
  const factory LoginState.loggedOut() = _LoggedOutLoginState;

  factory LoginState.fromJson(Map<String, Object?> json)
      => _$LoginStateFromJson(json);
}