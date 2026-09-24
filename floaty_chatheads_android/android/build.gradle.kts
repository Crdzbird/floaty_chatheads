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

// Configured through the public DSL interface (AGP 7+) instead of the
// legacy `android {}` accessor, which is an error-level deprecation on
// the AGP 9 script classpath.
configure<com.android.build.api.dsl.LibraryExtension> {
    namespace = "ni.devotion.floaty_chatheads"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets.getByName("main").java.srcDirs("src/main/kotlin")
    sourceSets.getByName("test").java.srcDirs("src/test/kotlin")

    defaultConfig {
        minSdk = 24
        consumerProguardFiles("consumer-rules.pro")
    }

    testOptions {
        unitTests.all {
            it.useJUnitPlatform()
            it.outputs.upToDateWhen { false }
            it.testLogging {
                events(
                    "passed",
                    "skipped",
                    "failed",
                    "standardOut",
                    "standardError",
                )
                showStandardStreams = true
            }
        }
    }
}

// Built-in Kotlin (Flutter 3.44+ / AGP 9+): Kotlin support comes from
// AGP itself, so no Kotlin Gradle Plugin is applied here. The
// `kotlin {}` extension is provided by Flutter's tooling on every
// supported version.
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    "implementation"("com.facebook.rebound:rebound:0.3.8")
    "implementation"("com.google.android.material:material:1.14.0")
    "implementation"("androidx.core:core-ktx:1.18.0")
    "implementation"("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.11.0")
    "testImplementation"("org.jetbrains.kotlin:kotlin-test")
    "testImplementation"("org.mockito:mockito-core:5.23.0")
}
