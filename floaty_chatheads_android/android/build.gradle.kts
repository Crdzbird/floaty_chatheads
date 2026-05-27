plugins {
    id("com.android.library")
}

group = "ni.devotion.floaty_chatheads"
version = "1.0-SNAPSHOT"

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

android {
    namespace = "ni.devotion.floaty_chatheads"

    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")
    sourceSets["test"].java.srcDirs("src/test/kotlin")

    defaultConfig {
        minSdk = 24
    }

    dependencies {
        implementation("com.facebook.rebound:rebound:0.3.8")
        implementation("com.google.android.material:material:1.12.0")
        implementation("androidx.core:core-ktx:1.15.0")
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.11.0")
        testImplementation("org.jetbrains.kotlin:kotlin-test")
        testImplementation("org.mockito:mockito-core:5.23.0")
    }

    testOptions {
        unitTests.all {
            it.useJUnitPlatform()
            it.testLogging {
                events(
                    "passed",
                    "skipped",
                    "failed",
                    "standardOut",
                    "standardError",
                )
                outputs.upToDateWhen { false }
                showStandardStreams = true
            }
        }
    }
}

// Backwards-compatible Built-in Kotlin pattern (parked for a future
// release — see CHANGELOG and branch description).
//
// - On AGP < 9 (Flutter 3.27–3.43) the Kotlin Gradle Plugin is not
//   provided by Flutter; apply it explicitly so the build wires KGP.
// - On AGP >= 9 (Flutter 3.44+) Flutter's Gradle Plugin provides KGP
//   via Built-in Kotlin and the explicit apply is skipped, so this
//   plugin no longer appears in Flutter's "applies KGP" warning.
//
// The top-level `kotlin { compilerOptions {} }` DSL replaces the
// legacy `android { kotlinOptions {} }` block and requires KGP 2.0+
// (Flutter 3.27 or any consumer that pins KGP 2.0 themselves).
val agpMajor = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION
    .substringBefore('.').toInt()

if (agpMajor < 9) {
    apply(plugin = "kotlin-android")
}

project.extensions.configure(
    org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension::class.java,
) {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}
