package org.gordeev.smartreader;

import android.app.Activity;
import android.util.Log;
import android.content.Intent;
import org.json.JSONArray;
import org.json.JSONException;
import org.apache.cordova.*;

public class SmartIDReader extends CordovaPlugin {

    private static final String TAG = "SmartIDReader";
    private CallbackContext callbackContext;
    private boolean processing;

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        Log.d(TAG, "Initializing SmartIDReader");
    }

    public boolean execute(String action, JSONArray args, CallbackContext cb) throws JSONException {
        try {
            if (action.equals("recognize")) {
                if (!this.processing) {
                    this.callbackContext = cb;

                    String mask = args.optString(0);
                    String time_out = args.optString(1);

                    startRecognizeActivity(mask, time_out);
                }
            }
            return true;
        } catch (Exception error) {
            Log.d(TAG, error.toString());
            callbackContext.error("[SmartIDReader] error - " + error.toString());
            return false;
        }
    }


    private void startRecognizeActivity(String mask, String timeout) {
        try {
            this.processing = true;

            final Intent intent = new Intent(cordova.getActivity().getApplicationContext(), org.gordeev.smartreader.SmartIDActivity.class);

            if (!mask.isEmpty()) intent.putExtra("mask", mask);
            if (!timeout.isEmpty()) intent.putExtra("timeout", timeout);

            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    cordova.setActivityResultCallback(SmartIDReader.this);
                    cordova.getActivity().startActivityForResult(intent, 1);
                }
            });

        } catch (Exception e) {
            Log.d(TAG, e.toString());
            if (callbackContext != null) {
                callbackContext.error(e.toString());
                callbackContext = null;
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        this.processing = false;

        if (resultCode == Activity.RESULT_CANCELED) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            callbackContext.sendPluginResult(pluginResult);
            callbackContext = null;
            return;
        }

        if (resultCode == Activity.RESULT_OK) {
            String result = data.getStringExtra("result");
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, result);
            callbackContext.sendPluginResult(pluginResult);
            callbackContext = null;
            return;
        }
    }

}
