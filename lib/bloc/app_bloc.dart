import 'package:bloc/bloc.dart';
import '../apis/notes_api.dart';
import '../bloc/actions.dart';
import '../models.dart';

import '../apis/login_api.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppAction, AppState> {
  final LoginApiProtocol loginApi;
  final NotesApiProtocol notesApi;
  final LoginHandle acceptableLoginHandle;

  AppBloc({
    required this.loginApi,
    required this.notesApi,
    required this.acceptableLoginHandle,
  }) : super(const AppState.empty()) {
    on<LoginAction>(
      (event, emit) async {
        //start loading
        emit(
          const AppState(
            isLoading: true,
            loginErrors: null,
            loginHandle: null,
            fetchedNotes: null,
          ),
        );
        //  log the user in
        final loginHandle =
            await loginApi.login(email: event.email, password: event.password);
        emit(
          AppState(
            isLoading: false,
            loginErrors: loginHandle == null ? LoginErrors.invalidHandle : null,
            loginHandle: loginHandle,
            fetchedNotes: null,
          ),
        );
      },
    );
    on<LoadNotesAction>(
      (event, emit) async {
        //start loading
        emit(
          AppState(
            isLoading: true,
            loginErrors: null,
            loginHandle: state.loginHandle,
            fetchedNotes: null,
          ),
        );
        //  get the login handle
        final loginHandle = state.loginHandle;
        if (loginHandle != acceptableLoginHandle) {
          //invalid login handle, cannot fetch notes
          emit(
            AppState(
              isLoading: false,
              loginErrors: LoginErrors.invalidHandle,
              loginHandle: loginHandle,
              fetchedNotes: null,
            ),
          );
          return;
        }
        //  we have a valid login handle and wait to fetch notes
        final notes = await notesApi.getNotes(loginHandle: loginHandle!);
        emit(
          AppState(
            isLoading: false,
            loginErrors: null,
            loginHandle: loginHandle,
            fetchedNotes: notes,
          ),
        );
      },
    );
  }
}
