import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/login_controller.dart';
import '../atoms/animated_button.dart';

class LoginForm extends GetView<LoginController> {
  final VoidCallback? onLoginPressed;
  final VoidCallback? onForgotPressed;
  final bool isLoading;

  const LoginForm({
    super.key,
    this.onLoginPressed,
    this.onForgotPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final LoginController controller = Get.put(LoginController());

    // Variable para controlar la visibilidad de la contraseña
    final RxBool obscurePassword = true.obs;

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
          Container(
            height: inputHeight,
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
              onChanged: (String value) {
                controller.setEmail(value);
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu correo';
                }
                if (!value.contains('@')) {
                  return 'Por favor ingresa un correo válido';
                }
                return null;
              },
            ),
          ),

          SizedBox(height: spacing),
          Text(
            'Contraseña',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
          SizedBox(height: smallSpacing),
          Container(
            height: inputHeight,
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
            child: Obx(
              () => TextFormField(
                obscureText: obscurePassword.value,
                style: TextStyle(fontSize: fontSize),
                decoration: InputDecoration(
                  hintText: '********',
                  hintStyle: TextStyle(fontSize: fontSize),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isWeb ? 18 : 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    onPressed: () =>
                        obscurePassword.value = !obscurePassword.value,
                  ),
                ),
                onChanged: (String value) {
                  controller.setPassword(value);
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
            ),
          ),

          SizedBox(height: smallSpacing),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed:
                  onForgotPressed ??
                  () => controller.handleForgotSubmit(context),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.secondary,
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 8 : 4,
                  vertical: isWeb ? 8 : 4,
                ),
              ),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(fontSize: fontSize - 1),
              ),
            ),
          ),

          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: smallSpacing),
                child: Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontSize: fontSize - 2,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          SizedBox(height: spacing),
          AnimatedButton(
            text: 'Iniciar',
            onPressed: isLoading
                ? null
                : () => (onLoginPressed != null
                      ? onLoginPressed!.call()
                      : controller.handleLoginPressed(context)),
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            width: double.infinity,
            height: buttonHeight,
            borderRadius: BorderRadius.circular(16),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
