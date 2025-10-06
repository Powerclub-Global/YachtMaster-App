# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Stripe classes
-keep class com.stripe.** { *; }
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# Keep Flutter and Dart classes
-keep class io.flutter.** { *; }
-keep class dartx.** { *; }

# Keep permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep Google Maps classes
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.maps.** { *; }

# Keep image picker classes
-keep class io.flutter.plugins.imagepicker.** { *; }

# General rules for reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Remove debug logging in release builds
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}