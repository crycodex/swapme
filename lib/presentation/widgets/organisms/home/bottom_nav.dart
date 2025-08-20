import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:get/get.dart';
import '../../../../controllers/home/home_controller.dart';

class BottomNavBar extends StatelessWidget {
  final HomeController controller;
  final ColorScheme colorScheme;
  const BottomNavBar({
    super.key,
    required this.controller,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 125,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface.withValues(alpha: 0.8),
                  colorScheme.surface.withValues(alpha: 0.95),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Inicio',
                      controller: controller,
                      colorScheme: colorScheme,
                    ),
                    _NavItem(
                      index: 1,
                      icon: Icons.storefront_rounded,
                      label: 'Tienda',
                      controller: controller,
                      colorScheme: colorScheme,
                    ),
                    _CenterAction(
                      onPressed: () => Get.toNamed('/create-swap'),
                      isActive: controller.currentIndex.value == 2,
                      colorScheme: colorScheme,
                    ),
                    _NavItem(
                      index: 3,
                      icon: Icons.chat_bubble_rounded,
                      label: 'Mensajes',
                      controller: controller,
                      colorScheme: colorScheme,
                    ),
                    _NavItem(
                      index: 4,
                      icon: Icons.person_rounded,
                      label: 'Perfil',
                      controller: controller,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final HomeController controller;
  final ColorScheme colorScheme;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.controller,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = controller.currentIndex.value == index;
    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.onSurface.withValues(alpha: 0.75);
    final Color activeBackgroundColor = colorScheme.primaryContainer;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.changeIndex(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  width: isActive ? 48 : 40,
                  height: isActive ? 32 : 28,
                  padding: const EdgeInsets.all(4),
                  decoration: isActive
                      ? BoxDecoration(
                          color: activeBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: Icon(
                    icon,
                    color: isActive
                        ? colorScheme.onPrimaryContainer
                        : inactiveColor,
                    size: isActive ? 22 : 20,
                    semanticLabel: label,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  style: TextStyle(
                    color: isActive ? activeColor : inactiveColor,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: isActive ? 12 : 11,
                    letterSpacing: 0.1,
                  ),
                  child: Text(label, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;
  final ColorScheme colorScheme;

  const _CenterAction({
    required this.onPressed,
    required this.isActive,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Symbols.cached,
              color: colorScheme.onPrimary,
              size: 30,
              semanticLabel: 'Crear intercambio',
            ),
          ),
        ),
      ),
    );
  }
}
