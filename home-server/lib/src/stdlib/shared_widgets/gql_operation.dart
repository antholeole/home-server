import 'package:fe/services/clients/gql_client/auth_gql_client.dart';
import 'package:fe/stdlib/errors/failure.dart';
import 'package:fe/stdlib/errors/handler.dart';
import 'package:fe/stdlib/theme/loader.dart';
import 'package:ferry/ferry.dart';
import 'package:ferry/typed_links.dart';
import 'package:flutter/material.dart';
import '../../service_locator.dart';

class GqlOperation<TData, TVars> extends StatefulWidget {
  //overrides the lookup context in contexts where widget in inserted
  //in the tree where it cannot access the main cubits.
  final BuildContext? _providerReadableContext;
  final OperationRequest<TData, TVars>? operationRequest;
  final Widget? loader;
  final String? errorText;
  final Widget? error;

  final Widget Function(TData) onResponse;

  const GqlOperation(
      {this.operationRequest,
      required this.onResponse,
      this.loader,
      this.error,
      BuildContext? providerReadableContext,
      this.errorText})
      : _providerReadableContext = providerReadableContext;

  @override
  _GqlOperationState<TData, TVars> createState() =>
      _GqlOperationState<TData, TVars>();
}

class _GqlOperationState<TData, TVars>
    extends State<GqlOperation<TData, TVars>> {
  final _client = getIt<AuthGqlClient>();
  final _handler = getIt<Handler>();
  TData? _resultFromCache;

  @override
  void didUpdateWidget(GqlOperation<TData, TVars> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operationRequest != widget.operationRequest) {
      setState(() => _resultFromCache = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.operationRequest == null) {
      return _buildLoader();
    }

    return StreamBuilder<TData>(
        stream: widget.operationRequest != null
            ? _client.request(widget.operationRequest!)
            : null,
        builder: _builder);
  }

  Widget _builder(BuildContext context, AsyncSnapshot<TData> snapshot) {
    if (snapshot.connectionState != ConnectionState.active &&
        snapshot.connectionState != ConnectionState.done) {
      return _buildLoader();
    }

    if (snapshot.error is Failure) {
      _handler.handleFailure(
          snapshot.error as Failure, widget._providerReadableContext ?? context,
          withPrefix: widget.errorText);

      return _resultFromCache != null
          ? widget.onResponse(_resultFromCache!)
          : widget.error ??
              Text(
                widget.errorText ?? 'error',
                style: const TextStyle(color: Colors.red),
              );
    }

    final response = snapshot.data;
    _resultFromCache = response;
    return widget.onResponse(response!);
  }

  Widget _buildLoader() {
    return Center(
      child: widget.loader ??
          const Loader(
            size: 12,
          ),
    );
  }
}
