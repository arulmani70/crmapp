import 'package:crmapp/src/chat/bloc/chat_bloc.dart';
import 'package:crmapp/src/chat/view/desktop/chat_page_desktop.dart';
import 'package:crmapp/src/chat/view/mobile/chat_page_mobile.dart';
import 'package:crmapp/src/chat/view/tablet/chat_page_tablet.dart';
import 'package:crmapp/src/common/services/websocket_service.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatelessWidget {
  final CustomerModel customer;
  const ChatPage({super.key, required this.customer});

  Future<String> _getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final log = Logger();

    return FutureBuilder<String>(
      future: _getLoggedInUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userId = snapshot.data!;
        final webSocketService = WebSocketService();

        return BlocProvider(
          create: (_) => ChatMessageBloc(
            webSocketService: webSocketService,
            loggedInUserId: userId,
          )..add(InitializeChat(customer: customer)),
          child: Builder(
            builder: (context) {
              return ResponsiveValue<Widget>(
                context,
                defaultValue: const ChatPageDesktop(),
                conditionalValues: [
                  const Condition.equals(name: TABLET, value: ChatPageTablet()),
                  const Condition.smallerThan(
                    name: MOBILE,
                    value: ChatPageMobile(),
                  ),
                ],
              ).value;
            },
          ),
        );
      },
    );
  }
}
