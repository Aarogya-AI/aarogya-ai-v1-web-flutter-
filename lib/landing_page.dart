import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'main.dart';  // Add this import to access LoginPage and SignUpPage

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background with gradient and particles
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A1F),
                  Color(0xFF1A1A3F),
                ],
                stops: [0, 1],
              ),
            ),
          ),
          
          // Parallax content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Navigation bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo and name
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: _AnimatedLogo(),
                      ),
                      
                      // Auth buttons
                      Row(
                        children: [
                          _HoverButton(
                            text: 'Login',
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),  // Add const
                            ),
                          ),
                          SizedBox(width: 16),
                          _HoverButton(
                            text: 'Sign Up',
                            isPrimary: true,
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const SignUpPage()),  // Add const
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Hero section
                Transform.translate(
                  offset: Offset(0, -_scrollOffset * 0.5),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome to',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [Color(0xFF00FF94), Colors.blue],
                                ).createShader(bounds),
                                child: Text(
                                  'Aarogya AI',
                                  style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Your Personal Health Analytics Platform',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Features section
                Container(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Column(
                    children: [
                      _FeatureCard(
                        title: 'AI-Powered Health Analysis',
                        description: 'Upload your medical reports and get instant insights powered by advanced AI.',
                        icon: Icons.analytics,
                        offset: _scrollOffset,
                      ),
                      _FeatureCard(
                        title: 'Smart Health Score',
                        description: 'Track your overall health with our comprehensive health score system.',
                        icon: Icons.favorite,
                        offset: _scrollOffset,
                        isReversed: true,
                      ),
                      _FeatureCard(
                        title: 'Personal Health Assistant',
                        description: 'Chat with our AI assistant about your health data and get personalized advice.',
                        icon: Icons.chat_bubble,
                        offset: _scrollOffset,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.1 : 1.0),
        child: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            SizedBox(width: 12),
            Text(
              'Aarogya AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isPrimary;

  const _HoverButton({
    required this.text,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_isHovered ? Color(0xFF00FF94) : Color(0xFF00FF94).withOpacity(0.8))
                : (_isHovered ? Colors.white.withOpacity(0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.isPrimary ? Colors.transparent : Colors.white30,
            ),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isPrimary ? Colors.black : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double offset;
  final bool isReversed;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.offset,
    this.isReversed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(
        isReversed ? offset * 0.3 : -offset * 0.3,
        0,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFF00FF94).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            if (!isReversed) _buildIcon(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: isReversed
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF00FF94),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: isReversed ? TextAlign.right : TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            if (isReversed) _buildIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF00FF94).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        size: 32,
        color: Color(0xFF00FF94),
      ),
    );
  }
}