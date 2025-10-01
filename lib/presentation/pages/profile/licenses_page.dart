import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Licencias',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SwapApp',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Versión 1.0.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '© 2025 SwapApp. Todos los derechos reservados.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Licencias de Terceros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLicenseCard(
              'Flutter',
              'BSD 3-Clause License',
              'Framework de desarrollo multiplataforma de Google',
            ),
            _buildLicenseCard(
              'GetX',
              'MIT License',
              'Framework de gestión de estado y navegación',
            ),
            _buildLicenseCard(
              'Firebase',
              'Apache 2.0 License',
              'Plataforma de desarrollo móvil de Google',
            ),
            _buildLicenseCard(
              'Google Sign-In',
              'Apache 2.0 License',
              'Autenticación con Google',
            ),
            _buildLicenseCard(
              'Image Picker',
              'MIT License',
              'Selección de imágenes y videos',
            ),
            _buildLicenseCard(
              'Video Player',
              'Apache 2.0 License',
              'Reproductor de video',
            ),
            _buildLicenseCard(
              'Camera',
              'Apache 2.0 License',
              'Acceso a la cámara del dispositivo',
            ),
            _buildLicenseCard(
              'Local Notifications',
              'Apache 2.0 License',
              'Notificaciones locales',
            ),
            _buildLicenseCard(
              'WebView',
              'BSD 3-Clause License',
              'Vista web integrada',
            ),
            _buildLicenseCard(
              'Google Mobile Ads',
              'Apache 2.0 License',
              'Anuncios móviles de Google',
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLicenseCard(String name, String license, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              license,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
