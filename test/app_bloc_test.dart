import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:testingbloc_course/apis/login_api.dart';
import 'package:testingbloc_course/apis/notes_api.dart';
import 'package:testingbloc_course/bloc/actions.dart';
import 'package:testingbloc_course/bloc/app_bloc.dart';
import 'package:testingbloc_course/bloc/app_state.dart';
import 'package:testingbloc_course/models.dart';

const Iterable<Note> mockNotes = [
  Note(note: 'Note 1'),
  Note(note: 'Note 2'),
  Note(note: 'Note 3')
];

@immutable
class DummyNotesApi implements NotesApiProtocol {
  final LoginHandle acceptedLoginHandle;
  final Iterable<Note>? notesToReturnForAcceptedLoginHandle;

  const DummyNotesApi({
    required this.acceptedLoginHandle,
    required this.notesToReturnForAcceptedLoginHandle,
  });

  const DummyNotesApi.empty()
      : acceptedLoginHandle = const LoginHandle.fooBar(),
        notesToReturnForAcceptedLoginHandle = null;

  @override
  Future<Iterable<Note>?> getNotes({required LoginHandle loginHandle}) async {
    if (loginHandle == acceptedLoginHandle) {
      return notesToReturnForAcceptedLoginHandle;
    } else {
      return null;
    }
  }
}

@immutable
class DummyLoginApi implements LoginApiProtocol {
  final String acceptedEmail;
  final String acceptedPassword;
  final LoginHandle handleToReturn;

  const DummyLoginApi({
    required this.acceptedEmail,
    required this.acceptedPassword,
    required this.handleToReturn,
  });

  const DummyLoginApi.empty()
      : acceptedEmail = '',
        acceptedPassword = '',
        handleToReturn = const LoginHandle.fooBar();

  @override
  Future<LoginHandle?> login({
    required String email,
    required String password,
  }) async {
    if (email == acceptedEmail && password == acceptedPassword) {
      return const LoginHandle.fooBar();
    } else {
      return null;
    }
  }
}

const acceptedLoginHandle = LoginHandle(token: 'foobar');

void main() {
  blocTest(
    'Initial state of the bloc should e AppState.empty()',
    build: () => AppBloc(
      loginApi: const DummyLoginApi.empty(),
      notesApi: const DummyNotesApi.empty(),
      acceptableLoginHandle: acceptedLoginHandle,
    ),
    verify: (appState) => expect(appState.state, const AppState.empty()),
  );

  blocTest(
    'Can we login with correct credentials?',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'foo@bar.com',
        acceptedPassword: 'foobar',
        handleToReturn: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi.empty(),
      acceptableLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) => appBloc.add(
      const LoginAction(email: 'foo@bar.com', password: 'foobar'),
    ),
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      )
    ],
  );

  blocTest(
    'We should not be able to log in with invalid credentials',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'foo@bar.com',
        acceptedPassword: 'foobaz',
        handleToReturn: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi.empty(),
      acceptableLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) => appBloc.add(
      const LoginAction(email: 'foo@bar.com', password: 'foobar'),
    ),
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: LoginErrors.invalidHandle,
        loginHandle: null,
        fetchedNotes: null,
      )
    ],
  );

  blocTest(
    'Load some notes with a valid login handle',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'foo@bar.com',
        acceptedPassword: 'foobar',
        handleToReturn: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi(
        acceptedLoginHandle: acceptedLoginHandle,
        notesToReturnForAcceptedLoginHandle: mockNotes,
      ),
      acceptableLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) {
      appBloc.add(
        const LoginAction(email: 'foo@bar.com', password: 'foobar'),
      );
      appBloc.add(
        const LoadNotesAction(),
      );
    },
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: mockNotes,
      )
    ],
  );
}
