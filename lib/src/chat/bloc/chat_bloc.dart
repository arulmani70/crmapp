import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:crmapp/src/common/services/websocket_service.dart';
import 'package:crmapp/src/common/models/customer_model.dart';
import 'package:crmapp/src/common/models/chat_message.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatMessageBloc extends Bloc<ChatPageEvent, ChatPageState> {
  final Logger log = Logger();
  final WebSocketService webSocketService;
  final String loggedInUserId;
  late final StreamSubscription<String> _webSocketSubscription;

  ChatMessageBloc({
    required this.webSocketService,
    required this.loggedInUserId,
  }) : super(ChatPageState.initial) {
    on<InitializeChat>(_onInitializeChat);
    on<SendChatMessage>(_onSendChatMessage);
    on<ReceiveChatMessage>(_onReceiveChatMessage);

    webSocketService.connect();

    _webSocketSubscription = webSocketService.messageStream.listen((rawMsg) {
      log.d('WebSocket raw message received: $rawMsg');
      try {
        final parsedJson = jsonDecode(rawMsg);
        final originalMessage = ChatMessage.fromJson(parsedJson);

        final currentCustomerId = state.customer?.id;

        if (currentCustomerId != null) {
          final replyMessage = ChatMessage(
            id: originalMessage.id,
            senderId: originalMessage.receiverId,
            receiverId: originalMessage.senderId,
            text: originalMessage.text,
            timestamp: DateTime.now(),
            isUser: false,
          );

          final isForCurrentChat =
              (replyMessage.senderId == currentCustomerId &&
                  replyMessage.receiverId == loggedInUserId) ||
              (replyMessage.senderId == loggedInUserId &&
                  replyMessage.receiverId == currentCustomerId);

          if (isForCurrentChat) {
            add(ReceiveChatMessage(message: replyMessage));
          }
        }
      } catch (e) {
        log.e('WebSocket message parsing error: $e');
      }
    });
  }

  @override
  Future<void> close() async {
    await _webSocketSubscription.cancel();
    webSocketService.disconnect();
    return super.close();
  }

  Future<void> _onInitializeChat(
    InitializeChat event,
    Emitter<ChatPageState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: () => ChatPageStatus.loading,
          customer: () => event.customer,
        ),
      );

      emit(state.copyWith(status: () => ChatPageStatus.success));
    } catch (e) {
      log.e('Failed to initialize chat: $e');
      emit(
        state.copyWith(
          status: () => ChatPageStatus.failure,
          message: () => e.toString(),
        ),
      );
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<ChatPageState> emit,
  ) async {
    try {
      final updatedMessages = List<ChatMessage>.from(state.messages)
        ..add(event.message);

      emit(
        state.copyWith(
          status: () => ChatPageStatus.sending,
          messages: () => updatedMessages,
        ),
      );

      final jsonMsg = jsonEncode(event.message.toJson());
      webSocketService.sendMessage(jsonMsg);

      emit(state.copyWith(status: () => ChatPageStatus.success));
    } catch (e) {
      log.e('Error sending message: $e');
      emit(
        state.copyWith(
          status: () => ChatPageStatus.failure,
          message: () => e.toString(),
        ),
      );
    }
  }

  Future<void> _onReceiveChatMessage(
    ReceiveChatMessage event,
    Emitter<ChatPageState> emit,
  ) async {
    log.d('Received message in bloc: ${event.message.text}');

    try {
      final updatedMessages = List<ChatMessage>.from(state.messages)
        ..add(event.message);

      emit(
        state.copyWith(
          status: () => ChatPageStatus.success,
          messages: () => updatedMessages,
        ),
      );
    } catch (e) {
      log.e('Error receiving message: $e');
      emit(
        state.copyWith(
          status: () => ChatPageStatus.failure,
          message: () => e.toString(),
        ),
      );
    }
  }
}
