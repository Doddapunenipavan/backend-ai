package com.example.merchant_app

import com.example.merchant_app.aadhaar.AadhaarSecureQrSignatureVerifier
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Merchant app host — Aadhaar Secure QR signature verify channel. */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.flextenure.merchant/aadhaar_secure_qr"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val verifier = AadhaarSecureQrSignatureVerifier(applicationContext)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "verifyRawPayload" -> {
                        val payload = call.argument<String>("rawPayload")
                        if (payload.isNullOrBlank()) {
                            result.error("ARG", "rawPayload required", null)
                            return@setMethodCallHandler
                        }
                        result.success(verifier.verifyRawPayload(payload))
                    }
                    "verifyBytes" -> {
                        val signedData = call.argument<ByteArray>("signedData")
                        val signature = call.argument<ByteArray>("signature")
                        if (signedData == null || signature == null) {
                            result.error("ARG", "signedData and signature required", null)
                            return@setMethodCallHandler
                        }
                        result.success(verifier.verify(signedData, signature))
                    }
                    else -> result.notImplemented()
                }
            } catch (e: IllegalArgumentException) {
                result.error("INVALID_QR", e.message, null)
            } catch (e: Exception) {
                result.error("VERIFY_ERROR", e.message, null)
            }
        }
    }
}
