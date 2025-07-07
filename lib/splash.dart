import 'package:flutter/material.dart';
import 'chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to ChatScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade-in animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/Ai_logo2.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 30),
            // Text with typing animation
            const TypingAnimatedText(
              text: 'Welcome to AI Assistant',
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),
            const SizedBox(height: 20),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
            ),
          ],
        ),
      ),
    );
  }
}

// Typing animation widget
class TypingAnimatedText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const TypingAnimatedText({
    super.key,
    required this.text,
    required this.textStyle,
  });

  @override
  State<TypingAnimatedText> createState() => _TypingAnimatedTextState();
}

class _TypingAnimatedTextState extends State<TypingAnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _displayText = '';
  int _textIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.text.length * 100),
    )..addListener(() {
        final textLength = (widget.text.length * _controller.value).round();
        if (textLength != _textIndex) {
          setState(() {
            _displayText = widget.text.substring(0, textLength);
            _textIndex = textLength;
          });
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.textStyle,
    );
  }
}