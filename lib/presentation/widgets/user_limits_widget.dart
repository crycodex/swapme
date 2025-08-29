import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/limits/user_limits_controller.dart';

class UserLimitsWidget extends StatelessWidget {
  const UserLimitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final UserLimitsController controller = Get.find<UserLimitsController>();

    return Obx(() {
      final userLimits = controller.userLimits.value;

      if (controller.isLoading.value) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (userLimits == null) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No se pudieron cargar los límites'),
          ),
        );
      }

      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    userLimits.isPremium ? Icons.star : Icons.person,
                    color: userLimits.isPremium ? Colors.amber : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userLimits.isPremium
                        ? 'Usuario Premium'
                        : 'Usuario Gratuito',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: userLimits.isPremium ? Colors.amber : Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  if (!userLimits.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Con Anuncios',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Información de swaps
              _buildInfoRow(
                context,
                icon: Icons.swap_horiz,
                title: 'Swaps',
                value: userLimits.isPremium
                    ? 'Ilimitados'
                    : '${userLimits.totalSwaps}/${userLimits.maxSwaps}',
                color: userLimits.canSwap ? Colors.green : Colors.red,
              ),

              if (!userLimits.isPremium) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: userLimits.totalSwaps / userLimits.maxSwaps,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    userLimits.hasReachedSwapLimit ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Swaps restantes: ${userLimits.remainingSwaps}',
                  style: TextStyle(
                    color: userLimits.hasReachedSwapLimit
                        ? Colors.red
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Permisos
              _buildInfoRow(
                context,
                icon: Icons.store,
                title: 'Crear Tienda',
                value: userLimits.canCreateStore ? 'Permitido' : 'No permitido',
                color: userLimits.canCreateStore ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 16),

              // Botón para actualizar a premium
              if (!userLimits.isPremium)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showPremiumUpgradeDialog(context, controller),
                    icon: const Icon(Icons.star),
                    label: const Text('Actualizar a Premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showPremiumUpgradeDialog(
    BuildContext context,
    UserLimitsController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar a Premium'),
        content: const Text(
          '¿Deseas actualizar tu cuenta a Premium? '
          'Obtendrás swaps ilimitados, sin anuncios y podrás crear tu tienda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.updatePremiumStatus(true);
              Get.snackbar(
                'Éxito',
                'Tu cuenta ha sido actualizada a Premium',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
