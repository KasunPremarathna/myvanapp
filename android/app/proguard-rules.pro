# ProGuard/R8 rules to handle missing classes from optional dependencies
-dontwarn com.fasterxml.jackson.**
-dontwarn com.google.auto.value.**
-dontwarn io.opentelemetry.**
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
-dontwarn com.google.errorprone.annotations.**

# Firebase & OneSignal
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
