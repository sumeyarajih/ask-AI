import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();

  final List<_StatItem> _stats = const [
    _StatItem(icon: Icons.chat_bubble_outline, label: 'Conversations', value: '24'),
    _StatItem(icon: Icons.upload_file, label: 'Documents', value: '6'),
    _StatItem(icon: Icons.bookmark_outline, label: 'Saved', value: '12'),
    _StatItem(icon: Icons.memory, label: 'Memories', value: '8'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = _auth.userName;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsSheet(context, isDark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppTheme.darkRed,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.darkRed,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
            ),
            Text('Free Plan', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.workspace_premium, color: AppTheme.darkRed),
              label: Text('Upgrade to Pro', style: GoogleFonts.poppins(color: AppTheme.darkRed, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.darkRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 28),
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.0,
              children: _stats.map((s) => _statCard(s, theme, isDark)).toList(),
            ),
            const SizedBox(height: 28),
            // Settings Tiles
            _sectionTitle('Account', theme),
            _tile(context, Icons.person_outline, 'Edit Profile', theme, onTap: () {}),
            _tile(context, Icons.lock_outline, 'Change Password', theme, onTap: () {}),
            _tile(context, Icons.memory, 'AI Memory Settings', theme, onTap: () {}),
            const SizedBox(height: 12),
            _sectionTitle('Preferences', theme),
            _tile(context, Icons.bookmark_outline, 'Saved Answers', theme, onTap: () {}),
            _tile(context, Icons.bar_chart, 'My Dashboard', theme, onTap: () {}),
            const SizedBox(height: 12),
            _sectionTitle('Danger Zone', theme),
            _tile(context, Icons.logout, 'Log Out', theme, isRed: true, onTap: () async {
              await _auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false,
                );
              }
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statCard(_StatItem item, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.mediumGray : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: AppTheme.darkRed, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              Text(item.label, style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, ThemeData theme, {required VoidCallback onTap, bool isRed = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: isRed ? Colors.red : theme.iconTheme.color),
      title: Text(label, style: GoogleFonts.poppins(color: isRed ? Colors.red : theme.textTheme.bodyLarge?.color, fontSize: 14)),
      trailing: isRed ? null : const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showSettingsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Settings', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(ctx).textTheme.bodyLarge?.color)),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.textWhite,
              activeTrackColor: AppTheme.darkerRed,
              title: Text('Dark Mode', style: GoogleFonts.poppins(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              value: isDark,
              onChanged: (_) => ThemeNotifier().toggleTheme(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined),
              title: Text('Notifications', style: GoogleFonts.poppins(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: Text('Language', style: GoogleFonts.poppins(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({required this.icon, required this.label, required this.value});
}
