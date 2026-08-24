package com.sponsoradog.sponsor_a_dog

import io.flutter.embedding.android.FlutterFragmentActivity

// RevenueCat's paywall UI (purchases_ui_flutter) renders via native Android
// Fragments, which requires a FlutterFragmentActivity host instead of the
// default FlutterActivity — presentPaywall() throws otherwise.
class MainActivity : FlutterFragmentActivity()
