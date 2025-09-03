import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glossy/glossy.dart';
import '../../../controllers/tutorial/tutorial_controller.dart';
import '../molecules/tutorial_step_widget.dart';

class TutorialLayout extends StatefulWidget {
  final TutorialController controller;
  final bool isLoading;

  const TutorialLayout({
    super.key,
    required this.controller,
    this.isLoading = false,
  });

  @override
  State<TutorialLayout> createState() => _TutorialLayoutState();
}

class _TutorialLayoutState extends State<TutorialLayout>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: colorScheme.secondary,
      body: Column(
        children: [
          // Header con skip button
          _buildHeader(theme, colorScheme, isWeb),

          // Contenido principal con PageView
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 800 : double.infinity,
                ),
                child: _buildPageView(theme, colorScheme),
              ),
            ),
          ),

          // Footer con controles de navegación
          _buildFooter(theme, colorScheme, isWeb),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, bool isWeb) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo o título
            FadeTransition(
              opacity: _fadeController,
              child: Text(
                'SwapMe',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Skip button
            FadeTransition(
              opacity: _fadeController,
              child: TextButton(
                onPressed: widget.controller.skipTutorial,
                child: Text(
                  'Omitir',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: PageView.builder(
              controller: widget.controller.pageController,
              onPageChanged: widget.controller.onPageChanged,
              itemCount: widget.controller.tutorialSteps.length,
              itemBuilder: (context, index) {
                final step = widget.controller.tutorialSteps[index];
                return TutorialStepWidget(
                  step: step,
                  theme: theme,
                  colorScheme: colorScheme,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(ThemeData theme, ColorScheme colorScheme, bool isWeb) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isWeb ? 800 : double.infinity),
        child: GlossyContainer(
          width: double.infinity,
          height: 120,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicadores de página
                _buildPageIndicators(theme, colorScheme),

                const SizedBox(height: 16),

                // Botones de navegación
                _buildNavigationButtons(theme, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators(ThemeData theme, ColorScheme colorScheme) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.controller.tutorialSteps.length, (
          index,
        ) {
          final isActive = index == widget.controller.currentPage.value;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );
    });
  }

  Widget _buildNavigationButtons(ThemeData theme, ColorScheme colorScheme) {
    return Obx(() {
      final isFirstPage = widget.controller.currentPage.value == 0;
      final isLastPage =
          widget.controller.currentPage.value ==
          widget.controller.tutorialSteps.length - 1;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          if (!isFirstPage)
            TextButton(
              onPressed: widget.controller.previousPage,
              child: Text(
                'Anterior',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outlineVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox(width: 80),

          // Botón siguiente/continuar
          ElevatedButton(
            onPressed: widget.isLoading ? null : widget.controller.nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    isLastPage ? 'Comenzar' : 'Siguiente',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      );
    });
  }
}
