pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.4.1" apply false
    // Declared, never applied: with built-in Kotlin AGP compiles Kotlin
    // itself but takes the compiler version from this declaration
    // (its bundled 2.2.10 is below Flutter's 2.2.20 minimum).
    id("org.jetbrains.kotlin.android") version "2.4.20" apply false
}

include(":app")