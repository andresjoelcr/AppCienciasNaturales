plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mi_app"
    compileSdk = flutter.compileSdkVersion
    // NDK 28.2.13676358: es el mas alto que piden los plugins de Flutter y el mas
    // compatible hacia atras (regla de Flutter cuando varios plugins piden distinto NDK).
    //
    // OJO: este NDK es solo para el modulo 'app'. El modulo 'unityLibrary' sigue con el
    // NDK de Unity (27.2.12479018) via ndkPath, porque la compilacion de IL2CPP la
    // ejecuta Unity con su propia cadena de herramientas y no la de Gradle.
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        // OJO: cambiarlo exige registrar un cliente nuevo en Firebase
        // (project settings > apps > Android). Ver README-unity.md
        applicationId = "com.example.mi_app"
        minSdk = 29  // unityLibrary exige 29; ARCore/Vuforia necesitan 24+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ← AGREGADO: necesario para Firebase
    }

    // La clave local de EduRA corresponde al OAuth de desarrollo registrado en
    // Firebase. Cada desarrollador puede compilar aun si no tiene este archivo.
    val eduraDebugKeystore = file("edura-debug.keystore")
    if (eduraDebugKeystore.exists()) {
        signingConfigs {
            create("eduraDebug") {
                storeFile = eduraDebugKeystore
                storePassword = "android"
                keyAlias = "eduradebugkey"
                keyPassword = "android"
            }
        }
    }

    buildTypes {
        debug {
            if (eduraDebugKeystore.exists()) {
                signingConfig = signingConfigs.getByName("eduraDebug")
            }
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ← AGREGADO: Dependencias de Firebase
dependencies {
    implementation("com.android.support:multidex:1.0.3")

    // Unity: solo cuando ya se exporto el proyecto a android/unityLibrary
    // (el plugin flutter_unity_widget_2 exige :unityLibrary de forma incondicional)
    if (rootProject.file("unityLibrary").exists()) {
        implementation(project(":flutter_unity_widget_2"))
        implementation(project(":unityLibrary"))
    }
}

// ← AGREGADO: Plugin de Google Services
apply(plugin = "com.google.gms.google-services")
