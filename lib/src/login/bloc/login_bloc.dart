import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import 'package:crmapp/src/login/repo/login_repository.dart';
import 'package:crmapp/src/common/models/models.dart';

part 'login_state.dart';
part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Logger log = Logger();
  final LoginRepository _repository;

  LoginBloc({required LoginRepository repository})
    : _repository = repository,
      super(LoginState.initial) {
    on<LoginInitial>(_onLoginInitial);
    on<LoginWithEmailPasswordEvent>(_onLoginWithEmailPassword);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoginInitial(
    LoginInitial event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: () => LoginStatus.loading));

    try {
      final validUserPresent = await _repository.checkValidUser();

      log.d("LoginBloc: valid user present? $validUserPresent");

      emit(
        state.copyWith(
          status: () => LoginStatus.loggedOut,
          savedStatus: () => LoginStatus.loggedOut,
        ),
      );
    } catch (error, stackTrace) {
      log.e("Error in _onLoginInitial", error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: () => LoginStatus.error,
          message: () => error.toString(),
        ),
      );
    }
  }

  Future<void> _onLoginWithEmailPassword(
    LoginWithEmailPasswordEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: () => LoginStatus.loading));

    try {
      log.i("Login attempt with email: ${event.email}");

      final UsersModel user = await _repository.loginWithEmailPassword(
        event.email.trim(),
        event.password,
      );

      if (user.id.isNotEmpty) {
        emit(
          state.copyWith(
            user: () => user,
            status: () => LoginStatus.loggedIn,
            savedStatus: () => LoginStatus.loggedIn,
            message: () => '',

            email: () => event.email,
            password: () => event.password,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: () => LoginStatus.error,
            message: () => "Invalid email or password",
          ),
        );
      }
    } catch (error, stackTrace) {
      log.e("Login failed", error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: () => LoginStatus.error,
          message: () => "Login failed: ${error.toString()}",
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: () => LoginStatus.loading));
    try {
      emit(
        state.copyWith(
          status: () => LoginStatus.loggedOut,
          savedStatus: () => LoginStatus.loggedOut,
          user: () => UsersModel.empty(),
          email: () => '',
          password: () => '',
          message: () => '',
        ),
      );
    } catch (error, stackTrace) {
      log.e("Logout failed", error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: () => LoginStatus.error,
          message: () => error.toString(),
        ),
      );
    }
  }
}
