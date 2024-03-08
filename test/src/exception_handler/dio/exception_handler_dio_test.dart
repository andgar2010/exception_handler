import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_exception/http_exception.dart';
import 'package:http_status/http_status.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DioExceptionHandler dioExceptionHandler = DioExceptionHandler();

  group('DioExceptionHandler Tests', () {
    final mockDio = MockDio();
    late MockApiHandler<Response, String> mockApiHandler;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockApiHandler = MockApiHandler<Response, String>();
      mockConnectivity = MockConnectivity();
      DioExceptionHandler.connectivity = mockConnectivity;
    });
    test('Successful API call returns parsed data', () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'key': 'value'},
          statusCode: 200,
        ),
      );

      final ResultState<String> result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (Object? data) => (data as Map)['key'] as String,
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      switch (result) {
        case SuccessState<String>(:final String data):
          success = data;
        case FailureState<String>(:final ExceptionState<String> exception):
          failure = exception;
      }

      expect(failure, isNull);
      expect(success, 'value');
    });

    test('API call with 401 status code returns unauthorized exception',
        () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
        ),
      );

      final result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (Object? data) => data as String,
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      switch (result) {
        case SuccessState<String>(:final String data):
          success = data;
        case FailureState<String>(:final ExceptionState<String> exception):
          failure = exception;
      }

      expect(success, isNull);
      expect(failure, isA<DataHttpExceptionState>());
      expect(
        (failure as DataHttpExceptionState).httpException,
        HttpStatus.fromCode(401).exception(),
      );
    });

    test('API call with no internet connection returns network exception',
        () async {
      when(() => mockApiHandler.apiCall())
          .thenThrow(DioException(requestOptions: RequestOptions()));

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final result = await dioExceptionHandler.callApi(mockApiHandler);

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState<String>():
          fail('Expected failure but got success');
        case FailureState<String>(:final ExceptionState<String> exception):
          expect(exception, isA<DataNetworkExceptionState>());
      }
    });
    test('API call with client exception', () async {
      when(() => mockDio.get<dynamic>(any())).thenThrow(Exception('Client Error'));

      final result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (Object? data) => data as String,
        ),
      );

      String? success;
      ExceptionState<String>? failure;

      switch (result) {
        case SuccessState<String>(:final String data):
          success = data;
        case FailureState<String>(:final ExceptionState<String> exception):
          failure = exception;
      }

      expect(success, isNull);
      expect(failure, isA<DataClientExceptionState>());
    });

    test('API call with parsing error', () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: 'Invalid data',
          statusCode: 200,
        ),
      );

      final ResultState<String> result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (Object? data) =>
              int.parse(data as String).toString(), // Intentional parse error
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      switch (result) {
        case SuccessState<String>(:final String data):
          success = data;
        case FailureState<String>(:final ExceptionState<String> exception):
          failure = exception;
      }

      expect(success, isNull);
      expect(failure, isA<DataParseExceptionState>());
    });

    test('should return FailureState with DataHttpException for 3xx error',
        () async {
      final ResultState result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () async => Response<dynamic>(
            requestOptions: RequestOptions(path: ''),
            statusCode: 300,
          ),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          expect(
            (exception as DataHttpExceptionState).httpException,
            equals(HttpStatus.fromCode(300).exception()),
          );
      }
    });
    test('should return FailureState with DataHttpException for 4xx error',
        () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );
      final ResultState result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpStatus.fromCode(400).exception()),
            );
          }
      }
    });
    test('should return FailureState with DataHttpException for 404 error',
        () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      );
      final ResultState result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpStatus.fromCode(404).exception()),
            );
          }
      }
    });

    test('should return FailureState with DataHttpException for 500 error',
        () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );
      final ResultState result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (res) {},
        ),
      );
      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpStatus.fromCode(500).exception()),
            );
          }
      }
    });
    test('should return FailureState with DataHttpException for 501 error',
        () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 501,
        ),
      );
      final ResultState result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpStatus.fromCode(501).exception()),
            );
          }
      }
    });
    test('should return FailureState with DataHttpException for 600 error',
        () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 600,
        ),
      );
      final ResultState result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(
                HttpException(
                  httpStatus: HttpStatus(
                    code: 600,
                    name: 'unknown_HttpStatus',
                    description: 'unknown_description',
                  ),
                  detail:
                      'exception: Invalid argument (code): Unrecognized status code. Use the HttpStatus constructor for custom codes: 600',
                ),
              ),
            );
          }
      }
    });

    test('handles DioException on API call', () async {
      when(() => mockApiHandler.apiCall()).thenThrow(
        MockDioException(type: DioExceptionType.connectionTimeout),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final ResultState<String> result =
          await dioExceptionHandler.callApi(mockApiHandler);

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataNetworkExceptionState>());
          if (exception is DataNetworkExceptionState) {
            expect(
              exception.message,
              equals('NetworkException.timeOutException'),
            );
          }
      }
      expect(result.exception, isA<DataNetworkExceptionState>());
    });
    test('handles DioExceptionType.sendTimeout on API call', () async {
      when(() => mockApiHandler.apiCall()).thenThrow(
        MockDioException(type: DioExceptionType.sendTimeout),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final ResultState<String> result =
          await dioExceptionHandler.callApi(mockApiHandler);

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataNetworkExceptionState>());
          if (exception is DataNetworkExceptionState) {
            expect(
              exception.message,
              equals('NetworkException.sendTimeout'),
            );
          }
      }
      expect(result.exception, isA<DataNetworkExceptionState>());
    });
    test('handles DioExceptionType.unknown on API call', () async {
      when(() => mockApiHandler.apiCall()).thenThrow(
        MockDioException(type: DioExceptionType.unknown),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final ResultState<String> result =
          await dioExceptionHandler.callApi(mockApiHandler);

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:final ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(
                HttpException(
                  httpStatus: HttpStatus(
                    code: 0,
                    name: 'unknown_HttpStatus',
                    description: 'unknown_description',
                  ),
                  detail: '',
                ),
              ),
            );
          }
      }
      expect(result.exception, isA<DataHttpExceptionState>());
    });

    test('handles general exception on API call', () async {
      final exception = Exception('General error');
      when(() => mockApiHandler.apiCall()).thenThrow(exception);
      final result = await dioExceptionHandler.callApi(mockApiHandler);

      expect(result, isA<FailureState>());
      expect(
        (result as FailureState).exception,
        isA<DataClientExceptionState>(),
      );
    });
    test('API call with unknown error', () async {
      when(() => mockDio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: 'Invalid data',
          statusCode: 200,
        ),
      );

      final ResultState<String> result = await dioExceptionHandler.callApi(
        ApiHandler(
          apiCall: () => mockDio.get<dynamic>('test'),
          parserModel: (Object? data) {
            throw Exception('Error Unknown'); // Intentional error
          },
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      switch (result) {
        case SuccessState<String>(:final String data):
          success = data;
        case FailureState<String>(:final ExceptionState<String> exception):
          failure = exception;
      }

      expect(success, isNull);
      expect(failure, isA<DataUnknownExceptionState>());
    });
  });
}
