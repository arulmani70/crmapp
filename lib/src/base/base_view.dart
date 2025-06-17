import 'package:crmapp/src/common/constants/constansts.dart';

import 'package:crmapp/src/loigin_firebase/bloc/login_firebase_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crmapp/src/base/bloc/base_bloc.dart';
import 'package:crmapp/src/app/route_names.dart';
import 'package:crmapp/src/base/repository/base_repository.dart';
import 'package:crmapp/src/common/common.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class BaseView extends StatelessWidget {
  final log = Logger();

  BaseView({super.key});

  @override
  Widget build(BuildContext context) {
    UsersModel currentUser = context.select(
      (LoginFirebaseBloc bloc) => bloc.state.user,
    );

    log.d("BaseView::: In Build method::currentUser::${currentUser.toJson()}");

    return Scaffold(
      body: BlocProvider(
        create: (_) => BaseBloc(
          repository: BaseRepository(
            apiRepo: context.read<ApiRepository>(),
            prefRepo: context.read<PreferencesRepository>(),
          ),
        )..add(InitializeApp(currentUser: currentUser)),
        child: BlocConsumer<BaseBloc, BaseState>(
          listener: (context, state) {
            log.d("BaseStatusBaseStatus :: ${state.status}");
            if (state.status == BaseStatus.completed) {
              context.goNamed(RouteNames.customer);
            }
          },
          builder: (context, state) {
            if (state.status == BaseStatus.syncing) {
              return Center(
                child: Text(
                  'Syncing App Data...',
                  style: TextStyle(
                    fontFamily: Constants.app.FONT_POPPINS,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            } else if (state.status == BaseStatus.initial) {
              return Center(
                child: Text(
                  'Initialising App...',
                  style: TextStyle(
                    fontFamily: Constants.app.FONT_POPPINS,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            } else if (state.status == BaseStatus.error) {
              return Center(
                child: Text(
                  'Error initializing App Data',
                  style: TextStyle(
                    fontFamily: Constants.app.FONT_POPPINS,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
