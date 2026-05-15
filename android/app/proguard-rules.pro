# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepclassmembers class com.google.firebase.* { *; }
-keepclassmembers class com.google.android.gms.* { *; }

# Keep Flutter/Pigeon classes
-keep class io.flutter.plugins.** { *; }
-keep class dev.flutter.pigeon.** { *; }
-keepclassmembers class dev.flutter.pigeon.* { *; }
