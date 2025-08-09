import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/auth_controller.dart';

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
        final bool darkMode = controller.isDarkMode.value;
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
            _SectionTitle(title: 'Información básica'),
            _SettingsCard(
              children: [
                _FormTile(
                  label: 'Correo',
                  child: Text(
                    email,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 1),
                _FormTile(
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
                _FormTile(
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
                  backgroundColor: colorScheme.surfaceVariant,
                );
              },
              child: const Text('Guardar cambios'),
            ),
          ],
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _FormTile extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormTile({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}
