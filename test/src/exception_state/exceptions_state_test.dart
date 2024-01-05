import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('exceptions state', () {
    group('DataClientException', () {
      final testException = Exception('Test exception');
      final dataClientException = DataClientException<String>(
        testException,
        StackTrace.current,
      );
      test('should assign the client exception correctly', () {
        expect(dataClientException.clientException, testException);
        expect(dataClientException.clientException, isA<Exception>());
        expect(
          dataClientException.clientException.toString(),
          'Exception: Test exception',
        );
      });
      test('should correct toString', () {
        expect(
          dataClientException.toString(),
          'DataClientException<String>(clientException: Exception: Test exception)',
        );
      });
    });
    group('DataParseException', () {
      final Exception exception = Exception('Parse error');
      final DataParseException<String> dataParseException =
          DataParseException<String>(exception, StackTrace.current);
      test('should assign the parse exception correctly', () {
        expect(dataParseException.parseException, equals(exception));
      });
      test('should correct toString', () {
        expect(
          dataParseException.toString(),
          'DataParseException<String>(parseException: Exception: Parse error)',
        );
      });
    });
    group('DataHttpException', () {
      final DataHttpException<String> dataHttpException =
          DataHttpException<String>(
        exception: null,
        httpException: HttpException.unauthorized,
        stackTrace: StackTrace.current,
        statusCode: 401,
      );
      test('should assign the http exception correctly', () {
        expect(
          dataHttpException.httpException,
          equals(HttpException.unauthorized),
        );
      });
      test('should correct toString', () {
        expect(
          dataHttpException.toString(),
          'DataHttpException<String>(httpException: HttpException.unauthorized, statusCode: 401)',
        );
      });
    });
    group('DataNetworkException', () {
      final DataNetworkException<String> dataNetworkException =
          DataNetworkException<String>(
        NetworkException.noInternetConnection,
        StackTrace.current,
      );
      test('should assign the network exception correctly', () {
        expect(
          dataNetworkException.networkException,
          equals(NetworkException.noInternetConnection),
        );
      });

      test('should correct toString', () {
        expect(
          dataNetworkException.toString(),
          'DataNetworkException<String>(networkException: NetworkException.noInternetConnection)',
        );
      });
    });
    group('DataCacheException', () {
      final DataCacheException<String> dataCacheException =
          DataCacheException<String>(
        CacheException.unknown,
        StackTrace.current,
      );
      test('should assign the cache exception correctly', () {
        expect(
          dataCacheException.cacheException,
          equals(CacheException.unknown),
        );
      });

      test('should correct toString', () {
        expect(
          dataCacheException.toString(),
          'DataCacheException<String>(cacheException: CacheException.unknown)',
        );
      });
    });
    group('DataInvalidInputException', () {
      final DataInvalidInputException<String> dataInvalidInputException =
          DataInvalidInputException<String>(
        InvalidInputException.unknown,
        StackTrace.current,
      );
      test('should assign the cache exception correctly', () {
        expect(
          dataInvalidInputException.invalidInputException,
          equals(InvalidInputException.unknown),
        );
      });

      test('should correct toString', () {
        expect(
          dataInvalidInputException.toString(),
          'DataInvalidInputException<String>(invalidInputException: InvalidInputException.unknown)',
        );
      });
    });
  });
}
