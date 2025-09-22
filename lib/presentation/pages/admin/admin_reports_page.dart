import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/theme_data.dart';
import '../../../data/models/admin_report_model.dart';
import '../../../services/content_moderation_service.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final ContentModerationService _moderationService =
      Get.find<ContentModerationService>();
  final RxString _selectedFilter = 'all'.obs;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Moderación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              _selectedFilter.value = value;
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'all',
                child: Text('Todos los reportes'),
              ),
              const PopupMenuItem<String>(
                value: 'pending',
                child: Text('Pendientes'),
              ),
              const PopupMenuItem<String>(
                value: 'high',
                child: Text('Alta prioridad'),
              ),
              const PopupMenuItem<String>(
                value: 'overdue',
                child: Text('Vencidos'),
              ),
            ],
          ),
        ],
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
        child: Column(
          children: [
            // Filtros
            Container(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _getFilterText(_selectedFilter.value),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.filter_list, color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),

            // Lista de reportes
            Expanded(
              child: StreamBuilder<List<AdminReportModel>>(
                stream: _getReportsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error cargando reportes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final List<AdminReportModel> reports = snapshot.data ?? [];

                  if (reports.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_turned_in,
                            size: 64,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay reportes pendientes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Todos los reportes han sido procesados',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final AdminReportModel report = reports[index];
                      return _buildReportCard(report, theme, colorScheme);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<AdminReportModel>> _getReportsStream() {
    return _moderationService.getContentReports().map((reports) {
      // Convertir ContentReportModel a AdminReportModel y filtrar
      final List<AdminReportModel> adminReports = reports.map((report) {
        return AdminReportModel(
          id: report.id,
          reportId: report.id,
          reporterId: report.reporterId,
          reportedUserId: report.reportedUserId,
          reportedContentId: report.reportedContentId,
          type: report.type.name,
          reason: report.reason,
          description: report.description,
          status: report.status.name,
          priority: _getPriorityFromType(report.type),
          requiresAction: report.status.name == 'pending',
          createdAt: report.createdAt,
          actionDeadline: report.createdAt.add(const Duration(hours: 24)),
          resolvedAt: report.resolvedAt,
          moderatorNotes: report.moderatorNotes,
          moderatorId: report.moderatorId,
        );
      }).toList();

      // Aplicar filtros
      return _applyFilters(adminReports);
    });
  }

  List<AdminReportModel> _applyFilters(List<AdminReportModel> reports) {
    switch (_selectedFilter.value) {
      case 'pending':
        return reports.where((r) => r.status == 'pending').toList();
      case 'high':
        return reports.where((r) => r.priority == 'high').toList();
      case 'overdue':
        return reports.where((r) => r.isOverdue).toList();
      default:
        return reports;
    }
  }

  String _getFilterText(String filter) {
    switch (filter) {
      case 'pending':
        return 'Pendientes';
      case 'high':
        return 'Alta prioridad';
      case 'overdue':
        return 'Vencidos';
      default:
        return 'Todos los reportes';
    }
  }

  String _getPriorityFromType(dynamic type) {
    // Esta función debería mapear el tipo a prioridad
    // Por simplicidad, usamos valores por defecto
    return 'medium';
  }

  Widget _buildReportCard(
    AdminReportModel report,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: report.isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : report.isUrgent
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con prioridad y estado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      report.priority,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(report.priority),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(report.priority),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      report.status,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(report.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(report.status),
                    ),
                  ),
                ),
                const Spacer(),
                if (report.isOverdue)
                  Icon(Icons.warning, color: Colors.red, size: 20),
                if (report.isUrgent && !report.isOverdue)
                  Icon(Icons.access_time, color: Colors.orange, size: 20),
              ],
            ),

            const SizedBox(height: 12),

            // Tipo de reporte
            Text(
              report.reason,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Descripción
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Información adicional
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${_formatDate(report.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (report.requiresAction)
                  Text(
                    'Vence: ${report.timeRemaining}',
                    style: TextStyle(
                      fontSize: 12,
                      color: report.isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight: report.isOverdue
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showReportDetails(report),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Ver detalles'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _resolveReport(report),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Resolver'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return 'ALTA';
      case 'medium':
        return 'MEDIA';
      case 'low':
        return 'BAJA';
      default:
        return 'MEDIA';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'resolved':
        return 'RESUELTO';
      case 'dismissed':
        return 'DESCARTADO';
      default:
        return 'PENDIENTE';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  void _showReportDetails(AdminReportModel report) {
    Get.dialog(
      AlertDialog(
        title: Text('Detalles del Reporte'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Tipo:', report.reason),
              _buildDetailRow('Descripción:', report.description),
              _buildDetailRow('Prioridad:', _getPriorityText(report.priority)),
              _buildDetailRow('Estado:', _getStatusText(report.status)),
              _buildDetailRow('Creado:', _formatDate(report.createdAt)),
              if (report.requiresAction)
                _buildDetailRow('Vence en:', report.timeRemaining),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cerrar')),
          FilledButton(
            onPressed: () {
              Get.back();
              _resolveReport(report);
            },
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _resolveReport(AdminReportModel report) {
    final TextEditingController notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Resolver Reporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Cómo quieres resolver este reporte?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Notas del moderador...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Get.back();

              // Mostrar indicador de carga
              Get.dialog(
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Resolviendo reporte...'),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                final bool success = await _moderationService.resolveReport(
                  report.reportId,
                  moderatorNotes: notesController.text.trim(),
                  removeContent: false,
                  banUser: false,
                );

                Get.back(); // Cerrar indicador de carga

                if (success) {
                  Get.snackbar(
                    'Reporte resuelto',
                    'El reporte ha sido marcado como resuelto',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withValues(alpha: 0.8),
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'No se pudo resolver el reporte',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withValues(alpha: 0.8),
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.back(); // Cerrar indicador de carga
                Get.snackbar(
                  'Error',
                  'Ocurrió un error inesperado',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withValues(alpha: 0.8),
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
  }
}
