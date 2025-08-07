import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/login_controller.dart';
import '../atoms/animated_button.dart';

class LoginForm extends GetView<LoginController> {
  final VoidCallback? onLoginPressed;
  final bool isLoading;

  const LoginForm({super.key, this.onLoginPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = Get.find<LoginController>();

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo Email
          Text(
            'Correo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                controller.setEmail(value);
              },
              validator: (value) {
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

          const SizedBox(height: 20),

          // Campo Contraseña
          Text(
            'Contraseña',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                controller.setPassword(value);
              },
              validator: (value) {
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

          // Mensaje de error
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
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

          const SizedBox(height: 24),

          // Botón de login
          AnimatedButton(
            text: 'Iniciar',
            onPressed: isLoading
                ? null
                : () {
                    onLoginPressed?.call();
                  },
            backgroundColor: Colors.green,
            textColor: Colors.white,
            width: double.infinity,
            height: 56,
            borderRadius: BorderRadius.circular(16),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
