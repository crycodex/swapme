import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/swap/swap_controller.dart';
import '../../atoms/camera_preview_widget.dart';
import '../../molecules/camera_controls.dart';
import '../../molecules/swap_form_section.dart';

class CreateSwapLayout extends GetView<SwapController> {
  const CreateSwapLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          final bool hasImage = controller.capturedImage.value != null;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      ),
                    ),
                child: child,
              );
            },
            child: hasImage
                ? _buildFormView(context)
                : _buildCameraView(context),
          );
        }),
      ),
    );
  }

  Widget _buildCameraView(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData media = MediaQuery.of(context);

    return Column(
      key: const ValueKey('camera'),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              Text(
                'Tomar Foto',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 40), // Balance
            ],
          ),
        ),

        // Camera preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(
              () => CameraPreviewWidget(
                controller: controller.cameraController,
                isInitialized: controller.isCameraInitialized.value,
              ),
            ),
          ),
        ),

        // Camera controls
        CameraControls(controller: controller),
        SizedBox(height: media.padding.bottom),
      ],
    );
  }

  Widget _buildFormView(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData media = MediaQuery.of(context);

    return Column(
      key: const ValueKey('form'),
      children: [
        // Header with image
        Container(
          height: media.size.height * 0.4,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.8),
                      colorScheme.primary.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 16,
                left: 20,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Retake button
              Positioned(
                top: 16,
                right: 20,
                child: GestureDetector(
                  onTap: controller.retakePhoto,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Captured image
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  margin: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Obx(
                      () => controller.capturedImage.value != null
                          ? Image.file(
                              controller.capturedImage.value!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: colorScheme.surface),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Form section
        Expanded(
          child: Column(
            children: [
              Expanded(child: SwapFormSection(controller: controller)),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() {
                    final bool isEditing =
                        (controller.editingSwapId.value ?? '').isNotEmpty;
                    return Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => isEditing
                                      ? controller.saveEditedSwap()
                                      : controller.createSwapItem(),
                            child: Text(
                              isEditing ? 'Guardar cambios' : 'Crear Swap',
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
