import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models.dart';
import '../data/services/document_service.dart';

class DocumentState {
  final bool isLoading;
  final String? error;
  final List<Document> documents;
  final Set<String> selectedDocumentIds; // for targeted search

  DocumentState({
    this.isLoading = false,
    this.error,
    this.documents = const [],
    this.selectedDocumentIds = const {},
  });

  DocumentState copyWith({
    bool? isLoading,
    String? error,
    List<Document>? documents,
    Set<String>? selectedDocumentIds,
  }) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      documents: documents ?? this.documents,
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
    );
  }
}

class DocumentCubit extends Cubit<DocumentState> {
  final DocumentService documentService;

  DocumentCubit({required this.documentService}) : super(DocumentState());

  void loadDocuments() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final docs = await documentService.fetchDocuments();
      emit(state.copyWith(isLoading: false, documents: docs));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void uploadDocument(String filePath, String fileName) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await documentService.uploadDocument(filePath, fileName);
      loadDocuments(); // refresh list
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void deleteDocument(String id) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await documentService.deleteDocument(id);
      loadDocuments(); // refresh list
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void toggleDocumentSelection(String id) {
    final newSelection = Set<String>.from(state.selectedDocumentIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    emit(state.copyWith(selectedDocumentIds: newSelection));
  }
  
  void selectAll() {
    final allIds = state.documents.map((e) => e.id).toSet();
    emit(state.copyWith(selectedDocumentIds: allIds));
  }

  void deselectAll() {
    emit(state.copyWith(selectedDocumentIds: {}));
  }
}
