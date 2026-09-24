# EduRA

Aplicacion educativa de Ciencias Naturales desarrollada con Flutter. Incluye autenticacion con Google, guia didactica, quizzes generados con IA, chat contextual, glosario, escaner de imagenes y experiencias con camara/marcadores.

## Plataforma preparada

Android es el destino completamente configurado en este repositorio. El proyecto incluye `android/app/google-services.json` y permisos de Internet, camara y microfono.

El proyecto Firebase asociado es `edura-ciencias-2026`. Las reglas versionadas en `firestore.rules` restringen perfiles, progreso, logros y chats al usuario autenticado propietario.

- Flutter 3.29.2 / Dart 3.7.2 (o una version compatible con Dart `^3.7.2`).
- Android SDK 35, JDK 17 y un dispositivo o emulador Android.
- Un proyecto Firebase con Google Sign-In y Firestore habilitados.
- Claves de Groq y Gemini para las funciones de IA.

Web, Windows, iOS, macOS y Linux conservan los scaffolds de Flutter, pero no estan listos como destinos de produccion: faltan opciones Firebase por plataforma y el escaner usa APIs de archivo propias de movil.

## Configuracion local

1. Instala dependencias:

   ```powershell
   flutter pub get
   ```

2. Copia `.env.example` a `.env` y completa sus valores. `.env` es local y no debe versionarse.

3. Verifica el entorno:

   ```powershell
   flutter doctor -v
   flutter analyze
   flutter test
   ```

4. Inicia un emulador y ejecuta la aplicacion cargando las variables de compilacion:

   ```powershell
   flutter emulators --launch Medium_Phone_API_35
   flutter run -d <id-del-dispositivo> --dart-define-from-file=.env
   ```

Las variables se incorporan al binario de Flutter mediante `--dart-define`. Para una aplicacion distribuida publicamente, las llamadas a Groq/Gemini deben pasar por un backend; una clave incluida en una app cliente puede extraerse del binario.

## Servicios externos

- Firebase Authentication: acceso con Google.
- Cloud Firestore: perfil, progreso, estadisticas e historial del chat.
- Groq: chat educativo y generacion de quizzes/descripciones.
- Gemini Vision: identificacion inicial de imagenes.
- TensorFlow Lite: clasificacion local de respaldo con MobileNet V2.

Si Google Sign-In falla en Android, registra en Firebase las huellas SHA-1/SHA-256 de la clave de firma usada y vuelve a descargar `google-services.json`.
