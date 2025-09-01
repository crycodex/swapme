import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:glossy/glossy.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final isTablet = screenWidth > 400 && screenWidth <= 600;

    // Ajustar tamaños según dispositivo
    final glassHeightFactor = isWeb ? 0.85 : _glassHeightFactor;
    final borderRadius = isWeb ? 40.0 : 30.0;
    final padding = isWeb
        ? const EdgeInsets.fromLTRB(40, 30, 40, 40)
        : const EdgeInsets.fromLTRB(20, 20, 20, 28);
    final titleSpacing = isWeb ? 32.0 : 24.0;

    final Animation<Offset> slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

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

            // Contenedor principal con glassmorphism
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: slideAnimation,
                builder: (BuildContext context, Widget? child) {
                  return SlideTransition(
                    position: slideAnimation,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWeb ? 500 : double.infinity,
                        ),
                        child: GlossyContainer(
                          width: double.infinity,
                          height: screenHeight * glassHeightFactor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius),
                            topRight: Radius.circular(borderRadius),
                          ),
                          child: Padding(
                            padding: padding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getCardTitle(),
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isWeb ? 28 : 24,
                                      ),
                                ),
                                SizedBox(height: titleSpacing),
                                Expanded(
                                  child: PageView(
                                    controller: _pageController,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
        // Separador "o inicia con" solo si hay botones sociales
        _buildSocialLoginSection(theme, colorScheme),
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

  Widget _buildSocialLoginSection(ThemeData theme, ColorScheme colorScheme) {
    // Verificar si hay botones sociales para mostrar
    bool hasSocialButtons = false;

    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        hasSocialButtons = true;
      }
    }

    if (!hasSocialButtons) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(height: 1, color: colorScheme.onSecondary),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o inicia con',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondary,
                ),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: colorScheme.onSecondary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SocialLoginButtons(
          onGooglePressed: widget.onGoogleLoginPressed,
          onApplePressed: widget.onAppleLoginPressed,
        ),
        const SizedBox(height: 12),
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
