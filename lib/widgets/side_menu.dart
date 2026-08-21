import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chat_session.dart';
import '../../services/chat_session_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../screens/auth/login_screen.dart';

class SideMenu extends StatefulWidget {
  final Function(ChatSession) onSessionSelected;

  const SideMenu({Key? key, required this.onSessionSelected}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final ChatSessionService _sessionService = ChatSessionService();
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await _sessionService.getSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  Future<void> _createNewSession() async {
    final newSession = await _sessionService.createSession();
    _loadSessions();
    widget.onSessionSelected(newSession);
    if (mounted) Navigator.pop(context);
  }

  void _showRenameDialog(ChatSession session) {
    final controller = TextEditingController(text: session.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mediumGray,
        title: Text('Rename Chat', style: GoogleFonts.poppins(color: AppTheme.textWhite)),
        content: TextField(
          controller: controller,
          style: GoogleFonts.poppins(color: AppTheme.textWhite),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: GoogleFonts.poppins(color: AppTheme.textGrey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkRed),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _sessionService.updateSessionTitle(session.id, controller.text);
                _loadSessions();
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text('Rename', style: GoogleFonts.poppins(color: AppTheme.textWhite)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ChatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mediumGray,
        title: Text('Delete Chat', style: GoogleFonts.poppins(color: AppTheme.textWhite)),
        content: Text('Are you sure you want to delete this chat?', style: GoogleFonts.poppins(color: AppTheme.textWhite)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _sessionService.deleteSession(session.id);
              _loadSessions();
              if (mounted) Navigator.pop(context);
            },
            child: Text('Delete', style: GoogleFonts.poppins(color: AppTheme.textWhite)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.darkRed, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _createNewSession,
                  icon: const Icon(Icons.add, color: AppTheme.textWhite),
                  label: Text(
                    "New Chat",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: GoogleFonts.poppins(color: theme.iconTheme.color, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: theme.iconTheme.color, size: 20),
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? AppTheme.mediumGray : AppTheme.lightGray,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (text) {
                // Mock search logic
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark, color: AppTheme.darkRed),
            title: Text("Saved & Favorites", style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
            onTap: () {
              // Mock navigation to favorites
            },
          ),
          const Divider(),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.darkRed))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return ListTile(
                        leading: Icon(Icons.chat_bubble_outline, color: theme.iconTheme.color),
                        title: Text(
                          session.title,
                          style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          widget.onSessionSelected(session);
                          Navigator.pop(context);
                        },
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                          color: theme.colorScheme.surface,
                          onSelected: (value) {
                            if (value == 'rename') _showRenameDialog(session);
                            if (value == 'delete') _showDeleteDialog(session);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Text('Rename', style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          SwitchListTile(
            activeColor: AppTheme.textWhite,
            activeTrackColor: AppTheme.darkerRed,
            title: Text("Dark Mode", style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)),
            value: isDark,
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: theme.iconTheme.color),
            onChanged: (bool value) {
              ThemeNotifier().toggleTheme();
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.iconTheme.color),
            title: Text("Logout", style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)),
            onTap: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
