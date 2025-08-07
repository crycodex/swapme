import 'package:flutter/material.dart';
import 'package:glossy/glossy.dart';
import 'package:video_player/video_player.dart';
import '../molecules/login_form.dart';
import '../molecules/social_login_buttons.dart';
import '../molecules/register_form.dart';
import '../molecules/forgot_form.dart';

class LoginLayout extends StatefulWidget {
  final VoidCallback? onLoginPressed;
  final VoidCallback? onGoogleLoginPressed;
  final VoidCallback? onAppleLoginPressed;
  final VoidCallback? onRegisterSubmit;
  final VoidCallback? onForgotSubmit;
  final bool isLoading;

  const LoginLayout({
    super.key,
    this.onLoginPressed,
    this.onGoogleLoginPressed,
    this.onAppleLoginPressed,
    this.onRegisterSubmit,
    this.onForgotSubmit,
    this.isLoading = false,
  });

  @override
  State<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout>
    with TickerProviderStateMixin {
  static const double _glassHeightFactor = 0.75;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  VideoPlayerController? _videoController;
  late PageController _pageController;
  int _currentPage = 1; // 0: Forgot, 1: Login, 2: Register

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
    _pageController = PageController(initialPage: _currentPage);
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/vids/login/bg.mp4');

    try {
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.play();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al cargar el video: $e');
    }
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });
  }

  void _goToPage(int index) {
    if (index == _currentPage) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
    setState(() {
      _currentPage = index;
    });
  }

  String _getTopBarTitle() {
    switch (_currentPage) {
      case 0:
        return 'Forgot';
      case 2:
        return 'Create';
      default:
        return 'Login';
    }
  }

  String _getCardTitle() {
    switch (_currentPage) {
      case 0:
        return 'Olvidaste tu contraseña?';
      case 2:
        return 'Regístrate';
      default:
        return 'Inicia Sesión';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double screenHeight = MediaQuery.of(context).size.height;

    final Animation<Offset> slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    final Animation<double> fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.3),
        ),
        child: Stack(
          children: [
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.secondary.withValues(alpha: 0.8),
                        colorScheme.secondary.withValues(alpha: 0.6),
                        colorScheme.secondary.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: ClothesPatternPainter(colorScheme: colorScheme),
                  ),
                ),
              ),

            SafeArea(
              child: AnimatedBuilder(
                animation: fadeAnimation,
                builder: (BuildContext context, Widget? child) {
                  return Opacity(
                    opacity: fadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _getTopBarTitle(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: slideAnimation,
                builder: (BuildContext context, Widget? child) {
                  return SlideTransition(
                    position: slideAnimation,
                    child: GlossyContainer(
                      width: double.infinity,
                      height: screenHeight * _glassHeightFactor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCardTitle(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                physics: const PageScrollPhysics(),
                                onPageChanged: (int index) {
                                  setState(() => _currentPage = index);
                                },
                                children: [
                                  _buildForgotPage(theme, colorScheme),
                                  _buildLoginPage(theme, colorScheme),
                                  _buildRegisterPage(theme, colorScheme),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPage(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: LoginForm(
              onLoginPressed: widget.onLoginPressed,
              onForgotPressed: () => _goToPage(0),
              isLoading: widget.isLoading,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o inicia con',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SocialLoginButtons(
          onGooglePressed: widget.onGoogleLoginPressed,
          onApplePressed: widget.onAppleLoginPressed,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => _goToPage(2),
            child: Text(
              '¿No tienes cuenta? Regístrate',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterPage(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: RegisterForm(
              onSubmit: widget.onRegisterSubmit,
              isLoading: widget.isLoading,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => _goToPage(1),
            child: Text(
              '¿Ya tienes cuenta? Inicia sesión',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPage(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ForgotForm(
              onSubmit: widget.onForgotSubmit,
              isLoading: widget.isLoading,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => _goToPage(1),
            child: Text(
              'Volver a iniciar sesión',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ClothesPatternPainter extends CustomPainter {
  final ColorScheme colorScheme;

  ClothesPatternPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = colorScheme.onSecondary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 12; j++) {
        final double x = (size.width / 8) * i + (size.width / 16);
        final double y = (size.height / 12) * j + (size.height / 24);
        canvas.drawCircle(Offset(x, y), 20 + (i % 3) * 10.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
