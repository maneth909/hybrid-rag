import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models.dart';
import '../data/services/chat_service.dart';
import '../data/services/auth_service.dart';

class ChatState {
  final bool isLoadingHistory;
  final bool isQuerying;
  final String? error;
  final List<Message> messages;
  final String? currentConversationId;

  ChatState({
    this.isLoadingHistory = false,
    this.isQuerying = false,
    this.error,
    this.messages = const [],
    this.currentConversationId,
  });

  ChatState copyWith({
    bool? isLoadingHistory,
    bool? isQuerying,
    String? error,
    List<Message>? messages,
    String? currentConversationId,
  }) {
    return ChatState(
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isQuerying: isQuerying ?? this.isQuerying,
      error: error,
      messages: messages ?? this.messages,
      currentConversationId: currentConversationId ?? this.currentConversationId,
    );
  }
}

class ChatCubit extends Cubit<ChatState> {
  final ChatService chatService;
  final AuthService authService;

  ChatCubit({required this.chatService, required this.authService}) : super(ChatState());

  void loadMessages(String conversationId) async {
    emit(state.copyWith(isLoadingHistory: true, error: null, currentConversationId: conversationId));
    try {
      final msgs = await chatService.fetchMessages(conversationId);
      emit(state.copyWith(isLoadingHistory: false, messages: msgs));
    } catch (e) {
      emit(state.copyWith(isLoadingHistory: false, error: e.toString()));
    }
  }

  void startNewChat() {
    emit(ChatState()); 
  }

  void sendQuery(String query, List<String>? selectedDocumentIds) async {
    final userId = await authService.getUserId();
    
    final userMsg = Message(role: 'user', content: query);
    final currentMessages = List<Message>.from(state.messages)..add(userMsg);
    
    final assistantMsg = Message(role: 'assistant', content: '', sources: null);
    currentMessages.add(assistantMsg);

    emit(state.copyWith(
      isQuerying: true, 
      messages: currentMessages,
      error: null,
    ));

    final request = QueryRequest(
      query: query, 
      userId: userId,
      conversationId: state.currentConversationId,
      documentIds: selectedDocumentIds,
    );

    try {
      final stream = chatService.streamQuery(request);
      
      String responseContent = '';
      List<Source>? sources;

      await for (final event in stream) {
        final type = event['type'];
        
        if (type == 'meta') {
          emit(state.copyWith(currentConversationId: event['conversation_id']));
        } else if (type == 'sources') {
          final sourcesData = event['data'] as List;
          sources = sourcesData.map((e) => Source.fromJson(e)).toList();
          _updateLastMessage(responseContent, sources);
        } else if (type == 'token') {
          responseContent += event['data'];
          _updateLastMessage(responseContent, sources);
        } else if (type == 'error') {
          emit(state.copyWith(error: event['data']));
        }
      }
      
      emit(state.copyWith(isQuerying: false));
    } catch (e) {
      emit(state.copyWith(isQuerying: false, error: e.toString()));
    }
  }

  void _updateLastMessage(String content, List<Source>? sources) {
    if (state.messages.isEmpty) return;
    
    final messages = List<Message>.from(state.messages);
    final lastMsg = messages.last;
    
    if (lastMsg.role == 'assistant') {
      messages[messages.length - 1] = Message(
        role: 'assistant', 
        content: content, 
        sources: sources,
      );
      emit(state.copyWith(messages: messages));
    }
  }
}
