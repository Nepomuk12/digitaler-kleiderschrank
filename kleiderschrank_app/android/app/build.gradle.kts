// Aufgabe: Android Build-Konfiguration fuer die Flutter-App.
// Hauptfunktionen: SDK/Build-Typen, Ressourcen-Settings, Dependencies.
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Basis-Android-Config (SDK, Java/Kotlin Targets, App-ID).
    namespace = "com.example.kleiderschrank_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // App-Identitaet und Versionswerte (von Flutter uebernommen).
        applicationId = "com.example.kleiderschrank_app"
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    androidResources {
        // Verhindert Komprimierung der Model-Dateien.
        noCompress += "task"
        noCompress += "tflite"
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    buildTypes {
    release {
        // Release-Flags (Minify/Shrink bewusst deaktiviert).
        isMinifyEnabled = false
        isShrinkResources = false
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )

    }
}
}

dependencies {
    implementation("com.google.mediapipe:tasks-vision:0.10.14")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
}



flutter {
    source = "../.."
}
