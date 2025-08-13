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

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
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
              decoration: const InputDecoration(
                hintText: 'email',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
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

          const SizedBox(height: 16),
          Text(
            'Contraseña',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
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
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '********',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
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

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed:
                  onForgotPressed ??
                  () => controller.handleForgotSubmit(context),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.secondary,
              ),
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),

          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 20),
          AnimatedButton(
            text: 'Iniciar',
            onPressed: isLoading
                ? null
                : () => (onLoginPressed != null
                      ? onLoginPressed!.call()
                      : controller.handleLoginPressed(context)),
            backgroundColor: colorScheme.primary,
            textColor: Colors.grey,
            width: double.infinity,
            height: 52,
            borderRadius: BorderRadius.circular(16),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
