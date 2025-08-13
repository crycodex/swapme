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
          _buildInputContainer(
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
              onChanged: (String v) => controller.setEmail(v),
            ),
          ),

          const SizedBox(height: 20),
          AnimatedButton(
            text: 'Cambiar Contraseña',
            onPressed: isLoading
                ? null
                : (onSubmit ?? () => controller.handleForgotSubmit(context)),
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

  Widget _buildInputContainer({required Widget child}) {
    return Container(
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
