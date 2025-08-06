import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/welcome/welcome_controller.dart';
import '../../widgets/organisms/welcome_layout.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _bounceController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final welcomeController = ref.watch(welcomeControllerProvider.notifier);
    final welcomeState = ref.watch(welcomeControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: WelcomeLayout(
        fadeController: _fadeController,
        slideController: _slideController,
        bounceController: _bounceController,
        scaleController: _scaleController,
        onStartPressed: () => welcomeController.handleStartPressed(context),
        isLoading: welcomeState.isLoading,
      ),
    );
  }
}
