import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../logic/document_cubit.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // Local state to track documents that have been swiped away
  // This prevents the Dismissible crash while the Cubit updates.
  final Set<String> _dismissedIds = {};

  void _pickAndUploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md'],
    );
    if (result != null && result.files.single.path != null) {
      if (!context.mounted) return;
      final docCubit = context.read<DocumentCubit>();
      docCubit.uploadDocument(
        result.files.single.path!,
        result.files.single.name,
      );
    }
  }

  IconData _getIconForType(String ext) {
    if (ext == 'pdf') return CupertinoIcons.doc_fill;
    if (ext == 'md') return CupertinoIcons.chevron_left_slash_chevron_right;
    return CupertinoIcons.doc_text_fill;
  }

  Color _getColorForType(String ext) {
    if (ext == 'pdf') return Colors.redAccent.shade200;
    if (ext == 'md') return Colors.blueAccent.shade200;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // OVERRIDE DEFAULT BACK BUTTON HERE
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Knowledge Base',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.checkmark_rectangle),
            tooltip: 'Select All',
            onPressed: () => context.read<DocumentCubit>().selectAll(),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.clear),
            tooltip: 'Deselect All',
            onPressed: () => context.read<DocumentCubit>().deselectAll(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DocumentCubit, DocumentState>(
        builder: (context, state) {
          if (state.isLoading && state.documents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error: ${state.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Filter out the documents that have already been swiped away locally
          final visibleDocs = state.documents
              .where((doc) => !_dismissedIds.contains(doc.id))
              .toList();

          if (visibleDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.folder_open,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No documents uploaded yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const Text(
                    'Tap + to add a PDF, TXT, or MD file.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: visibleDocs.length,
            itemBuilder: (context, index) {
              final doc = visibleDocs[index];
              final ext = doc.filename.split('.').last.toLowerCase();
              final isSelected = state.selectedDocumentIds.contains(doc.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Dismissible(
                  key: Key(doc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    // 1. Instantly hide the item from the ListView
                    setState(() {
                      _dismissedIds.add(doc.id);
                    });

                    // 2. Safely tell the Cubit to process the deletion
                    context.read<DocumentCubit>().deleteDocument(doc.id);
                  },
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.0),
                    onTap: () => context
                        .read<DocumentCubit>()
                        .toggleDocumentSelection(doc.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                  ? const Color(0xFF284261)
                                  : Colors.blue.shade50)
                            : (isDark ? const Color(0xFF202022) : Colors.white),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent.withValues(alpha: 0.5)
                              : (isDark
                                    ? const Color(0xFF333333)
                                    : Colors.grey.shade300),
                          width: 1.5,
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: _getColorForType(
                                ext,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Icon(
                              _getIconForType(ext),
                              color: _getColorForType(ext),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.filename,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? (isDark
                                              ? Colors.blue.shade100
                                              : Colors.blue.shade900)
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${(doc.fileSizeBytes / 1024).round()} KB',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      ext.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              CupertinoIcons.checkmark_alt_circle_fill,
                              color: Colors.blueAccent,
                              size: 24,
                            )
                          else
                            Icon(
                              CupertinoIcons.circle,
                              color: Colors.grey.withValues(alpha: 0.5),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUploadFile(context),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}
