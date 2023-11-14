import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:fe/config.dart';
import 'package:fe/pages/main/cubit/main_cubit.dart';
import 'package:fe/service_locator.dart';
import 'package:fe/services/toaster/cubit/data_carriers/toast.dart';
import 'package:fe/services/toaster/cubit/toaster_cubit.dart';
import 'package:fe/stdlib/errors/failure.dart';
import 'package:fe/stdlib/errors/failure_status.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class Handler {
  final http.Client _client = getIt<http.Client>();
  final Config _config = getIt<Config>();
  final Connectivity _connectivity = getIt<Connectivity>();

  Future<void> reportUnknown(Object e) async {
    debugPrint(e.toString());
  }

  Future<Failure?> checkConnectivity() async {
    if (!(await isConnected())) {
      return Failure(status: FailureStatus.NoConn);
    }

    final hasServerConnection = await this.hasServerConnection();
    if (!hasServerConnection) {
      return Failure(status: FailureStatus.ServersDown);
    }
  }

  Future<bool> isConnected() async {
    var connectivityResult = await (_connectivity.checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> hasServerConnection() async {
    try {
      final resp = await _client.get(Uri(
          host: _config.hasuraHost,
          pathSegments: ['healthz'],
          port: _config.hasuraPort,
          scheme: _config.transportIsSecure ? 'https' : 'http'));
      return resp.statusCode == 200;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<Failure> basicGqlErrorHandler(OperationResponse resp) async {
    final errors = resp.graphqlErrors;

    if (resp.linkException != null) {
      if (resp.linkException!.originalException is Failure) {
        return resp.linkException!.originalException;
      }
    }

    if (errors != null) {
      StringBuffer errorBuff = StringBuffer();
      errors.forEach((error) {
        errorBuff.write(error.message);
      });
      return Failure(
          message: errorBuff.toString(), status: FailureStatus.GQLMisc);
    }

    final disconnectedFailure = await checkConnectivity();

    if (disconnectedFailure != null) {
      return disconnectedFailure;
    }

    return Failure(status: FailureStatus.Unknown);
  }

  void handleFailure(Failure f, BuildContext context,
      {String? withPrefix, bool toast = true}) {
    if (f.status.fatal) {
      context.read<MainCubit>().logOut(withError: f.message);
    } else {
      String errorString = f.message;

      if (withPrefix != null) {
        errorString = withPrefix + ': ' + errorString;
      }

      if (toast) {
        context.read<ToasterCubit>().add(Toast(
              message: errorString,
              type: ToastType.Error,
            ));
      }
    }
  }
}
