package com.parsa.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import com.auth0.android.provider.WebAuthProvider

class MainActivity : FlutterActivity() {

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Handle the callback from Auth0
        WebAuthProvider.resume(intent)
    }
}