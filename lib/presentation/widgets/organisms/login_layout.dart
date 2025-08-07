import 'package:flutter/material.dart';
import 'package:glossy/glossy.dart';
import 'package:video_player/video_player.dart';
import '../molecules/login_form.dart';
import '../molecules/social_login_buttons.dart';

class LoginLayout extends StatefulWidget {
  final VoidCallback? onLoginPressed;
  final VoidCallback? onGoogleLoginPressed;
  final VoidCallback? onAppleLoginPressed;
  final VoidCallback? onRegisterPressed;
  final bool isLoading;

  const LoginLayout({
    super.key,
    this.onLoginPressed,
    this.onGoogleLoginPressed,
    this.onAppleLoginPressed,
    this.onRegisterPressed,
    this.isLoading = false,
  });

  @override
  State<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Animación para el contenedor glassmorphism
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    final fadeAnimation = Tween<double>(
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
            // Video de fondo
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
              // Fallback mientras se carga el video
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

            // Título en la parte superior
            SafeArea(
              child: AnimatedBuilder(
                animation: fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: fadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Login',
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

            // Contenedor glassmorphism principal - posicionado desde abajo
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: slideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: slideAnimation,
                    child: GlossyContainer(
                      width: double.infinity,
                      height:
                          screenHeight * 0.65, // Aumentado para que suba más
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título "Inicia Sesión"
                            Text(
                              'Inicia Sesión',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Formulario de login
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: LoginForm(
                                  onLoginPressed: widget.onLoginPressed,
                                  isLoading: widget.isLoading,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Separador
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
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
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Botones de login social
                            SocialLoginButtons(
                              onGooglePressed: widget.onGoogleLoginPressed,
                              onApplePressed: widget.onAppleLoginPressed,
                            ),

                            const SizedBox(height: 12),

                            // Enlace para registrarse
                            Center(
                              child: TextButton(
                                onPressed: widget.onRegisterPressed,
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
}

// Painter para crear un patrón de ropa placeholder
class ClothesPatternPainter extends CustomPainter {
  final ColorScheme colorScheme;

  ClothesPatternPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.onSecondary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Dibujar círculos que simulan ropa colgada
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 12; j++) {
        final x = (size.width / 8) * i + (size.width / 16);
        final y = (size.height / 12) * j + (size.height / 24);

        canvas.drawCircle(Offset(x, y), 20 + (i % 3) * 10.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
