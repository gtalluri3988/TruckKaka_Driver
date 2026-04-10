import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/api_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/local_storage/stored_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    ApiService.init();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    await StoredData.applyStoredLocale();

    final isAuth = await StoredData.isAuthenticated();
    if (!mounted) return;

    if (isAuth) {
      Get.offAllNamed(AppRoute.dashboard);
    } else {
      Get.offAllNamed(AppRoute.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2A49),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B2A49), Color(0xFF274472)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo — identical Hero tag and CircleAvatar as TruckKaka_Mobile
                Hero(
                  tag: 'asva_logo',
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/dashboard/ASVAlogo.png',
                        fit: BoxFit.contain,
                        height: 100,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // App name
                const Text(
                  'ASVA Technologies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Driver-specific subtitle
                const Text(
                  'Driver App',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 80),

                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  strokeWidth: 2.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
