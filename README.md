# SwapMe 👕♻️

**SwapMe** es una aplicación móvil innovadora desarrollada en Flutter que permite a los usuarios intercambiar y vender ropa de segunda mano de manera sostenible y económica. La app fomenta la moda circular y contribuye a la reducción del impacto ambiental de la industria textil.

## 🌟 Características Principales

### 🔄 Sistema de Intercambio
- **Intercambio directo**: Los usuarios pueden proponer intercambios de ropa con otros usuarios
- **Catálogo personalizado**: Crea un inventario de tu ropa disponible para intercambio
- **Filtros avanzados**: Busca por talla, categoría, condición y precio estimado
- **Gestión de propuestas**: Sistema completo para gestionar ofertas de intercambio

### 🛒 Marketplace Integrado
- **Tienda personal**: Cada usuario puede crear su propia tienda
- **Venta directa**: Opción de vender ropa además del intercambio
- **Gestión de inventario**: Administra fácilmente tus productos en venta
- **Categorización**: Organiza por tipo de prenda (camisetas, pantalones, chaquetas, etc.)

### 💬 Sistema de Chat
- **Mensajería en tiempo real**: Comunícate directamente con otros usuarios
- **Negociación**: Discute detalles de intercambios y ventas
- **Notificaciones push**: Mantente al día con nuevos mensajes

### 🔐 Autenticación Segura
- **Firebase Authentication**: Sistema de autenticación robusto y seguro
- **Login social**: Inicia sesión con Google o Apple ID
- **Gestión de perfiles**: Personaliza tu perfil y preferencias

### 🎨 Interfaz Moderna
- **Diseño glassmorphism**: UI moderna con efectos de cristal
- **Animaciones fluidas**: Transiciones suaves entre pantallas
- **Tema adaptativo**: Soporte para modo claro y oscuro
- **Responsive design**: Optimizado para diferentes tamaños de pantalla

## 🚀 Tecnologías Utilizadas

### Frontend
- **Flutter 3.8+**: Framework multiplataforma para desarrollo móvil
- **Dart**: Lenguaje de programación moderno y eficiente
- **GetX**: Gestión de estado, rutas y dependencias
- **Material Symbols**: Iconografía moderna y consistente

### Backend & Servicios
- **Firebase Core**: Plataforma de desarrollo completa
- **Firebase Auth**: Autenticación y gestión de usuarios
- **Cloud Firestore**: Base de datos NoSQL en tiempo real
- **Firebase Storage**: Almacenamiento de imágenes y archivos
- **Firebase Messaging**: Notificaciones push

### UI/UX
- **FlexColorScheme**: Sistema de colores avanzado
- **Glossy**: Efectos de glassmorphism
- **Video Player**: Reproducción de contenido multimedia
- **Animated Widgets**: Componentes animados personalizados

### Funcionalidades Adicionales
- **Image Picker**: Selección y captura de imágenes
- **Camera**: Integración con la cámara del dispositivo
- **Local Notifications**: Notificaciones locales
- **App Badge**: Indicadores de notificaciones

## 📱 Capturas de Pantalla

```
📸 [Próximamente: Screenshots de la aplicación]
```

## 🛠️ Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.8.1 o superior
- Dart SDK compatible
- Android Studio / VS Code
- Cuenta de Firebase
- Cuenta de desarrollador (Google/Apple para publicación)

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/swapme.git
cd swapme
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Configurar Firebase
Sigue las instrucciones detalladas en [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar proyecto
flutterfire configure
```

### 4. Configurar Iconos de la App
```bash
flutter pub run flutter_launcher_icons
```

### 5. Ejecutar la Aplicación
```bash
# Modo debug
flutter run

# Modo release
flutter run --release
```

## 📂 Estructura del Proyecto

```
lib/
├── config/              # Configuraciones de la app
│   ├── app_config.dart     # Configuración principal
│   └── theme/              # Temas y estilos
├── controllers/         # Lógica de negocio (GetX)
│   ├── auth/              # Controladores de autenticación
│   ├── chat/              # Controladores de chat
│   ├── home/              # Controladores de home
│   ├── store/             # Controladores de tienda
│   └── swap/              # Controladores de intercambio
├── data/               # Modelos y datos
│   └── models/            # Modelos de datos
├── presentation/       # Interfaz de usuario
│   ├── pages/             # Páginas de la aplicación
│   └── widgets/           # Componentes reutilizables
│       ├── atoms/         # Componentes básicos
│       ├── molecules/     # Componentes compuestos
│       └── organisms/     # Componentes complejos
├── routes/             # Configuración de rutas
├── services/           # Servicios y APIs
└── main.dart          # Punto de entrada
```

## 🧪 Testing

### Ejecutar Tests
```bash
# Tests unitarios
flutter test

# Tests de widgets
flutter test test/widget_test.dart

# Tests de integración
flutter drive --target=test_driver/app.dart
```

### Estructura de Tests
```
test/
├── unit/              # Tests unitarios
├── widget/            # Tests de widgets
└── integration/       # Tests de integración
```

## 🚀 Despliegue

### Android
1. Configurar keystore para signing
2. Actualizar `android/app/build.gradle`
3. Generar APK/AAB:
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
1. Configurar certificados en Xcode
2. Configurar provisioning profiles
3. Generar IPA:
```bash
flutter build ios --release
```

## 🔧 Comandos Útiles

```bash
# Limpiar proyecto
flutter clean && flutter pub get

# Analizar código
flutter analyze

# Formatear código
dart format .

# Actualizar dependencias
flutter pub upgrade

# Generar código (freezed, json_serializable)
flutter packages pub run build_runner build

# Ver dispositivos conectados
flutter devices

# Ver logs
flutter logs
```

## 📱 Plataformas Soportadas

- ✅ **Android** (API 21+)
- ✅ **iOS** (12.0+)
- 🚧 **Web** (WIP: Work in Progress)
- 🚧 **macOS** (planeado)
- 🚧 **Windows** (planeado)

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

### Estándares de Código
- Sigue las [guías de estilo de Dart](https://dart.dev/guides/language/effective-dart)
- Usa nombres descriptivos para variables y funciones
- Documenta funciones públicas
- Escribe tests para nuevas funcionalidades

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo

- **Desarrollador Principal**: [Tu Nombre]
- **UI/UX Designer**: [Nombre del Designer]
- **Backend Developer**: [Nombre del Backend Dev]

## 📞 Contacto

- **Email**: recaldecd@gmail.com

## 🙏 Agradecimientos

- **Flutter Team** por el increíble framework
- **Firebase** por los servicios backend
- **GetX Community** por la gestión de estado
- **Material Design** por las guías de diseño
- **Open Source Community** por las librerías utilizadas

## 📈 Roadmap

### Versión 1.1
- [ ] Sistema de valoraciones y reseñas
- [ ] Integración con mapas para intercambios locales
- [ ] Modo offline básico
- [ ] Mejoras en el chat (envío de imágenes)

### Versión 1.2
- [ ] Sistema de puntos y gamificación
- [ ] Integración con redes sociales
- [ ] Recomendaciones basadas en IA
- [x] Soporte multi-idioma completo

### Versión 2.0
- [ ] Versión web completa
- [ ] API pública para desarrolladores
- [ ] Sistema de afiliados
- [x] Marketplace B2B para tiendas

---

<div align="center">
  <strong>🌱 Hecho con ❤️ para un futuro más sostenible</strong>
  
  Si te gusta este proyecto, ¡dale una ⭐️!
</div>