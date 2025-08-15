import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../widgets/atoms/section_title.dart';
import '../../widgets/molecules/settings_card.dart';
import '../../widgets/molecules/form_tile.dart';

class EditProfilePage extends GetView<AuthController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextEditingController nameCtrl = TextEditingController(
      text: controller.userName.value,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Obx(() {
        final String lang = controller.language.value.isEmpty
            ? 'es'
            : controller.language.value;
        final String email = controller.userEmail.value;
        final String? photo = controller.profileImage.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header similar al profile
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => controller.pickAndUploadProfileImage(),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.18,
                      ),
                      backgroundImage: (photo != null && photo.isNotEmpty)
                          ? NetworkImage(photo)
                          : null,
                      child: (photo == null || photo.isEmpty)
                          ? Icon(
                              Icons.person_rounded,
                              color: colorScheme.primary,
                              size: 40,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => controller.pickAndUploadProfileImage(),
                      child: const Text('Cambiar foto'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card: Información básica
            const SectionTitle(title: 'Información básica'),
            SettingsCard(
              children: [
                FormTile(
                  label: 'Correo',
                  child: Text(
                    email,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 1),
                FormTile(
                  label: 'Nombre',
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nombre',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Divider(height: 1),
                FormTile(
                  label: 'Idioma',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: lang,
                      items: const [
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (String? v) {
                        if (v != null) controller.updateLanguage(v);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final String newName = nameCtrl.text.trim();
                if (newName.isNotEmpty) {
                  await controller.updateUserName(newName);
                }
                Get.back();
                Get.snackbar(
                  'Perfil',
                  'Datos guardados',
                  backgroundColor: colorScheme.surfaceContainerHighest,
                );
              },
              child: const Text('Guardar cambios'),
            ),

            const SizedBox(height: 24),
            const SectionTitle(title: 'Zona de peligro'),
            SettingsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Eliminar cuenta y datos',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                        onPressed: () => _confirmDelete(context),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

// Shared atoms/molecules moved to their own files (SectionTitle, SettingsCard, FormTile)

void _confirmDelete(BuildContext context) {
  final AuthController controller = Get.put(AuthController());
  Get.dialog(
    AlertDialog(
      title: const Text('Eliminar cuenta'),
      content: const Text(
        'Esta acción eliminará tu foto, tus colecciones y tu usuario. ¿Deseas continuar?',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () async {
            Get.back();
            await controller.deleteAccount();
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}
