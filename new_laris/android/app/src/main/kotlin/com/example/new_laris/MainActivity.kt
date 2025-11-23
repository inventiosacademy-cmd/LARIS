package com.example.new_laris

import app.meedu.flutter_facebook_auth.FlutterFacebookAuthPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Ensures all plugins (including Facebook) are registered when the engine is created.
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        // Explicitly register Facebook plugin in case auto-registration is skipped.
        runCatching {
            flutterEngine.plugins.add(FlutterFacebookAuthPlugin())
        }
    }
}
