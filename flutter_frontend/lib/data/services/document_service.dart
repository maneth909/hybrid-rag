import 'package:dio/dio.dart';
import '../models.dart';
import 'auth_service.dart';

class DocumentService {
  final Dio dio;
  final AuthService authService;

  DocumentService({required this.dio, required this.authService});

  Future<List<Document>> fetchDocuments() async {
    final userId = await authService.getUserId();
    final response = await dio.get('/documents', queryParameters: {'user_id': userId});
    
    if (response.statusCode == 200) {
      final List data = response.data['documents'] ?? [];
      return data.map((e) => Document.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  Future<Document> uploadDocument(String filePath, String fileName) async {
    final userId = await authService.getUserId();
    
    FormData formData = FormData.fromMap({
      'user_id': userId,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dio.post('/ingest', data: formData);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Document(
        id: response.data['document_id'] ?? '',
        filename: response.data['filename'] ?? fileName,
        fileType: 'unknown',
        fileSizeBytes: 0,
      );
    } else {
      throw Exception('Failed to upload document');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final userId = await authService.getUserId();
    final response = await dio.delete('/documents/$documentId', queryParameters: {'user_id': userId});
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete document');
    }
  }
}
