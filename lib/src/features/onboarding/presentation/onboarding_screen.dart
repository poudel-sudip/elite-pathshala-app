import 'package:elite_pathshala/src/features/auth/auth_service.dart';
import 'package:elite_pathshala/src/features/auth/presentation/login_page.dart';
import 'package:elite_pathshala/src/features/home/presentation/main_scaffold.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _logoAnimated = false;
  bool _textAnimated = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _logoAnimated = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _textAnimated = true;
        });
      });
    });
  }

  Future<void> _handleNextPressed() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize auth service and check authentication
    await AuthService.initializeAuth();
    final isLoggedIn = await AuthService.isLoggedIn();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate based on authentication status
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(
                  0,
                  _logoAnimated ? 0 : -200,
                  0,
                ),
                child:
                    Image.asset('assets/images/app-icon.png', height: 150),
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(
                  0,
                  _textAnimated ? 0 : 200,
                  0,
                ),
                child: Image.asset('assets/images/app-text.png', height: 50),
              ),
              const SizedBox(height: 10),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _handleNextPressed,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
} 