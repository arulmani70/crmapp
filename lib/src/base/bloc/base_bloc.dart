import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:crmapp/src/base/repository/base_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:crmapp/src/common/constants/constansts.dart';
import 'package:logger/logger.dart';

part 'base_event.dart';
part 'base_state.dart';

class BaseBloc extends Bloc<BaseEvent, BaseState> {
  final log = Logger();
  final BaseRepository _repository;

  BaseBloc({required BaseRepository repository})
    : _repository = repository,
      super(BaseState.initial) {
    on<InitializeApp>(mapInitializeAppToState);
    on<CheckAppInitialized>(mapCheckAppInitializedToState);
    on<InitMemoryCache>(mapInitMemoryCacheToState);
  }

  Future<void> mapInitializeAppToState(
    InitializeApp event,
    Emitter<BaseState> emit,
  ) async {
    try {
      log.d("BaseBloc::InitializeAppToState::Triggered");

      emit(state.copyWith(status: () => BaseStatus.syncing));

      final initMap = await _repository.isAppInit(
        event.currentUser.id,
        event.currentUser.email,
      );

      final bool isAppInitialized =
          initMap[Constants.store.INITIALIZED] ?? false;

      await _repository.ensureMicrophonePermission(
        event.currentUser.id,
        event.currentUser.email,
      );

      emit(state.copyWith(status: () => BaseStatus.completed));
    } catch (error, stacktrace) {
      log.e(
        "BaseBloc::InitializeAppToState: $error",
        error: error,
        stackTrace: stacktrace,
      );
      emit(
        state.copyWith(
          status: () => BaseStatus.error,
          message: () => error.toString(),
        ),
      );
    }
  }

  Future<void> mapCheckAppInitializedToState(
    CheckAppInitialized event,
    Emitter<BaseState> emit,
  ) async {
    try {
      log.d("BaseBloc::CheckAppInitialized::Triggered");

      emit(state.copyWith(status: () => BaseStatus.syncing));

      final initMap = await _repository.isAppInit(
        event.currentUser.id,
        event.currentUser.email,
      );
      log.d("BaseBloc::CheckAppInitialized::App is Initialized::$initMap");

      emit(state.copyWith(status: () => BaseStatus.completed));
    } catch (error, stacktrace) {
      log.e(
        "BaseBloc::CheckAppInitialized: $error",
        error: error,
        stackTrace: stacktrace,
      );
      emit(
        state.copyWith(
          status: () => BaseStatus.error,
          message: () => error.toString(),
        ),
      );
    }
  }

  Future<void> mapInitMemoryCacheToState(
    InitMemoryCache event,
    Emitter<BaseState> emit,
  ) async {
    log.d("BaseBloc::InitMemoryCacheToState::Triggered");

    emit(state.copyWith(status: () => BaseStatus.syncing));
    try {
      List<UserRole> userRoleList = [];

      emit(
        state.copyWith(
          status: () => BaseStatus.completed,
          userRoleList: () => userRoleList,
        ),
      );
    } catch (error, stacktrace) {
      log.e(
        "BaseBloc::InitMemoryCacheToState: $error",
        error: error,
        stackTrace: stacktrace,
      );
      emit(
        state.copyWith(
          status: () => BaseStatus.error,
          message: () => error.toString(),
        ),
      );
    }
  }
}
