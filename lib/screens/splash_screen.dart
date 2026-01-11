import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Fade in effect
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Smooth "pop" scaling effect
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if system is in dark mode or light mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamic colors based on theme
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    final Color accentColor = const Color(0xFF2575FC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Subtle Background Accents (Blurred Circles)
          Positioned(
            top: -50,
            right: -50,
            child: _buildBackgroundCircle(accentColor.withOpacity(isDark ? 0.15 : 0.08), 250),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _buildBackgroundCircle(const Color(0xFF6A11CB).withOpacity(isDark ? 0.1 : 0.05), 300),
          ),

          // 2. Main Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Identity Card
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(isDark ? 0.2 : 0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        height: 90,
                        width: 90,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.auto_graph_rounded,
                          size: 70,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    
                    // App Name
                    Text(
                      'NOVA',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Modern Tagline
                    Text(
                      'FINANCE REIMAGINED',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Footer Loader & Branding
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: subTextColor.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}