import 'package:crmapp/src/base/base_view.dart';
import 'package:crmapp/src/call/call_page.dart';
import 'package:crmapp/src/call/voice_call.dart';
import 'package:crmapp/src/chat/chat_page.dart';
import 'package:crmapp/src/common/widgets/file_not_found.dart';
import 'package:crmapp/src/customer/customer_screen.dart';
// import 'package:crmapp/src/login/bloc/login_bloc.dart';
import 'package:crmapp/src/loigin_firebase/bloc/login_firebase_bloc.dart';
import 'package:crmapp/src/loigin_firebase/logine_firebase_page.dart';

// import 'package:crmapp/src/login/login_view.dart';

import 'package:crmapp/src/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crmapp/src/app/route_names.dart';
import 'package:logger/logger.dart';
import 'package:crmapp/src/common/widgets/splashscreen.dart';

import '../common/models/models.dart';

class Routes {
  final log = Logger();

  GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: RouteNames.splashscreen,
        path: "/",
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        name: RouteNames.login,
        path: "/login",
        builder: (BuildContext context, GoRouterState state) {
          return LoginFirebasePage();
        },
      ),

      GoRoute(
        name: RouteNames.customer,
        path: '/customer',
        builder: (context, state) => CustomerScreen(),
      ),
      GoRoute(
        name: RouteNames.profile,
        path: '/profile',
        builder: (context, state) => ProfileScreen(),
      ),
      GoRoute(
        name: RouteNames.chat,
        path: '/chat',
        builder: (BuildContext context, GoRouterState state) {
          final customer = state.extra as CustomerModel;
          return ChatPage(customer: customer);
        },
      ),

      GoRoute(
        name: RouteNames.voiceCall,
        path: '/voicecall',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          return VoiceCallPage(
            callerId: extra['callerId'],
            calleeId: extra['calleeId'],
            isCaller: extra['isCaller'],
          );
        },
      ),

      GoRoute(
        name: RouteNames.call,
        path: '/call',

        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          return CallPage(
            callerId: extra['callerId'],
            calleeId: extra['calleeId'],
            isCaller: extra['isCaller'],
          );
        },
      ),

      GoRoute(
        name: RouteNames.base,
        path: "/base",
        builder: (BuildContext context, GoRouterState state) {
          return BaseView();
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final log = Logger();
      final bool signedIn =
          context.read<LoginFirebaseBloc>().state.status ==
          LoginFirebaseStatus.loggedIn;
      log.d("Routes:::Redirect:Is LoggedIn: $signedIn");
      final bool signingIn = state.matchedLocation == '/login';
      log.d("Routes:::Redirect:MatchedLocation: ${state.matchedLocation}");
      log.d(
        "Routes:::sssssRedirect:: ${state.matchedLocation == '/' && !signedIn}",
      );
      if (state.matchedLocation == '/' && !signedIn) {
        return null;
      }

      if (!signedIn && !signingIn) {
        return '/login';
      } else if (signedIn && signingIn) {
        return '/base';
      }

      return null;
    },
    debugLogDiagnostics: true,
    errorBuilder: (contex, state) {
      return FileNotFound(message: "${state.error?.message}");
    },
  );
}
