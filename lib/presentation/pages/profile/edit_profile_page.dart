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
    final TextEditingController pinCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Obx(() {
        final bool darkMode = controller.isDarkMode.value;
        final String lang = controller.language.value.isEmpty
            ? 'es'
            : controller.language.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Basic info', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: lang,
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (String? v) {
                if (v != null) controller.updateLanguage(v);
              },
              decoration: const InputDecoration(labelText: 'Language'),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              value: darkMode,
              title: const Text('Dark mode'),
              onChanged: (_) => controller.toggleTheme(),
            ),
            const Divider(height: 32),
            Text('Security', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              value: controller.isAppLockEnabled.value,
              title: const Text('App lock (push notifications example)'),
              onChanged: (bool v) => controller.toggleAppLock(v),
            ),
            SwitchListTile.adaptive(
              value: controller.isBiometricEnabled.value,
              title: const Text('Face ID'),
              onChanged: (bool v) => controller.toggleBiometric(v),
            ),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN Code'),
              onChanged: (String v) => controller.updatePin(v),
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
              child: const Text('Save changes'),
            ),
          ],
        );
      }),
    );
  }
}
