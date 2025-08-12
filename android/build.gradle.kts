allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Apply configuration to all subprojects
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") || 
            project.plugins.hasPlugin("com.android.library")) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(35)
                defaultConfig {
                    minSdk = 23
                    targetSdk = 35
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
