class Document {
  final String id;
  final String filename;
  final String fileType;
  final int fileSizeBytes;
  final DateTime? uploadedAt;

  Document({
    required this.id,
    required this.filename,
    required this.fileType,
    required this.fileSizeBytes,
    this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      filename: json['filename'],
      fileType: json['file_type'] ?? 'unknown',
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      uploadedAt: json['uploaded_at'] != null ? DateTime.tryParse(json['uploaded_at']) : null,
    );
  }
}

class Source {
  final String filename;
  final String contentPreview;
  final double score;
  final double similarity;

  Source({
    required this.filename,
    required this.contentPreview,
    required this.score,
    required this.similarity,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      filename: json['filename'],
      contentPreview: json['content_preview'] ?? '',
      score: (json['score'] as num).toDouble(),
      similarity: (json['similarity'] as num).toDouble(),
    );
  }
}

class Message {
  final String role;
  final String content;
  final List<Source>? sources;

  Message({
    required this.role,
    required this.content,
    this.sources,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    var rawSources = json['sources'] as List?;
    return Message(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      sources: rawSources?.map((e) => Source.fromJson(e)).toList(),
    );
  }
}

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'] ?? 'New Chat',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
    );
  }
}

class QueryRequest {
  final String query;
  final String userId;
  final String? conversationId;
  final int topK;
  final List<String>? documentIds;

  QueryRequest({
    required this.query,
    required this.userId,
    this.conversationId,
    this.topK = 5,
    this.documentIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'user_id': userId,
      if (conversationId != null) 'conversation_id': conversationId,
      'top_k': topK,
      if (documentIds != null) 'document_ids': documentIds,
    };
  }
}
