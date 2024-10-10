package com.example.Bizatom

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val TASK_MANAGER_CHANNEL = "com.example.Bizatom/task_manager"
    private val STORE_TASK_MANAGER_CHANNEL = "com.example.Bizatom/store_task_manager"
    private val SEARCH_TASK_MANAGER_CHANNEL = "com.example.Bizatom/search_task_manager"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Handle all channels within a single function
        configureMethodChannels(flutterEngine, TASK_MANAGER_CHANNEL)
        configureMethodChannels(flutterEngine, STORE_TASK_MANAGER_CHANNEL)
        configureMethodChannels(flutterEngine, SEARCH_TASK_MANAGER_CHANNEL)
    }

    private fun configureMethodChannels(flutterEngine: FlutterEngine, channelName: String) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler {
            call, result ->
                when (call.method) {
                    "moveTaskToBack" -> {
                        moveTaskToBack(true)
                        result.success(true)
                    }
                    "storemoveTaskToBack" -> {
                        moveTaskToBack(true)
                        // Handle store-specific logic here
                        result.success(true)
                    }
                    "searchmoveTaskToBack" -> {
                      moveTaskToBack(true)
                        // Handle search-specific logic here
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
        }
    }
}
