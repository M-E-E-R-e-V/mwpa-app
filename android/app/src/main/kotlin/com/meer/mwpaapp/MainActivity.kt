package com.meer.mwpaapp

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    /// reply of a running notification permission request
    private var pendingNotificationResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // see lib/Util/UtilNotificationPermission.dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "request" -> requestNotificationPermission(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun isNotificationGranted(): Boolean {
        // before Android 13 notifications need no runtime permission
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (isNotificationGranted()) {
            result.success(true)
            return
        }

        if (pendingNotificationResult != null) {
            result.error("busy", "A notification permission request is already running", null)
            return
        }

        pendingNotificationResult = result
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        // super delivers the results of the plugins (geolocator, camera, ...)
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED

            pendingNotificationResult?.success(granted)
            pendingNotificationResult = null
        }
    }

    companion object {
        private const val CHANNEL = "mwpa/notification_permission"
        private const val REQUEST_CODE = 4711
    }
}
