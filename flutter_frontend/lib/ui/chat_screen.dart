import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/chat_cubit.dart';
import '../logic/conversation_cubit.dart';
import '../logic/document_cubit.dart';
import '../logic/theme_cubit.dart';
import '../data/models.dart';
import 'documents_screen.dart';
import 'meteor_background.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final query = _controller.text;
    _controller.clear();

    final docState = context.read<DocumentCubit>().state;
    final selectedDocs = docState.selectedDocumentIds.toList();

    context.read<ChatCubit>().sendQuery(query, selectedDocs);
  }

  void _showRenameDialog(BuildContext context, Conversation conv) {
    final TextEditingController renameController = TextEditingController(
      text: conv.title,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Rename Chat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: renameController,
          decoration: InputDecoration(
            hintText: 'New title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (renameController.text.trim().isNotEmpty) {
                context.read<ConversationCubit>().renameConversation(
                  conv.id,
                  renameController.text.trim(),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(CupertinoIcons.bars),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        // title: const Wrap(
        //   crossAxisAlignment: WrapCrossAlignment.center,
        //   children: [
        //     Text(
        //       'Chat',
        //       overflow: TextOverflow.ellipsis,
        //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        //     ),
        //   ],
        // ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? CupertinoIcons.sun_max
                  : CupertinoIcons.moon,
            ),
            tooltip: 'Toggle Dark Mode',
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme(context);
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.folder),
            tooltip: 'Documents',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DocumentsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        child: SafeArea(
          child: BlocBuilder<ConversationCubit, ConversationState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar Pill
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2D2D30)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search for chats',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New Chat
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    leading: const Icon(CupertinoIcons.pencil_outline),
                    title: const Text(
                      'New chat',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      context.read<ChatCubit>().startNewChat();
                      context
                          .read<ConversationCubit>()
                          .clearSelection(); // <-- The fix
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 4),

                  // Documents Link
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    title: const Text(
                      'Documents',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(
                      CupertinoIcons.chevron_forward,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DocumentsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Chats Header
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Chats',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Chat List
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: state.conversations.length,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 0.0,
                            ),
                            itemBuilder: (context, index) {
                              final conv = state.conversations[index];
                              final isSelected =
                                  state.selectedConversationId == conv.id;

                              return CupertinoContextMenu(
                                actions: <Widget>[
                                  CupertinoContextMenuAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    trailingIcon: CupertinoIcons.share,
                                    child: const Text('Share conversation'),
                                  ),
                                  CupertinoContextMenuAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    trailingIcon: CupertinoIcons.pin,
                                    child: const Text('Pin'),
                                  ),
                                  CupertinoContextMenuAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showRenameDialog(context, conv);
                                    },
                                    trailingIcon: CupertinoIcons.pencil,
                                    child: const Text('Rename'),
                                  ),
                                  CupertinoContextMenuAction(
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context
                                          .read<ConversationCubit>()
                                          .deleteConversation(conv.id);
                                    },
                                    trailingIcon: CupertinoIcons.delete,
                                    child: const Text('Delete'),
                                  ),
                                ],
                                // FIX 1: Added SizedBox to constrain width and prevent the crash
                                child: SizedBox(
                                  width: 304, // Default drawer width
                                  child: Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          24.0,
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedTileColor: isSelected
                                          ? (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF284261)
                                                : Colors.blue.shade50)
                                          : null,
                                      title: Text(
                                        conv.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.blue.shade100
                                                    : Colors.blue.shade900)
                                              : (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white70
                                                    : Colors.black87),
                                        ),
                                      ),
                                      onTap: () {
                                        context
                                            .read<ConversationCubit>()
                                            .selectConversation(conv.id);
                                        context.read<ChatCubit>().loadMessages(
                                          conv.id,
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: BlocListener<ChatCubit, ChatState>(
        listenWhen: (previous, current) {
          return previous.isQuerying == true && current.isQuerying == false;
        },
        listener: (context, state) async {
          final convCubit = context.read<ConversationCubit>();

          // Check if we were previously in a "New Chat" (where nothing is selected)
          final wasNewChat = convCubit.state.selectedConversationId == null;

          // Reload the list of conversations from your backend/local DB
          await convCubit.loadConversations();

          // FIX 2: Automatically select the newly created chat
          if (wasNewChat && convCubit.state.conversations.isNotEmpty) {
            // Assuming the newest conversation is returned first (index 0)
            convCubit.selectConversation(
              convCubit.state.conversations.first.id,
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state.isLoadingHistory) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.messages.isEmpty) {
                      return MeteorBackground(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Ask anything about your documents.',
                                  textAlign: TextAlign
                                      .center, // Centers the text when it drops to a second line
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];
                        final isUser = msg.role == 'user';

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24.0),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                            ),
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (isUser)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Text(
                                      msg.content,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            CupertinoIcons.sparkles,
                                            color: Colors.blueAccent.shade400,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              msg.content,
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                                height: 1.5,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 32),
                                          IconButton(
                                            icon: const Icon(
                                              CupertinoIcons.doc_on_clipboard,
                                              size: 16,
                                            ),
                                            color: Colors.grey,
                                            tooltip: 'Copy',
                                            onPressed: () {
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text: msg.content,
                                                ),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Copied!'),
                                                  duration: Duration(
                                                    seconds: 1,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              CupertinoIcons.hand_thumbsup,
                                              size: 16,
                                            ),
                                            color: Colors.grey,
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              CupertinoIcons.hand_thumbsdown,
                                              size: 16,
                                            ),
                                            color: Colors.grey,
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                      if (msg.sources != null &&
                                          msg.sources!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 32.0,
                                          ),
                                          child: _buildSourcesAccordion(
                                            context,
                                            msg.sources!,
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Modern Input Area
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF202022)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: IconButton(
                          icon: const Icon(
                            CupertinoIcons.add,
                            color: Colors.grey,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Focus(
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.enter &&
                                  !HardwareKeyboard.instance.isShiftPressed) {
                                _sendMessage();
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              decoration: const InputDecoration(
                                hintText: 'Ask here...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      BlocBuilder<ChatCubit, ChatState>(
                        builder: (context, state) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                              bottom: 4.0,
                            ),
                            child: state.isQuerying
                                ? const Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      CupertinoIcons.paperplane_fill,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                    onPressed: _sendMessage,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourcesAccordion(BuildContext context, List<Source> sources) {
    final uniqueSources = <String, Source>{};
    for (var s in sources) {
      if (!uniqueSources.containsKey(s.filename)) {
        uniqueSources[s.filename] = s;
      }
    }
    final displaySources = uniqueSources.values.toList();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          'Sources (${displaySources.length})',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        children: displaySources
            .map(
              (s) => Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s.filename,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${(s.similarity * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.contentPreview,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
