import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/login_controller.dart';
import '../atoms/animated_button.dart';

class ForgotForm extends GetView<LoginController> {
  final VoidCallback? onSubmit;
  final bool isLoading;

  const ForgotForm({super.key, this.onSubmit, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Detectar plataforma y ajustar tamaños
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    // Ajustar tamaños según dispositivo
    final inputHeight = isWeb ? 56.0 : 48.0;
    final buttonHeight = isWeb ? 56.0 : 52.0;
    final fontSize = isWeb ? 16.0 : 14.0;
    final spacing = isWeb ? 20.0 : 16.0;
    final smallSpacing = isWeb ? 8.0 : 6.0;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
          SizedBox(height: smallSpacing),
          _buildInputContainer(
            height: inputHeight,
            fontSize: fontSize,
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: fontSize),
              decoration: InputDecoration(
                hintText: 'email',
                hintStyle: TextStyle(fontSize: fontSize),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isWeb ? 18 : 14,
                ),
              ),
              onChanged: (String v) => controller.setEmail(v),
            ),
          ),

          SizedBox(height: spacing),
          AnimatedButton(
            text: 'Cambiar Contraseña',
            onPressed: isLoading
                ? null
                : (onSubmit ?? () => controller.handleForgotSubmit(context)),
            backgroundColor: colorScheme.primary,
            textColor: Colors.grey,
            width: double.infinity,
            height: buttonHeight,
            borderRadius: BorderRadius.circular(16),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildInputContainer({
    required Widget child,
    required double height,
    required double fontSize,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
