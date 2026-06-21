# Preserve generic signatures for Gson
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Gson specific rules
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Prevent obfuscation of flutter_local_notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.gdelataillade.alarm.services.** { *; }
-keep class com.gdelataillade.alarm.notification.** { *; }