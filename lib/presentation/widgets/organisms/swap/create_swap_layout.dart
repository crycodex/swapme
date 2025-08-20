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
    return Obx(() {
      final bool hasImage = controller.capturedImage.value != null;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
            child: child,
          );
        },
        child: hasImage ? _buildFormView(context) : _buildCameraView(context),
      );
    });
  }

  Widget _buildCameraView(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData media = MediaQuery.of(context);

    return Scaffold(
      key: const ValueKey('camera'),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
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
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
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
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData media = MediaQuery.of(context);
    final double keyboardHeight = media.viewInsets.bottom;
    final bool isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      key: const ValueKey('form'),
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // Header con imagen adaptable
          SliverAppBar(
            expandedHeight: isKeyboardVisible ? 120 : media.size.height * 0.35,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: Stack(
                  children: [
                    // Close button
                    Positioned(
                      top: media.padding.top + 16,
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
                      top: media.padding.top + 16,
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
                    if (!isKeyboardVisible)
                      Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          margin: EdgeInsets.only(top: media.padding.top + 60),
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

                    // Mini imagen cuando el teclado está visible
                    if (isKeyboardVisible)
                      Positioned(
                        top: media.padding.top + 16,
                        left: 80,
                        right: 80,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
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
            ),
          ),

          // Formulario scrollable
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                // Contenido del formulario
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SwapFormSection(controller: controller),
                  ),
                ),

                // Botón de acción fijo al fondo
                Container(
                  color: colorScheme.surface,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        16 + (isKeyboardVisible ? 0 : 0),
                      ),
                      child: Obx(() {
                        final bool isEditing =
                            (controller.editingSwapId.value ?? '').isNotEmpty;
                        return SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => isEditing
                                      ? controller.saveEditedSwap()
                                      : controller.createSwapItem(),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    isEditing
                                        ? 'Guardar cambios'
                                        : 'Crear Swap',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
