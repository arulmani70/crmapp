import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:crmapp/src/loigin_firebase/repo/login_firebase_repository.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:logger/logger.dart';
part 'login_firebase_event.dart';
part 'login_firebase_state.dart';

class LoginFirebaseBloc extends Bloc<LoginFirebaseEvent, LoginFirebaseState> {
  final LoginFirebaseRepository _repository;
  final log = Logger();
  LoginFirebaseBloc({required LoginFirebaseRepository repository})
    : _repository = repository,
      super(LoginFirebaseState.initial()) {
    on<LoginInitial>((event, emit) {
      emit(LoginFirebaseState.initial());
    });

    on<LoginWithEmail>(_onLoginWithEmail);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmail event,
    Emitter<LoginFirebaseState> emit,
  ) async {
    emit(
      state.copyWith(status: LoginFirebaseStatus.loading, message: () => ''),
    );

    try {
      final user = await _repository.signInWithEmail(
        event.email,
        event.password,
      );

      if (user != null) {
        emit(
          state.copyWith(
            status: LoginFirebaseStatus.loggedIn,
            user: () => user,
            message: () => '',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LoginFirebaseStatus.failure,
            message: () => 'Invalid email or password',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginFirebaseStatus.failure,
          message: () => e.toString(),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginFirebaseState> emit,
  ) async {
    log.d("LoginFirebaseBloc :: _onLogoutRequested :: $event");
    await _repository.signOut();
    emit(
      state.copyWith(
        status: LoginFirebaseStatus.loggedOut,
        user: () => UsersModel.empty(),
        message: () => '',
      ),
    );
  }
}
