package com.therivanta.filesaverplus

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.file.Files
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito

/*
 * Unit tests for the Kotlin side of the plugin.
 *
 * Run from the example app: `cd example/android && ./gradlew :filesaverplus:testDebugUnitTest`.
 */
internal class FilesaverplusPluginTest {

    @Test
    fun onMethodCall_getPlatformVersion_returnsExpectedValue() {
        val plugin = FilesaverplusPlugin()
        val result: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(MethodCall("getPlatformVersion", null), result)

        Mockito.verify(result).success("Android " + android.os.Build.VERSION.RELEASE)
    }

    @Test
    fun onMethodCall_unknownMethod_isNotImplemented() {
        val plugin = FilesaverplusPlugin()
        val result: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(MethodCall("nope", null), result)

        Mockito.verify(result).notImplemented()
    }

    @Test
    fun sanitizeFileName_replacesIllegalCharacters() {
        assertEquals("a_b_c.txt", FilesaverplusPlugin.sanitizeFileName("a/b:c.txt"))
        assertEquals("file", FilesaverplusPlugin.sanitizeFileName("  ..  "))
        assertEquals("report.pdf", FilesaverplusPlugin.sanitizeFileName(" report.pdf "))
    }

    @Test
    fun uniqueFile_addsCounterWhenNameIsTaken() {
        val dir: File = Files.createTempDirectory("fsp").toFile()
        try {
            assertEquals("data.txt", FilesaverplusPlugin.uniqueFile(dir, "data.txt").name)
            File(dir, "data.txt").writeText("x")
            assertEquals("data (1).txt", FilesaverplusPlugin.uniqueFile(dir, "data.txt").name)
            File(dir, "data (1).txt").writeText("x")
            assertEquals("data (2).txt", FilesaverplusPlugin.uniqueFile(dir, "data.txt").name)
        } finally {
            dir.deleteRecursively()
        }
    }
}
