allprojects {
    repositories {
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

// Ensure older Flutter plugins define an Android namespace (required by AGP 8+)
subprojects {
    fun setNamespaceIfMissing() {
        val androidExtension = extensions.findByName("android") ?: return
        try {
            val getNamespace = androidExtension.javaClass.methods.firstOrNull {
                it.name == "getNamespace" && it.parameterTypes.isEmpty()
            }
            val setNamespace = androidExtension.javaClass.methods.firstOrNull {
                it.name == "setNamespace" &&
                    it.parameterTypes.size == 1 &&
                    it.parameterTypes[0] == String::class.java
            }
            val currentNamespace = getNamespace?.invoke(androidExtension) as? String
            if (currentNamespace.isNullOrBlank() && setNamespace != null) {
                val safeProjectName = project.name.replace('-', '_')
                setNamespace.invoke(androidExtension, "com.keepjoy.$safeProjectName")
            }
        } catch (_: Throwable) {
            // Ignore – plugin may already define namespace or not expose setters
        }
    }

    plugins.withId("com.android.application") { setNamespaceIfMissing() }
    plugins.withId("com.android.library") { setNamespaceIfMissing() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
