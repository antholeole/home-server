import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fe/pages/main/cubit/main_cubit.dart';
import 'package:fe/service_locator.dart';
import 'package:fe/services/toaster/cubit/data_carriers/toast.dart';
import 'package:fe/services/toaster/cubit/toaster_cubit.dart';
import 'package:fe/stdlib/errors/failure.dart';
import 'package:fe/stdlib/errors/failure_status.dart';
import 'package:fe/stdlib/errors/handler.dart';
import 'package:ferry/ferry.dart';
import 'package:fe/gql/fake/fake.req.gql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../test_helpers/mocks.dart';
import '../../test_helpers/get_it_helpers.dart';
import '../../test_helpers/reset_mock_bloc.dart';

void main() {
  setUpAll(() {
    registerFallbackValue<Uri>(Uri(host: 'google.com'));
  });

  setUp(() {
    registerAllMockServices();
  });

  group('check connectivity', () {
    test('should return no conn if no internet connection', () async {
      when(() => getIt<Connectivity>().checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final handler = Handler();

      expect(await handler.checkConnectivity(),
          equals(Failure(status: FailureStatus.NoConn)));
    });

    test('should return servers down if ping request fails', () async {
      when(() => getIt<Connectivity>().checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(() => getIt<http.Client>().get(any()))
          .thenAnswer((_) async => http.Response('blah', 500));

      final handler = Handler();

      expect(await handler.checkConnectivity(),
          equals(Failure(status: FailureStatus.ServersDown)));
    });

    test('should return null if has both connections', () async {
      when(() => getIt<Connectivity>().checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(() => getIt<http.Client>().get(any()))
          .thenAnswer((_) async => http.Response('b', 200));

      final handler = Handler();

      expect(await handler.checkConnectivity(), isNull);
    });
  });

  group('basic gql error handler', () {
    group('link exception', () {
      test('inner exception is failure should return unwrapped failure',
          () async {
        final failure = Failure(status: FailureStatus.Unknown);

        final handler = Handler();

        expect(
            await handler.basicGqlErrorHandler(OperationResponse(
                operationRequest: GFakeGqlReq(),
                linkException: FakeLinkException(failure))),
            equals(failure));
      });
    });

    test('should write all gql errors to custom error', () async {
      const msgs = ['first message hi', 'im the second one', 'finally last'];

      final handler = Handler();

      final result = await handler.basicGqlErrorHandler(OperationResponse(
          operationRequest: GFakeGqlReq(),
          graphqlErrors: msgs.map((e) => GraphQLError(message: e)).toList()));

      expect(
          result,
          isA<Failure>()
              .having((f) => f.status, 'status', FailureStatus.GQLMisc));

      for (final msg in msgs) {
        expect(result.message, contains(msg));
      }
    });

    test('should return connectivity check failure if no errors', () async {
      when(() => getIt<Connectivity>().checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final handler = Handler();

      expect(
          await handler.basicGqlErrorHandler(
              OperationResponse(operationRequest: GFakeGqlReq())),
          equals(Failure(status: FailureStatus.NoConn)));
    });

    test('should return unknown if all else fails', () async {
      when(() => getIt<Connectivity>().checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(() => getIt<http.Client>().get(any()))
          .thenAnswer((_) async => http.Response('b', 200));

      final handler = Handler();

      expect(
          await handler.basicGqlErrorHandler(
              OperationResponse(operationRequest: GFakeGqlReq())),
          equals(Failure(status: FailureStatus.Unknown)));
    });
  });

  group('handle failure', () {
    final mockMainCubit = MockMainCubit.getMock();
    final mockToasterCubit = MockToasterCubit.getMock();

    final nonFatal = Failure(status: FailureStatus.ServersDown);

    setUp(() {
      resetMockBloc(mockMainCubit);
      resetMockBloc(mockToasterCubit);
    });

    testWidgets('should log out if fatal error', (tester) async {
      final fatalFailure = Failure(status: FailureStatus.RefreshFail);
      final handler = Handler();
      late BuildContext context;

      whenListen(mockMainCubit, const Stream<MainState>.empty());
      when(() => mockMainCubit.logOut(withError: any(named: 'withError')))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(BlocProvider<MainCubit>(
        create: (context) => mockMainCubit,
        child: Builder(builder: (ctx) {
          context = ctx;
          return Container();
        }),
      ));

      handler.handleFailure(fatalFailure, context);

      verify(() => mockMainCubit.logOut(withError: any(named: 'withError')))
          .called(1);
    });

    testWidgets('should toast if toast = true', (tester) async {
      final handler = Handler();
      late BuildContext context;

      whenListen(mockToasterCubit, const Stream<ToasterState>.empty());
      when(() => mockMainCubit.logOut(withError: any(named: 'withError')))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider<MainCubit>(create: (_) => mockMainCubit),
          BlocProvider<ToasterCubit>(create: (_) => mockToasterCubit),
        ],
        child: Builder(builder: (ctx) {
          context = ctx;
          return Container();
        }),
      ));

      handler.handleFailure(nonFatal, context);

      tester.binding.scheduleFrame();
      await tester.pump();
      verify(() => mockToasterCubit.add(any(
          that: isA<Toast>()
              .having((toast) => toast.type, 'type', ToastType.Error))));
    });

    testWidgets('should not toast if toast = false', (tester) async {
      final handler = Handler();
      late BuildContext context;

      whenListen(mockToasterCubit, const Stream<ToasterState>.empty());
      when(() => mockMainCubit.logOut(withError: any(named: 'withError')))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider<MainCubit>(create: (_) => mockMainCubit),
          BlocProvider<ToasterCubit>(create: (_) => mockToasterCubit),
        ],
        child: Builder(builder: (ctx) {
          context = ctx;
          return Container();
        }),
      ));

      handler.handleFailure(nonFatal, context, toast: false);

      tester.binding.scheduleFrame();
      await tester.pump();
      verifyNever(() => mockToasterCubit.add(any()));
    });

    group('error string', () {
      Future<String> getMessage(Failure failure, WidgetTester tester,
          {String? prefix}) async {
        final handler = Handler();
        late BuildContext context;

        whenListen(mockToasterCubit, const Stream<ToasterState>.empty());

        await tester.pumpWidget(MultiBlocProvider(
          providers: [
            BlocProvider<MainCubit>(create: (_) => mockMainCubit),
            BlocProvider<ToasterCubit>(create: (_) => mockToasterCubit),
          ],
          child: Builder(builder: (ctx) {
            context = ctx;
            return Container();
          }),
        ));

        handler.handleFailure(failure, context,
            withPrefix: prefix, toast: true);

        tester.binding.scheduleFrame();
        await tester.pump();

        return (verify(() => mockToasterCubit.add(captureAny())).captured.first
                as Toast)
            .message;
      }

      testWidgets('should default to status message', (tester) async {
        expect(
            await getMessage(
                Failure(status: FailureStatus.ServersDown), tester),
            equals(FailureStatus.ServersDown.message));
      });

      testWidgets('should use provided message if possible', (tester) async {
        const message = 'hi';

        expect(
            await getMessage(
                Failure(status: FailureStatus.ServersDown, message: message),
                tester),
            equals(message));
      });

      testWidgets('should add prefix if provided', (tester) async {
        const string = 'hi';
        const prefix = 'pfx';

        final message = await getMessage(
            Failure(status: FailureStatus.ServersDown, message: string), tester,
            prefix: prefix);

        expect(message, contains(string));
        expect(message, contains(prefix));
      });
    });
  });
}
