import 'package:equatable/equatable.dart';
import 'package:fe/stdlib/errors/failure_status.dart';
import 'package:flutter/foundation.dart';

@immutable
class Failure extends Equatable {
  final String message;
  final FailureStatus status;

  Failure({String? message, required this.status})
      : message = message ?? status.message;

  @override
  List<Object?> get props => [status, message];
}
