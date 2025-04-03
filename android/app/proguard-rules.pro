-keep class com.auth0.** { *; }
-dontwarn com.auth0.**

-keep class com.google.gson.** { *; }  # Only if you're using Gson directly with Auth0
-dontwarn com.google.gson.**

-keep class com.google.android.gms.** { *; }

-keep class com.huawei.hms.ads.** { *; }
-keep interface com.huawei.hms.ads.** { *; }

-keepclassmembers class com.parsa.app.MainActivity {
    public void onNewIntent(android.content.Intent);
}

# These are generally good practice but might not be strictly necessary for Auth0
-keepattributes *Annotation*, Exceptions, Signature, InnerClasses, EnclosingMethod

# Add this to keep line number information for better stack traces (optional but recommended)
-keepattributes SourceFile,LineNumberTable