allprojects {
    repositories {
        // Unity: repositorio plano para los .jar / .aar de unityLibrary
        val unityLibs = rootProject.file("unityLibrary/libs")
        if (unityLibs.exists()) {
            flatDir { dirs(unityLibs.path) }
        }
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}