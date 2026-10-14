# Flutter activa R8 (isMinifyEnabled = true) en el build release y agrega este
# archivo automaticamente si existe (FlutterPlugin.kt). Sin estas reglas R8
# renombra/elimina los metodos que Unity llama por reflexion (JNI), el boton de
# Unity lanza NoSuchMethodError, cae al respaldo Application.Quit() y la app se
# cierra en vez de volver a Flutter. En debug no hay R8, por eso ahi si funciona.

# Unity llama (desde C#) por nombre completo de clase:
#   new AndroidJavaClass("com.xraph.plugin.flutter_unity_widget.OverrideUnityActivity")
#       .CallStatic("volverAFlutter");
# Hay que conservar la clase y TODOS sus miembros (incluido volverAFlutter).
-keep class com.xraph.plugin.flutter_unity_widget.OverrideUnityActivity { *; }

# Puente del canal edura/unity_native (onClosed, constantes de extras). Lo usa
# OverrideUnityActivity; se conserva para no depender de que R8 lo alcance.
-keep class com.xraph.plugin.flutter_unity_widget.UnityNativeProcess { *; }
