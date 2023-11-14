import 'dart:async';

import 'package:fe/service_locator.dart';
import 'package:fe/services/clients/gql_client/auth_gql_client.dart';
import 'package:fe/stdlib/errors/failure.dart';
import 'package:fe/stdlib/errors/failure_status.dart';
import 'package:fe/stdlib/errors/handler.dart';
import 'package:fe/stdlib/shared_widgets/gql_operation.dart';
import 'package:fe/stdlib/theme/loader.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fe/gql/fake/fake.data.gql.dart';
import 'package:fe/gql/fake/fake.var.gql.dart';
import 'package:fe/gql/fake/fake.req.gql.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers/mocks.dart';
import '../../test_helpers/get_it_helpers.dart';
import '../../test_helpers/pump_app.dart';
import '../../test_helpers/stub_gql_response.dart';

void main() {
  setUpAll(() {
    registerFallbackValue<OperationRequest<GFakeGqlData, GFakeGqlVars>>(
        FakeRequest<GFakeGqlData, GFakeGqlVars>());
  });

  setUp(() {
    registerAllMockServices();
  });
  group('loader', () {
    //required so we can complete the future to clean up
    late Completer<OperationResponse<GFakeGqlData, GFakeGqlVars>> respCompleter;

    setUp(() {
      respCompleter = Completer();

      when(() =>
              getIt<AuthGqlClient>().request<GFakeGqlData, GFakeGqlVars>(any()))
          .thenAnswer((_) =>
              Stream.fromFuture(respCompleter.future.then((rc) => rc.data!)));
    });

    tearDown(() {
      respCompleter.complete(OperationResponse<GFakeGqlData, GFakeGqlVars>(
          operationRequest: FakeRequest<GFakeGqlData, GFakeGqlVars>(),
          data: GFakeGqlData.fromJson({'group_join_tokens': []})));
    });

    testWidgets('should build custom loader on loader', (tester) async {
      const loaderKey = Key('loaderkey');

      await tester.pumpApp(GqlOperation(
        onResponse: (_) => Container(),
        loader: Container(
          key: loaderKey,
        ),
        operationRequest: GFakeGqlReq(),
      ));

      expect(find.byKey(loaderKey), findsOneWidget);
    });

    testWidgets('should build standard loader on no loader', (tester) async {
      await tester.pumpApp(GqlOperation(
        onResponse: (_) => Container(),
        operationRequest: GFakeGqlReq(),
      ));

      expect(find.byType(Loader), findsOneWidget);
    });
  });

  group('on error', () {
    final fakeFailure = Failure(status: FailureStatus.GQLMisc);

    testWidgets('should call basic GQL error handler', (tester) async {
      stubGqlResponse<GFakeGqlData, GFakeGqlVars>(getIt<AuthGqlClient>(),
          error: (_) => fakeFailure);

      await tester.pumpApp(GqlOperation(
        onResponse: (_) => Container(),
        operationRequest: GFakeGqlReq(),
      ));

      await tester.pump();

      verify(() => getIt<Handler>().handleFailure(any(), any())).called(1);
    });
  });

  group('operation request prop', () {
    testWidgets('if not passed in should render loader', (tester) async {
      const renderKey = Key('value');

      await tester.pumpApp(GqlOperation(
        loader: Container(
          key: renderKey,
        ),
        onResponse: (_) => Container(),
      ));

      await tester.pump();

      expect(find.byKey(renderKey), findsOneWidget);
    });

    testWidgets('should call again if changed', (tester) async {
      stubGqlResponse<GFakeGqlData, GFakeGqlVars>(getIt<AuthGqlClient>(),
          data: (_) => GFakeGqlData.fromJson({'group_join_tokens': []})!);

      final controller = StreamController<GFakeGqlReq>();

      await tester.pumpApp(StreamBuilder<GFakeGqlReq>(
        stream: controller.stream,
        builder: (_, snapshot) => GqlOperation(
          operationRequest: snapshot.data,
          onResponse: (_) => Container(),
        ),
      ));

      controller.add(GFakeGqlReq((q) => q..requestId = 'first'));

      await tester.pump();

      controller.add(GFakeGqlReq((q) => q..requestId = 'second'));

      await tester.pump();

      verify(() =>
              getIt<AuthGqlClient>().request(any(that: isA<GFakeGqlReq>())))
          .called(2);
    });
  });
}
