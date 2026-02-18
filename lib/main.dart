import 'dart:html' as html;  // Add this import
import 'services/ocr_service.dart';
import 'config/env_config.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';  // Add this import at the top
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';  // Changed this line
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
//import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
//import 'package:google_ml_kit/google_ml_kit.dart';
//import 'package:image/image.dart' as img;
import 'dart:math' show min, max;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  
  runApp(const AarogyaAI());
}

class AarogyaAI extends StatefulWidget {
  const AarogyaAI({super.key});

  @override
  State<AarogyaAI> createState() => _AarogyaAIState();
}

class _AarogyaAIState extends State<AarogyaAI> {
  bool isDarkMode = true;

  ThemeData _buildTheme(bool isDark) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: isDark 
          ? ColorScheme.dark(
              primary: Color(0xFF00FF94),
              secondary: Color(0xFF00FF94).withOpacity(0.5),
              surface: Color(0xFF1A1A1A),
              background: Color(0xFF000000),
            )
          : ColorScheme.light(
              primary: Color(0xFF00BA6C),
              secondary: Color(0xFF00BA6C).withOpacity(0.5),
              surface: Colors.white,
              background: Color(0xFFF5F5F5),
            ),
      scaffoldBackgroundColor: isDark ? Color(0xFF000000) : Color(0xFFF5F5F5),
      cardTheme: CardThemeData(
        color: isDark ? Color(0xFF1A1A1A) : Colors.white,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF00FF94), width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        // Add these new properties
        labelStyle: TextStyle(color: Color(0xFF00FF94)),
        hintStyle: TextStyle(color: Colors.white70),
        prefixIconColor: Color(0xFF00FF94),
        // Set text style for input
        suffixStyle: TextStyle(color: Color(0xFF00FF94)),
      ),
      // Add text selection theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFF00FF94),
        selectionColor: Color(0xFF00FF94).withOpacity(0.3),
        selectionHandleColor: Color(0xFF00FF94),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00FF94),
          foregroundColor: Colors.black,
          minimumSize: Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Color(0xFF00FF94),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF00FF94)),
        titleTextStyle: TextStyle(
          color: Color(0xFF00FF94),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF00FF94),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF00FF94),
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aarogya AI',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(isDarkMode),
      home: const SplashScreen(), // Change this line back to SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _playCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Add listener to track completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _playCount++;
        if (_playCount < 2) {
          // Play again if we haven't played twice
          _controller.reset();
          _controller.forward();
        } else {
          // Check auth after second play
          _checkAuth();
        }
      }
    });
    
    // Start first play
    _controller.forward();
  }

  Future<void> _checkAuth() async {
    try {
      // Get the current session
      final session = Supabase.instance.client.auth.currentSession;
      
      // Get stored credentials if they exist
      final user = Supabase.instance.client.auth.currentUser;

      if (mounted) {
        if (session != null && user != null) {
          // User is already logged in, navigate to HomePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          // No valid session, go to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      // Handle any errors during auto-login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/animations/splashscreen.json',
                controller: _controller,
                fit: BoxFit.contain,
                onLoaded: (composition) {
                  // Optional: Adjust controller duration to match animation
                  _controller.duration = composition.duration;
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AarogyaAI',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _emailController.addListener(_updateFoxAnimation);
    _passwordController.addListener(_updateFoxAnimation);
  }

  void _updateFoxAnimation() {
    final text = _emailController.text + _passwordController.text;
    if (text.isEmpty) {
      _controller.animateTo(0);
    } else {
      final double newValue = (text.length % 30) / 30;
      _controller.animateTo(newValue);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Lottie Animation
              SizedBox(
                height: 200,
                child: Lottie.asset(
                  'assets/animations/fox.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Color(0xFF00FF94)), // Add this line
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                style: TextStyle(color: Color(0xFF00FF94)), // Add this line
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading ? null : _forgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _signIn,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Sign In'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                ),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Add SignUpPage
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _emailController.addListener(_updateFoxAnimation);
    _passwordController.addListener(_updateFoxAnimation);
    _confirmPasswordController.addListener(_updateFoxAnimation);
  }

  void _updateFoxAnimation() {
    final text = _emailController.text + _passwordController.text + _confirmPasswordController.text;
    if (text.isEmpty) {
      _controller.animateTo(0);
    } else {
      final double newValue = (text.length % 30) / 30;
      _controller.animateTo(newValue);
    }
  }

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check your email to confirm your account')),
        );
        Navigator.of(context).pop(); // Go back to login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Lottie Animation
              SizedBox(
                height: 200,
                child: Lottie.asset(
                  'assets/animations/fox.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Color(0xFF00FF94)), // Add this line
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                style: TextStyle(color: Color(0xFF00FF94)), // Add this line
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                style: TextStyle(color: Color(0xFF00FF94)), // Add this line
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HealthParameter> parameters = [];
  HealthScore? healthScore;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadParameters();
  }

  Future<void> _loadParameters() async {
    try {
      final response = await Supabase.instance.client
          .from('health_parameters')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

      final params = (response as List)
          .map((json) => HealthParameter.fromJson(json))
          .toList();

      // Calculate health score
      final score = await HealthScore.calculateFromParameters(params);

      setState(() {
        parameters = params;
        healthScore = score;
      });
    } catch (e) {
      print('Error loading parameters: $e');
    }
  }

  Future<void> _uploadReport() async {
    try {
      setState(() => isLoading = true);

      if (kIsWeb) {
        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.accept = '.pdf,image/*';
        uploadInput.click();

        await uploadInput.onChange.first;
        if (uploadInput.files!.isEmpty) return;

        final file = uploadInput.files![0];
        final reader = html.FileReader();
        
        if (file.name.toLowerCase().endsWith('.pdf')) {
          reader.readAsArrayBuffer(file);
        } else {
          reader.readAsDataUrl(file);
        }

        final bytes = await reader.onLoad.first.then((_) {
          if (file.name.toLowerCase().endsWith('.pdf')) {
            return reader.result as List<int>;
          } else {
            final dataUrl = reader.result as String;
            return base64Decode(dataUrl.split(',')[1]);
          }
        });

        // Show loading dialog
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xFF1A1A1A),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF94)),
                ),
                SizedBox(height: 16),
                Text(
                  file.name.toLowerCase().endsWith('.pdf') 
                      ? 'Processing PDF...' 
                      : 'Processing Image...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );

        final isPdf = file.name.toLowerCase().endsWith('.pdf');
        final text = await ReportProcessor.extractText(bytes, isPdf);
        
        if (text.isEmpty) {
          throw 'No text could be extracted from the document';
        }

        final newParameters = await ReportProcessor.processReport(text);
        await ReportProcessor.saveParameters(newParameters);
        await _loadParameters();

        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report processed successfully'),
            backgroundColor: Color(0xFF00FF94),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Existing FilePicker code for non-web platforms
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          withData: true,
        );

        if (result == null || result.files.isEmpty) return;
        
        final bytes = result.files.first.bytes!;
        final isPdf = result.files.first.name.toLowerCase().endsWith('.pdf');
        
        // Process the file...
        // ... rest of your existing code ...
      }
    } catch (e) {
      if (!mounted) return;
      if (context.mounted) Navigator.pop(context); // Close dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final username = user?.email?.split('@')[0] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 12),
            const Text('Aarogya AI'),
          ],
        ),
        centerTitle: true,
        actions: [
          // Add theme toggle button
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final appState = context.findAncestorStateOfType<_AarogyaAIState>();
              appState?.toggleTheme();
            },
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Hello $username 👋',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (healthScore != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: HealthScoreWidget(
                      score: healthScore!,
                      parameters: parameters, // Add this line
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: parameters.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No health parameters yet'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _uploadReport,
                            child: const Text('Upload your first report'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final param = parameters[index];
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A1A1A),
                                Color(0xFF262626),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: HealthParameterCard(parameter: param),
                        );
                      },
                      childCount: parameters.length,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _uploadReport,
        icon: isLoading 
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.upload_file),
        label: Text(isLoading ? 'Processing...' : 'Upload Report'),
        backgroundColor: isLoading ? Colors.grey : Color(0xFF00FF94),
      ),
    );
  }
}

class HealthParameterCard extends StatelessWidget {
  final HealthParameter parameter;

  const HealthParameterCard({
    super.key,
    required this.parameter,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParameterDetailPage(parameter: parameter),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(parameter.icon, color: Color(0xFF00FF94), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      parameter.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                parameter.value.toString(),
                style: TextStyle(
                  color: Color(0xFF00FF94),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                parameter.unit,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: parameter.history.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            (entry.value['value'] as num).toDouble(),
                          );
                        }).toList(),
                        isCurved: true,
                        color: Color(0xFF00FF94),
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Color(0xFF00FF94).withOpacity(0.1),
                        ),
                      ),
                    ],
                    minY: parameter.history.isEmpty ? 0 : parameter.history
                        .map((h) => (h['value'] as num).toDouble())
                        .reduce(min),
                    maxY: parameter.history.isEmpty ? 100 : parameter.history
                        .map((h) => (h['value'] as num).toDouble())
                        .reduce(max),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthParameter {
  final String name;
  final String unit;
  final double value;
  final List<Map<String, dynamic>> history;
  final DateTime lastUpdated;

  const HealthParameter({
    required this.name,
    required this.unit,
    required this.value,
    required this.history,
    required this.lastUpdated,
  });

  IconData get icon {
    final name = this.name.toLowerCase();
    if (name.contains('blood') && name.contains('sugar')) return Icons.water_drop;
    if (name.contains('blood') && name.contains('pressure')) return Icons.favorite;
    if (name.contains('cholesterol')) return Icons.analytics;
    if (name.contains('hemoglobin')) return Icons.bloodtype;
    if (name.contains('thyroid')) return Icons.assignment;
    if (name.contains('vitamin')) return Icons.brightness_7;
    return Icons.medical_information;
  }

  factory HealthParameter.fromJson(Map<String, dynamic> json) {
    return HealthParameter(
      name: json['name'],
      unit: json['unit'],
      value: double.parse(json['value'].toString()),
      history: List<Map<String, dynamic>>.from(json['history'] ?? []),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}

class ParameterDetailPage extends StatelessWidget {
  final HealthParameter parameter;

  const ParameterDetailPage({
    super.key,
    required this.parameter,
  });

  @override
  Widget build(BuildContext context) {
    final history = parameter.history;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(parameter.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Value',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(parameter.icon, size: 32),
                        const SizedBox(width: 16),
                        Text(
                          parameter.value.toString(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          parameter.unit,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: const FlTitlesData(show: true),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: history.asMap().entries.map((entry) {
                                  return FlSpot(
                                    entry.key.toDouble(),
                                    (entry.value['value'] as num).toDouble(),
                                  );
                                }).toList(),
                                isCurved: true,
                                color: Theme.of(context).colorScheme.primary,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this class after HealthParameter class
class HealthScore {
  final double score;
  final String analysis;
  final List<String> recommendations;

  const HealthScore({
    required this.score,
    required this.analysis,
    required this.recommendations,
  });

  static Future<HealthScore> calculateFromParameters(List<HealthParameter> parameters) async {
    if (parameters.isEmpty) {
      return HealthScore(
        score: 0,
        analysis: "No health data available",
        recommendations: ["Upload your first medical report to get started"],
      );
    }

    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EnvConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a health analysis assistant. Always respond with valid JSON only.'
            },
            {
              'role': 'user',
              'content': '''Analyze these health parameters and return ONLY a JSON object with exactly these fields: score (0-100), analysis (string), and recommendations (array of strings).

Parameters:
${parameters.map((p) => '${p.name}: ${p.value} ${p.unit}').join('\n')}

Example response:
{
  "score": 85,
  "analysis": "Overall health appears good with normal values",
  "recommendations": [
    "Continue regular exercise",
    "Maintain balanced diet",
    "Regular checkups"
  ]
}'''
            }
          ],
          'temperature': 0.1, // Lower temperature for more consistent formatting
        }),
      );

      if (response.statusCode != 200) {
        throw 'API Error: ${response.body}';
      }

      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['choices'][0]['message']['content'].trim();
      
      // Clean the response to ensure it's valid JSON
      final cleanContent = content.replaceAll(RegExp(r'```json\n?|\n?```'), '');
      final Map<String, dynamic> parsed = jsonDecode(cleanContent);

      return HealthScore(
        score: parsed['score'].toDouble(),
        analysis: parsed['analysis'],
        recommendations: List<String>.from(parsed['recommendations']),
      );
    } catch (e) {
      print('Error calculating health score: $e');
      return HealthScore(
        score: 50,
        analysis: "Unable to calculate accurate score",
        recommendations: ["Please consult your healthcare provider for a proper evaluation"],
      );
    }
  }
}

// Add this widget after HealthScore class
class HealthScoreWidget extends StatelessWidget {
  final HealthScore score;
  final List<HealthParameter> parameters; // Add this line

  const HealthScoreWidget({
    super.key,
    required this.score,
    required this.parameters, // Add this line
  });

  String _getScoreEmoji(double score) {
    if (score >= 90) return '😃';
    if (score >= 70) return '😁';
    if (score >= 50) return '😀';
    if (score >= 20) return '😐';
    return '☹️';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Color(0xFF00FF94).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Color(0xFF151515),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00FF94).withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: score.score / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey[900],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              score.score > 70
                                  ? Color(0xFF00FF94)
                                  : score.score > 40
                                      ? Color(0xFFFFB800)
                                      : Color(0xFFFF4545),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getScoreEmoji(score.score),
                              style: TextStyle(fontSize: 28),
                            ),
                            Text(
                              score.score.round().toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF00FF94).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Health Score',
                        style: TextStyle(
                          color: Color(0xFF00FF94),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF151515),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        score.analysis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ...score.recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF00FF94).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Color(0xFF00FF94),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HealthChatBot(parameters: parameters), // Now parameters is available
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00FF94).withOpacity(0.1),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      icon: Icon(Icons.chat_bubble_outline, color: Color(0xFF00FF94)),
                      label: Text(
                        'Chat with AI Health Assistant',
                        style: TextStyle(
                          color: Color(0xFF00FF94),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this class before HomePage
class ReportProcessor {
  static Future<String> extractText(List<int> bytes, bool isPdf) async {
    if (isPdf) {
      return _extractTextFromPdf(bytes);
    } else {
      return _extractTextFromImage(bytes);
    }
  }

  static Future<String> _extractTextFromPdf(List<int> bytes) async {
    try {
      final document = PdfDocument(inputBytes: Uint8List.fromList(bytes));
      final extractor = PdfTextExtractor(document);
      final text = await extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      print('PDF processing error: $e');
      throw 'Failed to process PDF: $e';
    }
  }

  static Future<String> _extractTextFromImage(List<int> bytes) async {
    try {
      final text = await OcrService.extractTextFromImage(bytes);
      if (text.isEmpty) {
        throw 'No text detected in image';
      }
      return text;
    } catch (e) {
      print('Image processing error: $e');
      throw 'Failed to process image: $e';
    }
  }

  static Future<List<HealthParameter>> processReport(String text) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${EnvConfig.groqApiKey}',
      },
      body: jsonEncode({
        'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
        'messages': [
          {
            'role': 'user',
            'content': '''You are a medical report analyzer. Extract health parameters from this text and return ONLY a valid JSON array. 
            
            Text: $text
            
            Format each parameter as:
            {
              "name": "parameter name",
              "value": "numerical value only",
              "unit": "measurement unit"
            }
            
            Example response:
            [
              {"name": "Blood Sugar", "value": "95", "unit": "mg/dL"},
              {"name": "Hemoglobin", "value": "14.5", "unit": "g/dL"}
            ]'''
          }
        ],
        'temperature': 0.3, // Lower temperature for more consistent formatting
      }),
    );

    if (response.statusCode != 200) {
      throw 'API Error: ${response.body}';
    }

    try {
      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['choices'][0]['message']['content'];
      
      // Find the JSON array in the response
      final match = RegExp(r'\[(.*?)\]', dotAll: true).firstMatch(content);
      if (match == null) {
        throw 'No valid JSON array found in response';
      }
      
      final jsonString = match.group(1);
      if (jsonString == null) {
        throw 'Empty JSON array';
      }
      
      final List<dynamic> parsed = jsonDecode('[$jsonString]');
      final DateTime now = DateTime.now();
      
      return parsed.map((item) => HealthParameter(
        name: item['name'],
        unit: item['unit'],
        value: double.parse(item['value'].toString()),
        history: [],
        lastUpdated: now,
      )).toList();
    } catch (e) {
      print('Raw response: ${response.body}');
      throw 'Failed to parse response: $e';
    }
  }

  static Future<void> saveParameters(List<HealthParameter> parameters) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    for (final parameter in parameters) {
      final existing = await supabase
          .from('health_parameters')
          .select()
          .eq('user_id', userId)
          .eq('name', parameter.name)
          .maybeSingle();

      if (existing != null) {
        List<Map<String, dynamic>> history = List.from(existing['history'] ?? []);
        history.add({
          'value': parameter.value,
          'date': parameter.lastUpdated.toIso8601String(),
        });

        await supabase
            .from('health_parameters')
            .update({
              'value': parameter.value,
              'history': history,
              'last_updated': parameter.lastUpdated.toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('name', parameter.name);
      } else {
        await supabase.from('health_parameters').insert({
          'user_id': userId,
          'name': parameter.name,
          'unit': parameter.unit,
          'value': parameter.value,
          'history': [
            {
              'value': parameter.value,
              'date': parameter.lastUpdated.toIso8601String(),
            }
          ],
          'last_updated': parameter.lastUpdated.toIso8601String(),
        });
      }
    }
  }
}

// Remove this sample data as we'll get real data from Supabase
/* Remove this section
final healthParameters = [
  HealthParameter(
    name: 'Blood Sugar',
    unit: 'mg/dL',
    value: 95,
    history: [
      {'value': 90, 'date': '2024-05-20T10:00:00Z'},
      {'value': 95, 'date': '2024-05-21T10:00:00Z'}
    ],
    lastUpdated: DateTime.now(),
  ),
  // ... remove other samples
];
*/

class HealthChatBot extends StatefulWidget {
  final List<HealthParameter> parameters;

  const HealthChatBot({
    super.key,
    required this.parameters,
  });

  @override
  State<HealthChatBot> createState() => _HealthChatBotState();
}

class _HealthChatBotState extends State<HealthChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hello! I'm your personal health assistant. I have access to your health records and can answer any questions about your health parameters and provide general health advice.");
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        isUser: false,
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        isUser: true,
      ));
      _isTyping = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EnvConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a helpful medical assistant with access to the user's health parameters. 
              Here are their current health parameters:
              ${widget.parameters.map((p) => '${p.name}: ${p.value} ${p.unit}').join('\n')}
              
              Provide accurate, helpful advice based on their health data. If you're unsure, always recommend consulting a healthcare provider.'''
            },
            {'role': 'user', 'content': text},
          ],
          'temperature': 0.7,
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      final botResponse = jsonResponse['choices'][0]['message']['content'];
      
      _addBotMessage(botResponse);
    } catch (e) {
      _addBotMessage("Sorry, I encountered an error. Please try again.");
    } finally {
      setState(() => _isTyping = false);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Assistant is typing...'),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me about your health...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: Color(0xFF00FF94),
                child: Icon(Icons.medical_services, color: Colors.black),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Color(0xFF00FF94)
                    : Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: Color(0xFF00FF94),
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
