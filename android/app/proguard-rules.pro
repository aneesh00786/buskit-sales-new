# Stripe Core
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }

# Push Provisioning
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }

# Specific missing classes
-keep class com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# General rules
-keepattributes *Annotation*
-dontwarn com.stripe.android.**