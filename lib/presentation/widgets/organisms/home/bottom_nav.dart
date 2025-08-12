import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  controller: controller,
                  colorScheme: colorScheme,
                ),
                _NavItem(
                  index: 1,
                  icon: Icons.storefront_rounded,
                  label: 'Store',
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
                  label: 'Messages',
                  controller: controller,
                  colorScheme: colorScheme,
                ),
                _NavItem(
                  index: 4,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  controller: controller,
                  colorScheme: colorScheme,
                ),
              ],
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
    final Color activeColor = colorScheme.secondary;
    final Color inactiveColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.changeIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
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
    return InkResponse(
      onTap: onPressed,
      radius: 36,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Icons.sync_alt_rounded, color: colorScheme.onPrimary),
      ),
    );
  }
}
