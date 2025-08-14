import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/store/store_controller.dart';
import '../../../data/models/store_item_model.dart';
import '../../../data/models/store_model.dart';

class StoreItemEditorPage extends StatefulWidget {
  const StoreItemEditorPage({super.key});

  @override
  State<StoreItemEditorPage> createState() => _StoreItemEditorPageState();
}

class _StoreItemEditorPageState extends State<StoreItemEditorPage> {
  final StoreController controller = Get.put(StoreController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String condition = 'Nuevo';
  String category = 'Otros';
  File? image;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1440,
    );
    if (file != null) setState(() => image = File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme color = theme.colorScheme;

    final Map args = Get.arguments as Map? ?? <String, dynamic>{};
    final StoreModel store =
        (args['store'] ?? Get.arguments)
            as StoreModel; // fallback si pasamos solo store
    final StoreItemModel? editing = args['item'] as StoreItemModel?;
    if (editing != null) {
      nameController.text = editing.name;
      descriptionController.text = editing.description;
      priceController.text = editing.price.toStringAsFixed(0);
      condition = editing.condition;
      category = editing.category;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(editing == null ? 'Nuevo artículo' : 'Editar artículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(image!, fit: BoxFit.cover),
                        )
                      : (editing?.imageUrl.isNotEmpty == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  editing!.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.image, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Selecciona una imagen',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              )),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio estimado'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: condition,
                    items: const [
                      DropdownMenuItem(value: 'Nuevo', child: Text('Nuevo')),
                      DropdownMenuItem(
                        value: 'Como nuevo',
                        child: Text('Como nuevo'),
                      ),
                      DropdownMenuItem(
                        value: 'Muy bueno',
                        child: Text('Muy bueno'),
                      ),
                      DropdownMenuItem(value: 'Bueno', child: Text('Bueno')),
                    ],
                    onChanged: (v) => setState(() => condition = v ?? 'Nuevo'),
                    decoration: const InputDecoration(labelText: 'Condición'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: category,
                    items: const [
                      DropdownMenuItem(
                        value: 'Camisetas',
                        child: Text('Camisetas'),
                      ),
                      DropdownMenuItem(
                        value: 'Pantalones',
                        child: Text('Pantalones'),
                      ),
                      DropdownMenuItem(
                        value: 'Chaquetas',
                        child: Text('Chaquetas'),
                      ),
                      DropdownMenuItem(
                        value: 'Calzado',
                        child: Text('Calzado'),
                      ),
                      DropdownMenuItem(
                        value: 'Accesorios',
                        child: Text('Accesorios'),
                      ),
                      DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                    ],
                    onChanged: (v) => setState(() => category = v ?? 'Otros'),
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              return FilledButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        final double price =
                            double.tryParse(priceController.text.trim()) ?? 0.0;
                        await controller.createOrUpdateStoreItem(
                          storeId: store.id,
                          editing: editing,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          price: price,
                          condition: condition,
                          category: category,
                          imageFile: image,
                        );
                        if (mounted) Get.back();
                      },
                child: Text(
                  editing == null ? 'Crear artículo' : 'Guardar cambios',
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
