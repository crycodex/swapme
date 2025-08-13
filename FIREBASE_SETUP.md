# Configuración de Firebase

## Importante ⚠️

El archivo `lib/firebase_options.dart` **NO** se sincroniza con el repositorio remoto por seguridad. Este archivo contiene claves de API y configuraciones sensibles.

## Configuración Inicial

### 1. Configuración de la aplicación
La aplicación ahora usa un sistema de configuración centralizado en `lib/config/app_config.dart` que no requiere archivos `.env`.

### 2. Generar el archivo de configuración de Firebase

Ejecuta el siguiente comando para generar tu archivo `firebase_options.dart`:

```bash
flutterfire configure
```

Este comando:
- Te pedirá que selecciones tu proyecto de Firebase
- Generará automáticamente el archivo `lib/firebase_options.dart`
- Configurará las plataformas que necesites (Android, iOS, Web)

### 2. Verificar la configuración

Asegúrate de que el archivo generado tenga la estructura correcta como se muestra en `lib/firebase_options.example.dart`.

### 3. Configuración de la aplicación
- La configuración principal está en `lib/config/app_config.dart`
- No se requieren archivos `.env` externos
- Todas las configuraciones están centralizadas y versionadas

### 4. Configurar plataformas específicas

#### Android
- Coloca `google-services.json` en `android/app/`
- Este archivo también está en `.gitignore` por seguridad

#### iOS
- Coloca `GoogleService-Info.plist` en `ios/Runner/`
- Este archivo también está en `.gitignore` por seguridad

## Cambio de Ramas

Cuando cambies de rama:
1. El archivo `firebase_options.dart` se mantendrá en tu repositorio local
2. No se sobrescribirá al hacer pull o checkout
3. Mantendrás tu configuración de Firebase en todas las ramas

## Solución de Problemas

### Si el archivo se perdió accidentalmente:
1. Ejecuta `flutterfire configure` nuevamente
2. Selecciona tu proyecto de Firebase
3. El archivo se regenerará con tu configuración

### Si hay conflictos de merge:
1. El archivo está en `.gitignore`, por lo que no debería generar conflictos
2. Si hay problemas, regenera el archivo con `flutterfire configure`

## Notas de Seguridad

- **NUNCA** commits el archivo `firebase_options.dart` real
- **NUNCA** commits `google-services.json` o `GoogleService-Info.plist`
- Solo el archivo de ejemplo (`firebase_options.example.dart`) debe estar en el repositorio
- Cada desarrollador debe generar su propia configuración local

## Comandos Útiles

```bash
# Configurar Firebase
flutterfire configure

# Verificar configuración
flutterfire projects:list

# Limpiar configuración
flutterfire logout
flutterfire login

# Actualizar dependencias (después de cambios en pubspec.yaml)
flutter pub get
```
