import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/theme_data.dart';
import '../../../services/content_moderation_service.dart';
import '../../../data/models/content_report_model.dart';

class ReportContentPage extends StatefulWidget {
  final String reportedUserId;
  final String? contentId;
  final String? contentType;

  const ReportContentPage({
    super.key,
    required this.reportedUserId,
    this.contentId,
    this.contentType,
  });

  @override
  State<ReportContentPage> createState() => _ReportContentPageState();
}

class _ReportContentPageState extends State<ReportContentPage> {
  final ContentModerationService _moderationService =
      Get.put<ContentModerationService>(ContentModerationService());
  final TextEditingController _descriptionController = TextEditingController();

  ReportType _selectedType = ReportType.inappropriateContent;
  final RxBool _isSubmitting = false.obs;

  final Map<ReportType, String> _reportTypes = {
    ReportType.inappropriateContent: 'Contenido inapropiado',
    ReportType.spam: 'Spam',
    ReportType.harassment: 'Acoso',
    ReportType.fakeProduct: 'Producto falso',
    ReportType.inappropriateImage: 'Imagen inapropiada',
    ReportType.other: 'Otro',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor describe el motivo del reporte',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    _isSubmitting.value = true;

    try {
      final bool success = await _moderationService.reportContent(
        reportedUserId: widget.reportedUserId,
        type: _selectedType,
        reason: _reportTypes[_selectedType]!,
        description: _descriptionController.text.trim(),
        contentId: widget.contentId,
      );

      if (success) {
        Get.snackbar(
          'Reporte enviado',
          'Hemos recibido tu reporte y lo revisaremos dentro de 24 horas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo enviar el reporte. Inténtalo de nuevo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado. Inténtalo de nuevo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Contenido'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ayúdanos a mantener SwapMe seguro reportando contenido inapropiado',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Tipo de Reporte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              ..._reportTypes.entries.map((entry) {
                return RadioListTile<ReportType>(
                  title: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 14),
                  ),
                  value: entry.key,
                  groupValue: _selectedType,
                  onChanged: (ReportType? value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                );
              }).toList(),

              const SizedBox(height: 24),

              const Text(
                'Descripción del Reporte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Describe por qué estás reportando este contenido...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Información Importante',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Los reportes son revisados por nuestro equipo de moderación\n'
                      '• Actuaremos sobre contenido inapropiado dentro de 24 horas\n'
                      '• Los usuarios que violen nuestras políticas pueden ser suspendidos\n'
                      '• Tu identidad se mantiene confidencial en el proceso de reporte',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting.value ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Enviar Reporte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
