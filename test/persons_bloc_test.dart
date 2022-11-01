import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';
import 'package:testingbloc_course/bloc/person.dart';
import 'package:testingbloc_course/bloc/persons_bloc.dart';

const mockedPerson1 = [
  Person(age: 20, name: 'Foo'),
  Person(age: 30, name: 'Bar')
];

const mockedPerson2 = [
  Person(age: 20, name: 'Foo'),
  Person(age: 30, name: 'Bar')
];

Future<Iterable<Person>> mockGetPerson1(String _) =>
    Future.value(mockedPerson1);

Future<Iterable<Person>> mockGetPerson2(String _) =>
    Future.value(mockedPerson2);

void main() {
  group('Testing bloc', () {
    //  write our test
    late PersonBloc bloc;

    setUp(() {
      bloc = PersonBloc();
    });

    blocTest<PersonBloc, FetchResult?>(
      'Test initial state',
      build: () => bloc,
      verify: (bloc) => expect(bloc.state, null),
    );

    //  fetch mock persons1 compare with fetchResult
    blocTest(
      'Mock retrieving persons from first iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
            const LoadPersonAction(url: 'dummy_url_1', loader: mockGetPerson1));
        bloc.add(
            const LoadPersonAction(url: 'dummy_url_1', loader: mockGetPerson1));
      },
      expect: () => [
        const FetchResult(persons: mockedPerson1, isRetrievedFromCache: false),
        const FetchResult(persons: mockedPerson1, isRetrievedFromCache: true),
      ],
    );

    //  fetch mock persons2 compare with fetchResult
    blocTest(
      'Mock retrieving persons from first iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
            const LoadPersonAction(url: 'dummy_url_2', loader: mockGetPerson2));
        bloc.add(
            const LoadPersonAction(url: 'dummy_url_2', loader: mockGetPerson2));
      },
      expect: () => [
        const FetchResult(persons: mockedPerson2, isRetrievedFromCache: false),
        const FetchResult(persons: mockedPerson2, isRetrievedFromCache: true),
      ],
    );
  });
}
