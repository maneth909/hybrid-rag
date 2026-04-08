import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di.dart';
import 'core/theme.dart';
import 'ui/chat_screen.dart';
import 'logic/document_cubit.dart';
import 'logic/conversation_cubit.dart';
import 'logic/chat_cubit.dart';
import 'logic/theme_cubit.dart';
import 'data/services/document_service.dart';
import 'data/services/chat_service.dart';
import 'data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup Dependency Injection
  setupDI();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<DocumentCubit>(
          create: (context) => DocumentCubit(documentService: sl<DocumentService>())..loadDocuments(),
        ),
        BlocProvider<ConversationCubit>(
          create: (context) => ConversationCubit(chatService: sl<ChatService>())..loadConversations(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(
            chatService: sl<ChatService>(),
            authService: sl<AuthService>(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'RAG Hybrid Chat',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            home: const ChatScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
