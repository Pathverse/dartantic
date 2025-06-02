import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartantic/dartantic.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:core';
// Test model with @dttBloc annotation
part 'zbloc_test.dartantic.g.dart';
part 'zbloc_test.bloc.cubit.g.dart';
part 'zbloc_test.bloc.event.g.dart';
part 'zbloc_test.bloc.state.g.dart';

@dttModel
@dttBloc
class TestUser with _$TestUserMixin {
  final String name;
  final int age;
  final String? email;

  const TestUser({required this.name, required this.age, this.email});

  // Custom validation
  static bool _dttvalidate_age(int age) => age >= 0 && age <= 150;

  // Custom preprocessing
  static String _dttpreprocess_name(String name) => name.trim();
}

void main() {
  group('DttBlocTestUserCubit', () {
    late DttBlocTestUserCubit cubit;

    setUp(() async {
      cubit = DttBlocTestUserCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is DttBlocTestUserInitial', () {
      expect(cubit.state, isA<DttBlocTestUserInitial>());
    });

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits [loading, data] when loadData succeeds',
      build: () => cubit,
      act:
          (cubit) async => await cubit.loadData({
            'name': 'John Doe',
            'age': 30,
            'email': 'john@example.com',
          }),
      expect:
          () => [
            isA<DttBlocTestUserLoading>(),
            isA<DttBlocTestUserStateData>()
                .having((state) => state.name, 'name', 'John Doe')
                .having((state) => state.age, 'age', 30)
                .having((state) => state.email, 'email', 'john@example.com'),
          ],
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits [loading, error] when loadData fails validation',
      build: () => cubit,
      act:
          (cubit) async => await cubit.loadData({
            'name': 'John Doe',
            'age': 200, // Invalid age
            'email': 'john@example.com',
          }),
      expect:
          () => [
            isA<DttBlocTestUserLoading>(),
            isA<DttBlocTestUserError>().having(
              (state) => state.message,
              'message',
              'Invalid age: age failed custom validation',
            ),
          ],
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits [loading, error] when loadData has invalid data type',
      build: () => cubit,
      act:
          (cubit) async => await cubit.loadData({
            'name': 'John Doe',
            'age': 'not a number', // Invalid type
            'email': 'john@example.com',
          }),
      expect:
          () => [isA<DttBlocTestUserLoading>(), isA<DttBlocTestUserError>()],
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits updated state when updateName is called',
      build: () => cubit,
      setUp: () async {
        await cubit.loadData({
          'name': 'John Doe',
          'age': 30,
          'email': 'john@example.com',
        });
      },
      act: (cubit) => cubit.updateName('Jane Doe'),
      expect:
          () => [
            isA<DttBlocTestUserStateData>().having(
              (state) => state.name,
              'name',
              'Jane Doe',
            ),
          ],
      verify: (cubit) {
        final state = cubit.state as DttBlocTestUserStateData;
        expect(state.age, equals(30));
        expect(state.email, equals('john@example.com'));
      },
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits updated state when updateAge is called with valid age',
      build: () => cubit,
      setUp: () async {
        await cubit.loadData({
          'name': 'John Doe',
          'age': 30,
          'email': 'john@example.com',
        });
      },
      act: (cubit) => cubit.updateAge(25),
      expect:
          () => [
            isA<DttBlocTestUserStateData>().having(
              (state) => state.age,
              'age',
              25,
            ),
          ],
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits error state when updateAge is called with invalid age',
      build: () => cubit,
      setUp: () async {
        await cubit.loadData({
          'name': 'John Doe',
          'age': 30,
          'email': 'john@example.com',
        });
      },
      act: (cubit) => cubit.updateAge(200), // Invalid age
      expect:
          () => [
            isA<DttBlocTestUserError>().having(
              (state) => state.message,
              'message',
              'Invalid age: age failed custom validation',
            ),
          ],
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits updated state when updateEmail is called',
      build: () => cubit,
      setUp: () async {
        await cubit.loadData({
          'name': 'John Doe',
          'age': 30,
          'email': 'john@example.com',
        });
      },
      act: (cubit) => cubit.updateEmail('jane@example.com'),
      expect:
          () => [
            isA<DttBlocTestUserStateData>().having(
              (state) => state.email,
              'email',
              'jane@example.com',
            ),
          ],
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits [loading, data] when saveData succeeds',
      build: () => cubit,
      setUp: () async {
        await cubit.loadData({
          'name': 'John Doe',
          'age': 30,
          'email': 'john@example.com',
        });
      },
      act: (cubit) async => await cubit.saveData(),
      expect:
          () => [
            isA<DttBlocTestUserLoading>(),
            anyOf([
              isA<DttBlocTestUserStateData>(),
              isA<DttBlocTestUserError>().having(
                (state) => state.message,
                'message',
                'Invalid data',
              ),
            ]),
          ],
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'emits initial state when reset is called',
      build: () => cubit,
      setUp: () async {
        await cubit.loadData({
          'name': 'John Doe',
          'age': 30,
          'email': 'john@example.com',
        });
      },
      act: (cubit) => cubit.reset(),
      expect: () => [isA<DttBlocTestUserInitial>()],
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'validates state correctly',
      build: () => cubit,
      setUp: () async {
        await cubit.loadData({
          'name': 'John Doe',
          'age': 30,
          'email': 'john@example.com',
        });
      },
      act: (cubit) => cubit.validate(),
      expect: () => [], // No state changes
      verify: (cubit) {
        expect(cubit.validate(), isTrue);
      },
    );

    blocTest<DttBlocTestUserCubit, DttBlocTestUserState>(
      'fails validation with invalid age',
      build: () => cubit,
      setUp: () async {
        await cubit.loadData({
          'name': 'John Doe',
          'age': 200, // Invalid age
          'email': 'john@example.com',
        });
      },
      act: (cubit) => cubit.validate(),
      expect: () => [], // No state changes
      verify: (cubit) {
        expect(cubit.validate(), isFalse);
      },
    );

    test('preprocessing is applied to name updates', () async {
      await cubit.loadData({
        'name': 'John Doe',
        'age': 30,
        'email': 'john@example.com',
      });

      cubit.updateName('  Jane Doe  '); // With extra spaces
      final state = cubit.state as DttBlocTestUserStateData;
      expect(state.name, equals('Jane Doe')); // Should be trimmed
    });
  });
}
