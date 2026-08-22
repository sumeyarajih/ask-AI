import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../api/auth_api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _handleReset() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      await AuthApi().forgotPassword(_emailController.text.trim());
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''), style: GoogleFonts.poppins()),
            backgroundColor: AppTheme.darkerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.darkRed),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.mediumGray : AppTheme.lightGray,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset, size: 44, color: AppTheme.darkRed),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                "Reset Password",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 10),
              Text(
                _emailSent
                    ? "A reset link has been sent to your email."
                    : "Enter your email and we'll send you a reset link.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppTheme.textGrey : AppTheme.textBlack),
              ),
              const SizedBox(height: 40),
              if (!_emailSent) ...[
                CustomTextField(
                  hintText: "Email Address",
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.darkRed))
                    : ElevatedButton(
                        onPressed: _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          "Send Reset Link",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textWhite),
                        ),
                      ),
              ] else ...[
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.darkRed, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        "Check your inbox!",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () => setState(() => _emailSent = false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.darkRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Use a different email", style: GoogleFonts.poppins(color: AppTheme.darkRed)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
