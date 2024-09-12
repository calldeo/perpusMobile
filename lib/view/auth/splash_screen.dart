import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:belajar_flutter_perpus/view/auth/home_page.dart';
import 'package:flutter/material.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ganti LottieBuilder dengan Image.asset untuk menampilkan gambar
          Center(
            child: SizedBox(
              width: 200, // Set the desired width
              height: 200, // Set the desired height
              child: Image.asset(
                "assets/piticash_log.png",
                fit: BoxFit.contain, // Adjust the image fit as needed
              ),
            ),
          ),
        ],
      ),
      nextScreen: HomePage(),
      splashIconSize: 250, // Adjust the overall splash icon size
      backgroundColor: Color.fromARGB(253, 243, 243, 243),
    );
  }
}
