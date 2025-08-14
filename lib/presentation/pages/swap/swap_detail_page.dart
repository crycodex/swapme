import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/swap_item_model.dart';
import '../../../controllers/swap/swap_controller.dart';

class _SellerArguments {
  final String userId;
  final String userName;
  final String? photoUrl;
  const _SellerArguments({
    required this.userId,
    required this.userName,
    this.photoUrl,
  });
}

class SwapDetailPage extends StatelessWidget {
  const SwapDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SwapItemModel item = Get.arguments as SwapItemModel;
    final SwapController swapController = Get.put(SwapController());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            title: Text('Detalles', style: theme.textTheme.titleMedium),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen del artículo
                  Hero(
                    tag: 'swap-${item.id}',
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  // Gradiente superior/inferior para legibilidad
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    item.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chips de categoría, talla y estado
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        context,
                        label: item.category,
                        icon: Icons.category_rounded,
                      ),
                      _buildChip(
                        context,
                        label: item.size,
                        icon: Icons.straighten_rounded,
                      ),
                      _buildChip(
                        context,
                        label: item.condition,
                        icon: Icons.check_circle_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                      Text(
                        item.estimatedPrice.toStringAsFixed(0),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vendedor
                  const SizedBox(height: 8),
                  _SellerCard(
                    userId: item.userId,
                    swapController: swapController,
                    onOpenSeller:
                        (String userId, String userName, String? photo) {
                          Get.to(
                            () => _SellerSwapsPage(
                              args: _SellerArguments(
                                userId: userId,
                                userName: userName,
                                photoUrl: photo,
                              ),
                            ),
                            transition: Transition.cupertino,
                          );
                        },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.description, style: theme.textTheme.bodyMedium),

                  const SizedBox(height: 20),
                  // Meta información
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(item.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.sync_alt_rounded,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ID: ${item.id.substring(0, item.id.length > 6 ? 6 : item.id.length)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {},
              child: const Text('Intercambiar'),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    DateTime d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  final String userId;
  final SwapController swapController;
  final void Function(String userId, String userName, String? photoUrl)
  onOpenSeller;
  const _SellerCard({
    required this.userId,
    required this.swapController,
    required this.onOpenSeller,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    return FutureBuilder<Map<String, dynamic>?>(
      future: swapController.fetchUserProfile(userId),
      builder: (context, snapshot) {
        final Map<String, dynamic>? data = snapshot.data;
        final String userName = (data?['name'] ?? 'usuario') as String;
        final String? photoUrl = data?['photoUrl'] as String?;
        return InkWell(
          onTap: () => onOpenSeller(userId, userName, photoUrl),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.secondary.withValues(alpha: 0.15),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Icon(Icons.person, color: color.secondary)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Ver perfil y artículos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: theme.hintColor),
            ],
          ),
        );
      },
    );
  }
}

class _SellerSwapsPage extends StatelessWidget {
  final _SellerArguments args;
  const _SellerSwapsPage({required this.args});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;
    final SwapController controller = Get.find<SwapController>();
    return Scaffold(
      appBar: AppBar(title: Text(args.userName)),
      body: StreamBuilder<List<SwapItemModel>>(
        stream: controller.getSwapsByUser(args.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<SwapItemModel> items = snapshot.data ?? <SwapItemModel>[];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Este usuario aún no tiene swaps',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.76,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final SwapItemModel item = items[index];
              return GestureDetector(
                onTap: () => Get.to(() => SwapDetailPage(), arguments: item),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(item.imageUrl, fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.surface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 14,
                                    color: color.primary,
                                  ),
                                  Text(
                                    item.estimatedPrice.toStringAsFixed(0),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: color.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
