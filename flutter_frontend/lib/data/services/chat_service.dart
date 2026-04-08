import 'dart:convert';
import 'package:dio/dio.dart';
import '../models.dart';
import 'auth_service.dart';

class ChatService {
  final Dio dio;
  final AuthService authService;

  ChatService({required this.dio, required this.authService});

  Future<List<Conversation>> fetchConversations() async {
    final userId = await authService.getUserId();
    final response = await dio.get('/conversations', queryParameters: {'user_id': userId});
    
    if (response.statusCode == 200) {
      final List data = response.data['conversations'] ?? [];
      return data.map((e) => Conversation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<Message>> fetchMessages(String conversationId) async {
    final response = await dio.get('/conversations/$conversationId');
    if (response.statusCode == 200) {
      final List data = response.data['messages'] ?? [];
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    final userId = await authService.getUserId();
    await dio.delete('/conversations/$conversationId', queryParameters: {'user_id': userId});
  }

  Future<void> renameConversation(String conversationId, String newTitle) async {
    await dio.put('/conversations/$conversationId', data: {'title': newTitle});
  }

  Stream<Map<String, dynamic>> streamQuery(QueryRequest request) async* {
    final response = await dio.post(
      '/query/stream',
      data: request.toJson(),
      options: Options(
        responseType: ResponseType.stream,
      ),
    );

    final stream = response.data.stream;
    await for (final rawData in stream) {
      final String chunk = utf8.decode(rawData);
      final lines = chunk.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final dataStr = line.substring(6).trim();
          if (dataStr.isNotEmpty) {
            try {
              final json = jsonDecode(dataStr);
              yield json;
            } catch (_) {}
          }
        }
      }
    }
  }
}
