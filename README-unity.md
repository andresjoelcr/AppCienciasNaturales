# Integración Unity + Flutter (EduRA)

**Estado: el APK compiló con Unity embebido en la máquina de exportación.** `build\app\outputs\flutter-apk\app-debug.apk` (440 MB debug). Las bibliotecas nativas y el resultado de IL2CPP están ignorados por Git: cada equipo que compile Unity debe restaurar el export conforme a esta guía.

Verificado dentro del APK:
`libil2cpp.so` (78 MB), `libunity.so` (20 MB), `lib_burst_generated.so`,
`libUnityDriver.so`, `libVuforiaEngine.so`, `global-metadata.dat`

---

## ⚠️ Al re-exportar desde Unity hay que repetir esto

El export **pisa** `android/unityLibrary/build.gradle`. Si re-exportas, vuelve a aplicar
el parche de la sección 3.1 o el build falla con `Duplicate class com.unity3d.player.*`.

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

Build Settings: Android, escenas en orden `EscanearTarjetas` (0) y
`EscanerTarjetasV2` (1), IL2CPP, ARM64, OpenGLES3.

---

## 2. Copiar al proyecto Flutter

Solo **dos** carpetas, no todo:

| Origen | Destino | Por qué |
|---|---|---|
| `D:\UnityExport\unityLibrary` | `android\unityLibrary` | el módulo de Unity |
| `D:\UnityExport\shared` | `android\shared` | `build.gradle` hace `apply from: '../shared/common.gradle'` |

`launcher\`, `build.gradle`, `settings.gradle` y `gradle\` del export **no se copian**:
Flutter ya tiene su propio módulo `app` que reemplaza al `launcher`.

---

## 3. Parches aplicados

### 3.1 `android/unityLibrary/build.gradle` — se pierde al re-exportar

```groovy
compileOnly fileTree(dir: 'libs', include: ['*.jar'])   // era implementation
```

`unity-classes.jar` entraba dos veces al classpath: por el `fileTree` de este módulo y
por `flutter_unity_widget_2` vía `flatDir`. Gradle fallaba con
`Duplicate class com.unity3d.player.*`.

Con `compileOnly` el jar sirve solo para compilar el Java de este módulo; el
empaquetado lo aporta el plugin.

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

En `pubspec.yaml`:

```yaml
dependency_overrides:
  flutter_unity_widget_2:
    path: third_party/flutter_unity_widget_2
```

**No afecta al modo widget**, que es el que se usa: `CustomUnityPlayer` extiende
`UnityPlayerForActivityOrService`, y esa clase sí existe en Unity 6.3.
`OverrideUnityActivity` solo la usa `openNativeUnity()`, que nadie llama.

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

### 6.1 Código Dart

Hecho: **Realidad Aumentada → Marcadores de color** abre
`lib/screens/unity_escaneo_screen.dart`, que embeba Unity con `UnityWidget`.

Unity arranca solo en la escena índice 0 (`EscanearTarjetas`); no hace falta pedirle
que cargue escena. `ARScreenSimple` ya no se llama desde ese botón (el archivo sigue
en el repo, sin import en `home_screen.dart`).

Falta para la escena 2 (`EscanerTarjetasV2`): con este paquete **no existe
`loadScene`**. Habría que agregar una escena al Build Settings y usar `postMessage`
con el `UnityMessageManager` del lado de Unity.

`third_party/**` está excluido de `analysis_options.yaml`: su `example/` es una app de
demo que no se compila aquí y falla por `pointer_interceptor`, que no es dependencia
de este proyecto.

### 6.2 Plugin de Unity no importado

Falta importar `fuw-6000.unitypackage` y correr
`Herramientas > Configurar retorno a Flutter (las 2 escenas)`.

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
