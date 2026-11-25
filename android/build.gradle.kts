group = "com.therivanta.filesaverplus"
version = "1.1.0"

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.3.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.4.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

// AGP 9+ compiles Kotlin itself ("built-in Kotlin"), on by default unless the host app sets
// `android.builtInKotlin=false` (Flutter 3.50's app template still does). Applying the Kotlin
// Gradle Plugin on top of built-in Kotlin is what Flutter warns will become a build failure, but
// apps on AGP 8, or with built-in Kotlin disabled, still need KGP to compile this plugin's Kotlin
// sources. So apply KGP only when built-in Kotlin isn't active.
val agpMajorVersion = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION.substringBefore('.').toInt()
val builtInKotlinEnabled = agpMajorVersion >= 9 &&
    (findProperty("android.builtInKotlin")?.toString()?.toBooleanStrictOrNull() ?: true)
if (!builtInKotlinEnabled) {
    apply(plugin = "org.jetbrains.kotlin.android")
}

android {
    namespace = "com.therivanta.filesaverplus"

    compileSdk = 37

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        // Android 7.0. The plugin declares no permissions on any API level.
        minSdk = 24
    }

    testOptions {
        unitTests.isReturnDefaultValues = true
        unitTests.all {
            it.useJUnitPlatform()

            it.testLogging {
                events("passed", "skipped", "failed", "standardOut", "standardError")
                showStandardStreams = true
            }
        }
    }
}

// Configured through the compile tasks rather than the `kotlin {}` extension accessor, which
// only exists when KGP is applied in the `plugins {}` block; this works in both modes above.
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.14.2")
}
