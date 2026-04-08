import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models.dart';
import '../data/services/chat_service.dart';

class ConversationState {
  final bool isLoading;
  final String? error;
  final List<Conversation> conversations;
  final String? selectedConversationId;

  ConversationState({
    this.isLoading = false,
    this.error,
    this.conversations = const [],
    this.selectedConversationId,
  });

  ConversationState copyWith({
    bool? isLoading,
    String? error,
    List<Conversation>? conversations,
    String? selectedConversationId,
  }) {
    return ConversationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      conversations: conversations ?? this.conversations,
      selectedConversationId:
          selectedConversationId ?? this.selectedConversationId,
    );
  }
}

class ConversationCubit extends Cubit<ConversationState> {
  final ChatService chatService;

  ConversationCubit({required this.chatService}) : super(ConversationState());

  Future<void> loadConversations() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await chatService.fetchConversations();
      // sort by newest
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(isLoading: false, conversations: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void selectConversation(String? id) {
    emit(state.copyWith(selectedConversationId: id));
  }

  // --- NEW METHOD ADDED HERE ---
  void clearSelection() {
    emit(
      ConversationState(
        conversations: state.conversations,
        isLoading: state.isLoading,
        error: state.error,
        // We explicitly set this to null instead of using copyWith
        selectedConversationId: null,
      ),
    );
  }
  // -----------------------------

  void deleteConversation(String id) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await chatService.deleteConversation(id);
      if (state.selectedConversationId == id) {
        // We should also use the new method here so it actually clears when deleted!
        clearSelection();
      }
      loadConversations();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void renameConversation(String id, String newTitle) async {
    try {
      await chatService.renameConversation(id, newTitle);
      loadConversations();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
