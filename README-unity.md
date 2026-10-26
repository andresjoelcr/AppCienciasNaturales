# Integración Unity + Flutter (EduRA)

**Estado: el APK compiló con Unity embebido en la máquina de exportación.** `build\app\outputs\flutter-apk\app-debug.apk` (440 MB debug). Las bibliotecas nativas y el resultado de IL2CPP están ignorados por Git: cada equipo que compile Unity debe restaurar el export conforme a esta guía.

Verificado dentro del APK:
`libil2cpp.so` (78 MB), `libunity.so` (20 MB), `lib_burst_generated.so`,
`libUnityDriver.so`, `libVuforiaEngine.so`, `global-metadata.dat`

---

## ⚠️ Al re-exportar desde Unity hay que repetir esto

El export **pisa** `android/unityLibrary/build.gradle`. El export ya deja
`implementation fileTree(dir: 'libs', include: ['*.jar'])`, que es lo correcto
(sección 3.1) — no lo cambies a `compileOnly`, o la app caerá al abrir Unity con
`NoClassDefFoundError: com.unity3d.player.UnityPlayerGameActivity`.

El export compila **todo** `Assets/Scripts/*.cs` a `libil2cpp.so`. Si cambias un
script y **no** vuelves a exportar, el APK sigue con el código viejo dentro de
`libil2cpp.so` (aunque el `.cs` ya esté corregido). Comprobación rápida: el `.so`
debe ser más nuevo que el script.

```powershell
Get-Item android\unityLibrary\src\main\jniLibs\arm64-v8a\libil2cpp.so | % LastWriteTime
Get-Item D:\Unity\CienciasNaturales\Assets\Scripts\*.cs | Sort LastWriteTime -Desc | Select -First 1
```

> Caso real: `SalirApp.cs`/`VolverAFlutter.cs` se corrigieron para llamar al
> puente nativo `OverrideUnityActivity.volverAFlutter()` en vez de
> `Application.Quit()`, pero el `libil2cpp.so` del APK todavía tenía la versión
> vieja que hacía `Application.Quit()`: al salir de Unity se moría **todo** el
> proceso (se cerraba también Flutter). Re-exportar Unity lo arregla.

---

## 1. Exportar desde Unity

Proyecto Unity: `D:\Unity\CienciasNaturales`

**No exportes directo a `android\`.** Unity revisa los Gradle que ya están ahí, no
encuentra su marca de versión de plantilla y aborta con:

```
Gradle project template version mismatch, expected 21 was 0
Failed to parse gradle project template version from '.../android\gradle.properties'
```

En su lugar, exportar a una **carpeta vacía** (por ejemplo `D:\UnityExport`). Unity
crea ahí el proyecto Gradle con esta forma:

```
D:\UnityExport\
├── build.gradle
├── gradle.properties
├── local.properties
├── settings.gradle
├── gradle\        <- no se usa
├── launcher\      <- NO se usa
├── shared\        <- SÍ se usa
└── unityLibrary\  <- SÍ se usa
```

Build Settings: Android, escenas en orden `EscanearTarjetas` (0),
`CelulaVegetalRA` (1), `EscanerTarjetasV2` (2), `CelulaAnimalRA` (3),
`CelulaAnimal` (4), `CelulaVegetal` (5), `EscenaCarga` (6),
`CelulaAnimalOrganelos` (7) y `CelulaVegetalOrganelos` (8), IL2CPP, ARM64,
OpenGLES3.

---

## 2. Copiar al proyecto Flutter

Solo **dos** carpetas, no todo:

| Origen | Destino | Por qué |
|---|---|---|
| `D:\UnityExport\unityLibrary` | `android\unityLibrary` | el módulo de Unity |
| `D:\UnityExport\shared` | `android\shared` | `build.gradle` hace `apply from: '../shared/common.gradle'` |

`launcher\`, `build.gradle`, `settings.gradle` y `gradle\` del export **no se copian**:
Flutter ya tiene su propio módulo `app` que reemplaza al `launcher`.

Última copia: `D:\UnityExport` → `android\` (2654 archivos / ≈1017 MB en
`unityLibrary`, 2 archivos en `shared`), con el parche 3.1 reaplicado, el
manifest de 3.5 sin el `intent-filter` MAIN/LAUNCHER y con
`unityStreamingAssets=.mp4` + `unityTemplateVersion=21` en
`android/gradle.properties` (las propiedades `unity.*` del export).

---

## 3. Parches aplicados

### 3.1 `android/unityLibrary/build.gradle` — se pierde al re-exportar

```groovy
implementation fileTree(dir: 'libs', include: ['*.jar'])   // NO volver a compileOnly
```

`unity-classes.jar` (Unity 6000.3) trae las clases del player
(`UnityPlayer`, `UnityPlayerForGameActivity`, `IUnityPlayerLifecycleEvents`,
`IUnityPlayerSupport`, `IUnityPermissionRequestSupport`...). **Tiene que ir
empaquetado en el APK.** Si se pone `compileOnly`, el módulo compila pero las
clases no llegan a ningún `classes.dex` y la app cae al abrir Unity con:

```
java.lang.NoClassDefFoundError: Failed resolution of: Lcom/unity3d/player/UnityPlayerGameActivity;
Caused by: java.lang.ClassNotFoundException: com.unity3d.player.IUnityPlayerLifecycleEvents
```

El duplicado que se temía venir de `flutter_unity_widget_2` vía `flatDir` no
ocurre: ese plugin declara `compileOnly(name: 'unity-classes', ext:'jar')`
(sección 3.2), así que solo compila contra el jar y no lo empaqueta. El único
empaquetado válido es este `implementation`.

> El `libs/unity-classes.jar` del plugin
> (`third_party/flutter_unity_widget_2/android/libs`) es viejo y NO trae
> `UnityPlayerForGameActivity` ni los `IUnityPlayerSupport`; se usa solo para
> compilar el propio plugin. Al empaquetar se usa siempre el de `unityLibrary`.

### 3.2 `third_party/flutter_unity_widget_2/` — parche del plugin

`flutter_unity_widget_2` 6000.1.0+1 **no compila contra Unity 6000.3**: su
`OverrideUnityActivity.kt` extiende `com.unity3d.player.UnityPlayerActivity`, clase
que Unity 6.3 eliminó al quitar el entry point clásico "Activity" (ya no existe esa
opción en Player Settings; GameActivity es la única opción).

Se vendoriza el paquete y se parchea:

| Archivo | Cambio |
|---|---|
| `OverrideUnityActivity.kt` | `UnityPlayerActivity` → `UnityPlayerGameActivity` |
| `OverrideUnityActivity.kt` | quitar `mUnityPlayer.onTrimMemory(...)` (no existe en `UnityPlayerForGameActivity`) |
| `android/build.gradle` | `compileOnly` de `games-activity`, `appcompat`, `core`, `constraintlayout` |
| `FlutterUnityWidgetBuilder.kt` | propagar al controlador `fullscreen`, `hideStatusBar`, `runImmediately` y `unloadOnDispose` (se perdían al crear su propia copia de las opciones) |
| `UnityPlayerUtils.kt` | descarga en dos fases: `unloadPending` + `onUnloaded()` (borra vista/reproductor y vacía las creaciones encoladas), cola en `createUnityPlayer()` y timer de red de seguridad de 20 s |
| `FlutterUnityWidgetController.kt` | `onUnityPlayerUnloaded()` ejecuta `UnityPlayerUtils.onUnloaded()` en el hilo principal; `attachToView()`/`reattachToView()` ignorados mientras hay descargue; `onReady()` respeta `disposed` |

En `pubspec.yaml`:

```yaml
dependency_overrides:
  flutter_unity_widget_2:
    path: third_party/flutter_unity_widget_2
```

El modo **widget** (`UnityWidget`) sigue disponible y no lo tocan estos parches:
`CustomUnityPlayer` extiende `UnityPlayerForActivityOrService`, y esa clase sí
existe en Unity 6.3. La app ya **no** lo usa; ahora abre Unity en su propia
actividad nativa (sección 3.3).

### 3.3 Modo actividad nativa (EduRA) — se pierde al re-exportar el plugin

Unity ya no se incrusta en el árbol de Flutter. Se abre
`OverrideUnityActivity` a pantalla completa, fuera de Flutter, y el reproductor
**no se cierra** al volver (Unity 6 no soporta destruir y recrear el runtime en
el mismo proceso; ver 6.1). Archivos añadidos o reescritos en el paquete
vendorizado:

| Archivo | Cambio |
|---|---|
| `UnityNativeProcess.kt` (nuevo) | constantes del canal `edura/unity_native`, extras `scene`/`fullscreen`/`flutterActivity` y el hook `onClosed` (Unity → Flutter) |
| `OverrideUnityActivity.kt` (reescrito) | lee el extra `scene` y lo reenvía con `UnityPlayer.UnitySendMessage("CargarEscenas", "cargarEscena", …)` con reintentos 2 s/5 s/9 s; `onNewIntent` recarga la escena al reabrir; `onBackPressed`/`onUnityPlayerQuitted`/`onUnityPlayerUnloaded` llaman a `returnToFlutter()` → `onClosed` + trae `MainActivity` al frente (sin `finish`). Expone el método estático `volverAFlutter()` para que el botón **de Unity** vuelva sin cerrar el reproductor |
| `FlutterUnityWidgetPlugin.kt` | registra el canal `edura/unity_native` (`openInNativeProcess`) en `onAttachedToEngine` y conecta/limpia `UnityNativeProcess.onClosed` en las callbacks de actividad. No usa `startActivityForResult`: el retorno se avisa por canal |
| `lib/src/io/unity_native_process.dart` (nuevo) | API Dart `UnityNativeProcess.open({String? scene})` + `Stream<void> onClosed`; stub web en `lib/src/web/unity_native_process.dart` |
| `lib/flutter_unity_widget_2.dart` | exporta la API anterior (condicional a `dart.library.js_interop`) |

En `android/app/src/main/AndroidManifest.xml` se declara:

```xml
<activity
    android:name="com.xraph.plugin.flutter_unity_widget.OverrideUnityActivity"
    android:exported="false"
    android:launchMode="singleTask"
    android:screenOrientation="portrait"
    android:hardwareAccelerated="true"
    android:theme="@style/BaseUnityGameActivityTheme">
    <meta-data android:name="unityplayer.UnityActivity" android:value="true" />
    <meta-data android:name="android.app.lib_name" android:value="game" />
</activity>
```

`android:launchMode="singleTask"` permite que `FLAG_ACTIVITY_REORDER_TO_FRONT` y
`onNewIntent` reutilicen la misma instancia viva. El retorno (botón de Unity,
botón atrás del sistema o descarga del reproductor) se intercepta y se avisa a
Dart por el canal, sin cerrar la actividad.

> ⚠️ **El botón "salir" de Unity NO debe llamar a `Application.Quit()`.** En
> Android eso mata el proceso completo (se cierra también Flutter, se destruye
> el reproductor y reabrir Unity revienta). Los scripts de Unity
> (`SalirApp.cs`, `VolverAFlutter.cs`) llaman al método estático nativo:
>
> ```csharp
> new AndroidJavaClass("com.xraph.plugin.flutter_unity_widget.OverrideUnityActivity")
>     .CallStatic("volverAFlutter");
> ```
>
> Ese método solo trae Flutter al frente y avisa por canal, dejando vivo el
> reproductor. `Application.Quit()` queda únicamente como respaldo cuando el
> puente nativo no está disponible (build de Unity sin Flutter).

### 3.4 `android/app/proguard-rules.pro` — obligatorio en release

Flutter activa **R8** (`isMinifyEnabled = true`) en el build `release` y añade
este archivo solo si existe (`FlutterPlugin.kt`). `volverAFlutter()` se llama
desde Unity **por reflexión/JNI** con el nombre en texto, así que R8 no ve
ninguna referencia desde Kotlin y lo renombra/elimina. Resultado en release:
`AndroidJavaClass(...).CallStatic("volverAFlutter")` lanza `NoSuchMethodError`,
los scripts caen al respaldo `Application.Quit()` y **la app se cierra** en vez
de volver a Flutter. En debug no hay R8, por eso ahí funcionaba.

```proguard
-keep class com.xraph.plugin.flutter_unity_widget.OverrideUnityActivity { *; }
-keep class com.xraph.plugin.flutter_unity_widget.UnityNativeProcess { *; }
```

No borrar: sin estas reglas el retorno a Flutter se rompe **solo en release**.

### 3.5 `android/unityLibrary/src/main/AndroidManifest.xml` — doble ícono

El manifest que exporta Unity trae un `<intent-filter>` `MAIN`/`LAUNCHER` en
`com.unity3d.player.UnityPlayerGameActivity`. Como `unityLibrary` se fusiona en
el APK, Android crea **dos iconos** (Flutter y Unity). La app abre Unity solo con
un Intent explícito a `OverrideUnityActivity`, así que ese filtro se elimina y la
actividad queda `android:exported="false"`.

**Se pierde al re-exportar:** el export reescribe el manifest y vuelve a poner el
`intent-filter`. Después de cada export hay que quitarlo otra vez (el propio
archivo lo recuerda en un comentario).

---

## 4. Configuración automática (ya hecha, no tocar)

Los archivos de Gradle detectan si `android/unityLibrary` existe y se enganchan solos:

| Archivo | Qué hace |
|---|---|
| `android/settings.gradle.kts` | `include(":unityLibrary")` |
| `android/build.gradle.kts` | `flatDir` a `unityLibrary/libs` |
| `android/app/build.gradle.kts` | `:flutter_unity_widget_2` y `:unityLibrary` |
| `android/gradle.properties` | propiedades `unity.*` que leen `common.gradle` y `build.gradle` |

---

## 5. Versiones (validadas)

| Componente | Valor | Razón |
|---|---|---|
| Flutter | 3.47.5 | instalado |
| Gradle | **8.14.3** | mínimo Flutter 8.14.0; sigue en 8.x para Unity |
| AGP | **8.11.1** | mínimo Flutter 8.11.1; sigue en 8.x para Unity |
| Kotlin | **2.2.20** | mínimo Flutter 2.2.20 |
| NDK | **27.2.12479018** (r27c) | el mismo que usa Unity 6000.3.7f1 |
| Java | **17** | ver sección 5.1 |
| minSdk | **29** | `unityLibrary` exige 29 |
| compileSdk | **36** | `unityLibrary` exige 36 |

### 5.1 Java 24 rompe Gradle

En esta máquina el `java` del PATH es **24.0.1** (`C:\Program Files\Java\jdk-24`) y
`JAVA_HOME` está vacío. Gradle no soporta Java 24 hasta la versión 9, así que falla con:

```
Could not use Gradle version 8.4 and Java version 24.0.1 to configure the build
```

Se resuelve en dos niveles, sin tocar variables de sistema:

| Dónde | Qué hace |
|---|---|
| `JAVA_HOME` o `flutter config --jdk-dir=...` | selecciona un JDK 17 instalado en cada equipo |

En la máquina de exportación se usó el JDK de Unity 6000.3.7f1. La ruta de ese equipo ya no se fija en `android/gradle.properties`; comprueba con `flutter doctor -v` que Flutter encuentre Java 17.

> Las rutas `unity.*Path` en `android/gradle.properties` provienen del export original y deben apuntar al SDK, NDK y proyecto Unity instalados en el equipo que vuelva a compilar el módulo. Son rutas de esa máquina, no versiones de la app.

Estaba en Gradle 9.1.0 + AGP 9.0.1: AGP 9 rompe el plugin de Unity.
Verificar: `flutter build apk --debug`.

El primer build tarda **~10 minutos** porque compila IL2CPP
(`il2cpp build success (591 seconds)`). Los siguientes son de ~3 minutos.

---

## 6. Pendientes

### 6.1 Navegación RV/RA (Dart)

Hecho en `home_screen.dart`: la tarjeta y el selector pasaron a
**Realidad virtual y aumentada** y ofrecen dos opciones:

| Opción | Disparador | Escena de Unity |
|---|---|---|
| Marcadores de color | `home_screen.dart` (`_abrirEscaneoUnity`) | `EscanearTarjetas` (escena 0) |
| Imagen de célula → Célula Animal | `home_screen.dart` (`_abrirCelula`) | `CelulaAnimal` |
| Imagen de célula → Célula Vegetal | `home_screen.dart` (`_abrirCelula`) | `CelulaVegetal` |
| Guía → Organelos → AR → Célula Animal | `subtema_screen.dart` (`_mostrarSelectorAR`) | `CelulaAnimalOrganelos` |
| Guía → Organelos → AR → Célula Vegetal | `subtema_screen.dart` (`_mostrarSelectorAR`) | `CelulaVegetalOrganelos` |

En la guía didáctica, el subtema `1.4` (Organelos y sus funciones) muestra un
botón **AR** a un costado. Abre un diálogo con las dos opciones y llama a
`UnityNativeProcess.open(scene: …)` con la escena de organelos elegida.

`ar_image_target_screen.dart` quedó fuera del flujo (el archivo sigue en el
repo, sin import en `home_screen.dart`).

No hay pantalla intermedia: el botón llama directo a
`UnityNativeProcess.open(scene: …)` (que lanza `OverrideUnityActivity` a
pantalla completa, sección 3.3) y el usuario pasa directo a la escena, sin capa
de carga. Al volver, la actividad nativa trae `MainActivity` al frente y Flutter
queda en la pantalla donde estaba; no se hace `Navigator.pop` porque no se
apiló ninguna ruta.

La escena se envía a Unity por `UnityPlayer.UnitySendMessage` al GameObject
`CargarEscenas` (componente `FlutterLoadScene`, que expone
`cargarEscena(string)`), con reintentos 2 s / 5 s / 9 s para cubrir el arranque
en frío y la carga de Vuforia. El GameObject se mantiene persistente entre
escenas gracias a:

| Archivo | Cambio |
|---|---|
| Unity `Assets/Scripts/ReceptorEscenasPersistente.cs` | `[RuntimeInitializeOnLoadMethod]` que busca el GameObject `CargarEscenas` apenas arranca el player y lo marca `DontDestroyOnLoad` (lo crea con `FlutterLoadScene` si no existiera). El pedido de escena llega desde cualquier escena y no hace falta arrancar Unity de cero. Hay que reexportar el proyecto de Unity para que entre en el APK (IL2CPP compila los scripts a `libil2cpp.so`). |

Los parches del plugin de la sección 3.2 (`unloadPending`, cola de creaciones,
`onUnloaded()`, propagación de opciones) se mantienen aunque el modo widget ya
no se use: quedan por si algún día se vuelve a necesitar descargar el
reproductor.

**Pendiente en Unity:** `onUnitySceneLoaded`/`onUnityMessage` dependen del
`fuw-6000.unitypackage` (sección 6.2), así que los reintentos del lado nativo
(`OverrideUnityActivity.programarEscena`) siguen siendo el único mecanismo para
asegurar que la escena pedida se cargue.

`third_party/**` está excluido de `analysis_options.yaml`: su `example/` es una app de
demo que no se compila aquí y falla por `pointer_interceptor`, que no es dependencia
de este proyecto.

### 6.2 Plugin de Unity no importado

Falta importar `fuw-6000.unitypackage` y correr
`Herramientas > Configurar retorno a Flutter (las 2 escenas)`.

Mientras no se importe:

- no llegan a Flutter `onUnitySceneLoaded` ni `onUnityMessage`;
- `VolverAFlutter.EnviarMensajeAFlutter()` no encuentra `UnityMessageManager`,
  así que el retorno cae al puente nativo: los scripts de Unity llaman a
  `OverrideUnityActivity.volverAFlutter()` por `AndroidJavaClass` (sección 3.3),
  que trae Flutter al frente sin cerrar Unity. `Application.Quit()` queda solo
  como último respaldo, y **no debe usarse en el botón de Unity** porque en
  Android mata el proceso completo (cierra también Flutter).
  Al importar `fuw-6000.unitypackage` habrá que revisar que el camino de
  `UnityMessageManager` siga convergiendo en `returnToFlutter()`.

### 6.3 Conflicto de cámara

`pubspec.yaml` tiene `camera: ^0.11.0`, y existen `lib/screens/ar_image_target_screen.dart`
y `lib/services/simple_marker_detector.dart`.

En Android **solo un cliente puede tomar la cámara**. Si Flutter la tiene abierta y
Unity enciende la de Vuforia, se pelean y la AR no arranca. Decidir:

1. Vuforia como dueño único — quitar `camera` y los screens de AR de Flutter
2. Mantener ambos — abrir la cámara solo mientras se usa el scanner
3. Migrar el escaneo a Flutter — Vuforia solo para AR

### 6.4 `applicationId`

Sigue en `com.example.mi_app`. **Cambiarlo rompe el build** si no se registra antes
un cliente Android nuevo en Firebase (Project settings → Add app → Android):

```
No matching client found for package name '...' in google-services.json
```

El `namespace` se dejó igual a propósito: el manifest referencia `.MainActivity`,
que resuelve contra el namespace. Si se cambia, hay que mover también el paquete
del archivo Kotlin.
