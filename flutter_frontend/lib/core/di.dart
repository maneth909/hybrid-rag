import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../data/services/auth_service.dart';
import '../data/services/document_service.dart';
import '../data/services/chat_service.dart';

final sl = GetIt.instance;

void setupDI() {
  // Core
  sl.registerLazySingleton<Dio>(() => ApiClient.createDio());

  // Services
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<DocumentService>(() => DocumentService(
    dio: sl(),
    authService: sl(),
  ));
  sl.registerLazySingleton<ChatService>(() => ChatService(
    dio: sl(),
    authService: sl(),
  ));
}
