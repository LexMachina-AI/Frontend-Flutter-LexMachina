import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../models/chat_users.dart';
import '../services/gemini_service.dart';
import '../widgets/chat_typing_indicator.dart';
// import '../utils/file_handlers.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool _isAITyping = false;
  bool _isGeminiInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    try {
      await _geminiService.initialize();
      setState(() => _isGeminiInitialized = true);
    } catch (e) {
      setState(() => _initError = e.toString());
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // _handleImageSelection();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('File'),
                onTap: () {
                  Navigator.pop(context);
                  // _handleFileSelection();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _handleFileSelection() async {
  //   final result = await FileHandlers.handleFileSelection(ChatUsers.currentUser);
  //   if (result != null) {
  //     setState(() => _messages.insert(0, result));
  //   }
  // }
  //
  // void _handleImageSelection() async {
  //   final result = await FileHandlers.handleImageSelection(ChatUsers.currentUser);
  //   if (result != null) {
  //     setState(() => _messages.insert(0, result));
  //   }
  // }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      // Handle file message tap
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async { 
    final textMessage = types.TextMessage(
      author: ChatUsers.currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _isAITyping = true;
    });

    try {
      final response = await _geminiService.sendMessage(message.text);
      if (response != null) {
        final aiMessage = types.TextMessage(
          author: ChatUsers.aiUser,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
        );
        setState(() => _messages.insert(0, aiMessage));
      }
    } finally {
      setState(() => _isAITyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isGeminiInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Indian Legal AI Assistant'),
        ),
        body: Center(
          child: _initError != null
              ? Text('Error: $_initError')
              : const CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Legal AI Assistant'),
        bottom: _isAITyping ? const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(),
        ) : null,
      ),
      body: Chat(
        messages: _messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: ChatUsers.currentUser,
        customBottomWidget: _isAITyping ? const ChatTypingIndicator() : null,
      ),
    );
  }
}