import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/swap/swap_controller.dart';
import '../atoms/camera_control_button.dart';
import '../atoms/capture_button.dart';

class CameraControls extends StatelessWidget {
  final SwapController controller;

  const CameraControls({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final File? capturedImage = controller.capturedImage.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: capturedImage != null
            ? _buildImagePreviewControls(context, capturedImage)
            : _buildCameraControls(context),
      );
    });
  }

  Widget _buildCameraControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Flash toggle
        Obx(() => CameraControlButton(
              icon: controller.isFlashOn.value
                  ? Icons.flash_on
                  : Icons.flash_off,
              onTap: controller.toggleFlash,
              isActive: controller.isFlashOn.value,
            )),

        // Capture button
        Obx(() => CaptureButton(
              onTap: controller.capturePhoto,
              isLoading: controller.isLoading.value,
            )),

        // Close button
        CameraControlButton(
          icon: Icons.close,
          onTap: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildImagePreviewControls(BuildContext context, File image) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Image preview
        Container(
          width: 120,
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Retake button
            CameraControlButton(
              icon: Icons.refresh,
              onTap: controller.retakePhoto,
            ),

            // Continue to form button
            Container(
              width: 120,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    // Scroll to form section or navigate
                    // For now, we'll handle this in the parent organism
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: colorScheme.onPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Continuar',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            CameraControlButton(
              icon: Icons.close,
              onTap: () => Get.back(),
            ),
          ],
        ),
      ],
    );
  }
}
