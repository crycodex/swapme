import 'package:flutter/material.dart';
import '../molecules/welcome_content.dart';
import 'package:glossy/glossy.dart';

class WelcomeLayout extends StatefulWidget {
  final VoidCallback? onStartPressed;
  final bool isLoading;

  const WelcomeLayout({super.key, this.onStartPressed, this.isLoading = false});

  @override
  State<WelcomeLayout> createState() => _WelcomeLayoutState();
}

class _WelcomeLayoutState extends State<WelcomeLayout>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _sliderController;

  double _sliderValue = 0.0;
  bool _isSliding = false;

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

    _sliderController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
    });

    if (value >= 1.0 && !_isSliding) {
      _isSliding = true;
      _sliderController.forward().then((_) {
        if (mounted && widget.onStartPressed != null) {
          widget.onStartPressed!();
        }
      });
    }
  }

  void _onSliderEnd() {
    if (_sliderValue < 1.0) {
      setState(() {
        _sliderValue = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    _sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Animación para el slider
    final sliderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    return Scaffold(
      backgroundColor: colorScheme.secondary,
      body: Column(
        children: [
          // Contenido principal (fondo púrpura)
          Expanded(
            child: WelcomeContent(
              fadeController: _fadeController,
              slideController: _slideController,
              bounceController: _bounceController,
              scaleController: _scaleController,
            ),
          ),

          // Área del slider con efecto glassmorphism
          GlossyContainer(
            width: double.infinity,
            height: 150, // Altura fija para el contenedor glossy
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Slider animado
                  AnimatedBuilder(
                    animation: sliderAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: sliderAnimation.value,
                        child: _buildSlider(),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Texto de ayuda
                  if (!widget.isLoading)
                    AnimatedBuilder(
                      animation: sliderAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: sliderAnimation.value.clamp(0.0, 1.0),
                          child: Text(
                            'Desliza para comenzar tu experiencia',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outlineVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Fondo de progreso
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: MediaQuery.of(context).size.width * 0.85 * _sliderValue,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(50),
            ),
          ),

          // Slider thumb
          Positioned(
            left:
                (MediaQuery.of(context).size.width * 0.85 - 48) * _sliderValue,
            top: 4,
            child: GestureDetector(
              onPanUpdate: (details) {
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(
                  details.globalPosition,
                );
                final maxWidth = MediaQuery.of(context).size.width * 0.85 - 48;
                final newValue = (localPosition.dx / maxWidth).clamp(0.0, 1.0);
                _onSliderChanged(newValue);
              },
              onPanEnd: (_) => _onSliderEnd(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _sliderValue >= 1.0 ? Icons.check : Icons.arrow_forward,
                  color: colorScheme.onSecondary,
                  size: 24,
                ),
              ),
            ),
          ),

          // Texto del slider
          Center(
            child: Text(
              _sliderValue >= 1.0 ? 'Bienvenido!' : 'Desliza',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
