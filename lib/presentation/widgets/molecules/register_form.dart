import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/auth/login_controller.dart';
import '../atoms/animated_button.dart';

class RegisterForm extends GetView<LoginController> {
  final VoidCallback? onSubmit;
  final bool isLoading;

  const RegisterForm({super.key, this.onSubmit, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Variables para controlar la visibilidad de las contraseñas
    final RxBool obscurePassword = true.obs;
    final RxBool obscurePasswordConfirm = true.obs;

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
            'Nombre',
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
              style: TextStyle(fontSize: fontSize),
              decoration: InputDecoration(
                hintText: 'nombre',
                hintStyle: TextStyle(fontSize: fontSize),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isWeb ? 18 : 14,
                ),
              ),
              onChanged: (String v) => controller.setRegisterName(v),
            ),
          ),

          SizedBox(height: spacing),
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
              onChanged: (String v) => controller.setRegisterEmail(v),
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
          _buildInputContainer(
            height: inputHeight,
            fontSize: fontSize,
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
                onChanged: (String v) => controller.setRegisterPassword(v),
              ),
            ),
          ),

          SizedBox(height: spacing),
          Text(
            'Confirmar Contraseña',
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
            child: Obx(
              () => TextFormField(
                obscureText: obscurePasswordConfirm.value,
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
                      obscurePasswordConfirm.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    onPressed: () => obscurePasswordConfirm.value =
                        !obscurePasswordConfirm.value,
                  ),
                ),
                onChanged: (String v) =>
                    controller.setRegisterPasswordConfirm(v),
              ),
            ),
          ),

          SizedBox(height: spacing),
          AnimatedButton(
            text: 'Crear Cuenta',
            onPressed: isLoading
                ? null
                : (onSubmit ?? () => controller.handleRegisterPressed(context)),
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            width: double.infinity,
            height: buttonHeight,
            borderRadius: BorderRadius.circular(16),
            isLoading: isLoading,
          ),

          // Enlace a términos y condiciones
          Center(
            child: GestureDetector(
              onTap: () => _launchTermsAndConditions(),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSize - 2,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  children: [
                    const TextSpan(
                      text: 'Al crear una cuenta, aceptas nuestros ',
                    ),
                    TextSpan(
                      text: 'Términos',
                      style: TextStyle(
                        color: colorScheme.primaryContainer,
                        decoration: TextDecoration.underline,
                        decorationColor: colorScheme.primaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  Future<void> _launchTermsAndConditions() async {
    final Uri url = Uri.parse('https://swapme-landing.vercel.app/terms');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'No se pudo abrir los términos y condiciones',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo abrir los términos y condiciones',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
