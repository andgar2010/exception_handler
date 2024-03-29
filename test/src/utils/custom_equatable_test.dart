import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

class TestClass extends CustomEquatable {
  const TestClass({required this.name, this.age, this.height});

  final int? age;
  final double? height;
  final String name;

  @override
  Map<String, Object?> get namedProps =>
      {'name': name, 'age': age, 'height': height};
}

void main() {
  group(
    'CustomEquatable Tests',
    () {
      test('toString should return correct format', () {
        const instance = TestClass(name: 'John Doe', age: 30, height: 1.5);
        const expectedString =
            'TestClass(name: "John Doe", age: 30, height: 1.5)';
        expect(instance.toString(), equals(expectedString));
      });
      test('toString should return correct format null', () {
        const instance = TestClass(name: 'John Doe');
        const expectedString =
            'TestClass(name: "John Doe", age: null, height: null)';
        expect(instance.toString(), equals(expectedString));
      });

      test('Equatable properties should work correctly', () {
        const instance1 = TestClass(name: 'John', age: 25);
        const instance2 = TestClass(name: 'John', age: 25);
        const instance3 = TestClass(name: 'Jane', age: 30);

        expect(instance1, equals(instance2));
        expect(instance1, isNot(equals(instance3)));
      });
    },
  );
}
