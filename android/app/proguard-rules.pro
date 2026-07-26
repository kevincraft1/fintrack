# ProGuard Rules for FinTrack Pro
# https://www.guardsquare.com/proguard

## Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Isar Database
-keep class * extends isar.IsarObject { *; }
-keepclassmembers class * {
    @isar.Ignore <methods>;
    @isar.Id <fields>;
    @isar.Index <fields>;
}

## GetX
-keep class com.getcapacitor.** { *; }
-keepclassmembers class * {
    @javafx.fxml.FXML <methods>;
    @javafx.fxml.FXML <fields>;
}

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items).
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

## With R8 full mode generic signatures are stripped for classes that are not kept.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

## Google Fonts
-keep class com.google.android.gms.** { *; }

## PDF & Printing
-keep class org.apache.pdfbox.** { *; }
-keep class com.itextpdf.** { *; }

## File Picker
-keep class io.flutter.plugins.filepicker.** { *; }

## Share Plus
-keep class io.flutter.plugins.share.** { *; }

## Local Auth (Biometric)
-keep class androidx.biometric.** { *; }
-keep class androidx.core.app.** { *; }

## Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
