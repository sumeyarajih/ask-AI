import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/message.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/side_menu.dart';
import '../../models/chat_session.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Message> _messages = [];
  final AIService _aiService = AIService();
  final ScrollController _scrollController = ScrollController();
  
  ChatSession? _currentSession;
  String? _selectedDocumentName;

  @override
  void initState() {
    super.initState();
    final name = AuthService().userName;
    _messages.add(
      Message(
        text: "Hi, $name! 👋\nI'm your AI assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _onSessionSelected(ChatSession session) {
    setState(() {
      _currentSession = session;
      _messages.clear();
      _messages.add(
        Message(
          text: "Continuing session: ${session.title}",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _handleUploadItem(String type) {
    setState(() {
      _selectedDocumentName = type == 'photo' ? "image_${DateTime.now().second}.png" : "report_2026.pdf"; // Mocked upload
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Item '$_selectedDocumentName' uploaded.", style: GoogleFonts.poppins(color: AppTheme.textWhite)),
        backgroundColor: AppTheme.darkRed,
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty && _selectedDocumentName == null) return;
    
    final attachment = _selectedDocumentName;
    setState(() => _selectedDocumentName = null);

    _textController.clear();

    final userMessage = Message(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      attachmentName: attachment,
    );

    setState(() {
      _messages.add(userMessage);
      _messages.add(
        Message(
          text: "...",
          isUser: false,
          timestamp: DateTime.now(),
          isStreaming: true,
        ),
      );
    });

    _scrollToBottom();
    
    final loadingIndex = _messages.length - 1;

    _aiService.getStreamingResponse(text, documentId: attachment != null ? 'doc-id' : null).listen(
      (chunk) {
        setState(() {
          _messages[loadingIndex] = _messages[loadingIndex].copyWith(
            text: chunk,
          );
        });
        _scrollToBottom();
      },
      onDone: () {
        setState(() {
          _messages[loadingIndex] = _messages[loadingIndex].copyWith(
            isStreaming: false,
          );
        });
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _currentSession?.title ?? 'ASK AI',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: SideMenu(onSessionSelected: _onSessionSelected),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                         theme.scaffoldBackgroundColor, 
                         theme.colorScheme.surface,
                      ],
                    ),
                  ),
                ),
                // Background Watermark Design Icon
                Center(
                  child: Opacity(
                    opacity: isDark ? 0.05 : 0.15, // Barely visible watermark
                    child: Image.asset(
                      'assets/images/Ai_logo2.png',
                      width: 250,
                      height: 250,
                      color: isDark ? Colors.white : AppTheme.darkRed, 
                    ),
                  ),
                ),
                // Messages List
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessage(message);
                  },
                ),
              ],
            ),
          ),
          if (_selectedDocumentName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
              child: Row(
                children: [
                  Chip(
                    backgroundColor: AppTheme.darkRed,
                    label: Text(
                      _selectedDocumentName!,
                      style: GoogleFonts.poppins(color: AppTheme.textWhite, fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, color: AppTheme.textWhite, size: 16),
                    onDeleted: () {
                      setState(() => _selectedDocumentName = null);
                    },
                  ),
                ],
              ),
            ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.attachmentName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf, color: theme.iconTheme.color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    message.attachmentName!,
                    style: GoogleFonts.poppins(color: theme.iconTheme.color, fontSize: 12),
                  ),
                ],
              ),
            ),
          ChatBubble(
            clipper: ChatBubbleClipper4(
              type: message.isUser ? BubbleType.sendBubble : BubbleType.receiverBubble,
            ),
            alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
            backGroundColor: message.isUser 
                ? AppTheme.darkRed 
                : (isDark ? AppTheme.mediumGray : AppTheme.lightGray),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  color: message.isUser ? AppTheme.textWhite : theme.textTheme.bodyLarge?.color, 
                  fontSize: 14
                ),
              ),
            ),
          ),
          if (message.isStreaming && !message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 2.0),
              child: Text(
                'AI is typing...',
                style: GoogleFonts.poppins(color: theme.iconTheme.color, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildInput() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkRed.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          PopupMenuButton<String>(
            icon: Icon(Icons.attach_file, color: theme.iconTheme.color),
            color: theme.colorScheme.surface,
            tooltip: "Upload item",
            onSelected: (value) {
              _handleUploadItem(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'photo',
                child: Row(
                  children: [
                    Icon(Icons.image, color: theme.iconTheme.color, size: 20),
                    const SizedBox(width: 8),
                    Text('Photo', style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'file',
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, color: theme.iconTheme.color, size: 20),
                    const SizedBox(width: 8),
                    Text('File / PDF', style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: GoogleFonts.poppins(color: theme.iconTheme.color),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark 
                    ? AppTheme.mediumGray 
                    : AppTheme.lightGray,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.darkRed, AppTheme.darkerRed],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkRed.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppTheme.textWhite),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}