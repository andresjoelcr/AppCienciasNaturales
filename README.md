# EduRA

Aplicacion educativa de Ciencias Naturales desarrollada con Flutter. Incluye autenticacion con Google, guia didactica, quizzes generados con IA, chat contextual, glosario, escaner de imagenes y experiencias con camara/marcadores.

## Plataforma preparada

Android es el destino completamente configurado en este repositorio. El proyecto incluye `android/app/google-services.json` y permisos de Internet, camara y microfono.

El proyecto Firebase asociado es `cienciasnaturales-f5577`. Las reglas versionadas en `firestore.rules` restringen perfiles, progreso, logros y chats al usuario autenticado propietario. La publicación de estas reglas se realiza por separado.

- Flutter 3.47.5 (version validada por la integración de Unity) y Dart 3.11 o posterior. `pubspec.lock` fija dependencias que requieren Dart 3.11; usa la misma versión de Flutter en ambos equipos antes de ejecutar `flutter pub get`.
- Gradle 8.14.3, AGP 8.11.1, Kotlin 2.2.20, Android SDK 36, JDK 17 y un dispositivo Android 29 o posterior. Consulta `README-unity.md` para el export de Unity 6000.3.7f1.
- Un proyecto Firebase con Google Sign-In y Firestore habilitados.
- Clave de Groq para las funciones de IA.

La versión pública de Android se controla en `pubspec.yaml` (`version: 1.0.0+1`); Gradle toma de Flutter `versionName` y `versionCode`. `unity.versionName` y `unity.versionCode` describen el módulo embebido y no sustituyen la versión de la app. Antes de publicar una nueva entrega, acuerden el siguiente número y cambien solo `pubspec.yaml`.

Web, Windows, iOS, macOS y Linux conservan los scaffolds de Flutter, pero no estan listos como destinos de produccion: faltan opciones Firebase por plataforma y el escaner usa APIs de archivo propias de movil.

## Configuracion local

1. Instala dependencias:

   ```powershell
   flutter pub get
   ```

   Si `flutter --version` aún muestra Flutter 3.29 / Dart 3.7, cambia primero al SDK 3.47.5. No regeneres `pubspec.lock` con un SDK anterior al validado.

2. Copia `.env.example` a `.env` y completa sus valores. `.env` es local y no debe versionarse.

   Modelos de Groq disponibles para una clave gratuita (verifica los tuyos en
   `GET https://api.groq.com/openai/v1/models`): `openai/gpt-oss-20b`,
   `openai/gpt-oss-120b`, `qwen/qwen3.8-27b`, `allam-2-7b`. Si Groq responde
   `404 model_not_found`, el modelo del `.env` fue retirado: actualiza `GROQ_MODEL`.

   `qwen/qwen3.8-27b` es el **unico** de los anteriores con vision; los `gpt-oss`
   y `allam-2` solo aceptan texto. Va en `GROQ_VISION_MODEL` y es lo que permite
   el escaner de imagenes. Ademas el nivel gratuito de vision esta limitado a
   unos 8000 tokens por minuto, asi que el escaner admite alrededor de 5 imagenes
   por minuto antes de empezar a devolver `429`.

3. Verifica el entorno:

   ```powershell
   flutter doctor -v
   flutter analyze
   flutter test
   ```

4. Inicia la aplicacion. **No necesitas pasar ningun flag**:

   ```powershell
   flutter run
   ```

   La clave se lee sola de `assets/groq.env`, que `tool/sync_env.ps1` genera a
   partir de `.env`. Si editas `.env` a mano, vuelve a ejecutar:

   ```powershell
   .\tool\sync_env.ps1
   ```

   Para devices Android concretos, o para generar un APK:

   ```powershell
   .\tool\run.ps1 -Device 23090RA98G
   .\tool\run.ps1 -BuildApk -Release
   ```

   En VS Code, F5 funciona directamente: las configuraciones `EduRA` de
   `.vscode/launch.json` ya pasan `--dart-define-from-file=.env` por si prefieres
   esa via.

   ### De donde sale la clave

   Hay dos caminos, y el asset es el que manda en la practica:

   | Origen | Cuando se usa |
   |---|---|
   | `assets/groq.env` | Siempre que el asset este generado. Es el camino normal. |
   | `--dart-define-from-file=.env` | Solo si pasas el flag; tiene prioridad. |

   Flutter resuelve `String.fromEnvironment` **al compilar**, no en runtime, por
   eso el flag por si solo no basta: si compilas sin el y sin asset, la clave
   llega vacia y el chat y el escaner responden que no estan configurados.

   El destino del asset **no empieza por punto** a proposito: Flutter descarta
   del paquete cualquier archivo cuyo nombre empieza por `.`, aunque lo declares
   en el `pubspec`.

   `assets/groq.env` esta en `.gitignore` porque contiene la clave.

   ### Seguridad de la clave

   La clave queda legible dentro del APK con cualquier extractor, tanto con el
   flag como con el asset: no es una diferencia real de seguridad. Para una app
   distribuida a una escuela conviene poner un backend que guarde la clave y
   reenvie las peticiones a Groq.

## Servicios externos

- Firebase Authentication: acceso con Google.
- Cloud Firestore: perfil, progreso, estadisticas e historial del chat.
- Groq: chat educativo, generacion de quizzes, fichas educativas e identificacion de imagenes.
- Unity (Vuforia) y marcadores propios: realidade aumentada.
- TensorFlow Lite: retired. El escaner ya no usa MobileNet.

Todo el servicio de IA pasa por Groq, con una sola clave. `GROQ_MODEL` es el
modelo de texto y `GROQ_VISION_MODEL` el unico con vision de la plataforma.
Verifica los modelos disponibles para tu clave en `GET https://api.groq.com/openai/v1/models`.

Si Google Sign-In falla en Android, registra en Firebase las huellas SHA-1/SHA-256 de la clave de firma usada y vuelve a descargar `google-services.json`. En esta máquina existe `android/app/edura-debug.keystore` (ignorado por Git) y el build debug la usa si está presente. En otra máquina se usa la firma debug normal; registra su SHA en Firebase o configura una clave local equivalente para que funcione el login. Las imágenes del login viven en `assets/login/`.
