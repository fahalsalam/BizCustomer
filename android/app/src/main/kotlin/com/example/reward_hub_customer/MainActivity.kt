package com.example.Bizatom

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val TASK_MANAGER_CHANNEL = "com.example.Bizatom/task_manager"
    private val STORE_TASK_MANAGER_CHANNEL = "com.example.Bizatom/store_task_manager"
    private val SEARCH_TASK_MANAGER_CHANNEL = "com.example.Bizatom/search_task_manager"
    private val PHONE_DIALER_CHANNEL = "phone_dialer"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize method channels
        configureMethodChannels(flutterEngine, TASK_MANAGER_CHANNEL)
        configureMethodChannels(flutterEngine, STORE_TASK_MANAGER_CHANNEL)
        configureMethodChannels(flutterEngine, SEARCH_TASK_MANAGER_CHANNEL)
        configurePhoneDialerChannel(flutterEngine) // Fixing the phone dialer issue
    }

    private fun configureMethodChannels(flutterEngine: FlutterEngine, channelName: String) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "moveTaskToBack" -> {
                    moveTaskToBack(true)
                    result.success(true)
                }
                "storemoveTaskToBack" -> {
                    moveTaskToBack(true)
                    result.success(true)
                }
                "searchmoveTaskToBack" -> {
                    moveTaskToBack(true)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun configurePhoneDialerChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PHONE_DIALER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makeCall") {
                val phoneNumber = call.argument<String>("phoneNumber")
                if (!phoneNumber.isNullOrEmpty()) {
                    val intent = Intent(Intent.ACTION_DIAL)
                    intent.data = Uri.parse("tel:$phoneNumber")
                    startActivity(intent)
                    result.success(null)
                } else {
                    result.error("INVALID_NUMBER", "Phone number is empty", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
