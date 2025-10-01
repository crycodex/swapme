import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: Image.asset(
          'assets/app/swapme.gif',
          width: 269,
          height: 474,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
