package org.gordeev.smartreader;

import android.Manifest;
import android.view.Window;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceView;
import android.widget.RelativeLayout;
import android.content.Intent;
import java.util.HashMap;
import org.json.JSONObject;
import biz.smartengines.smartid.swig.RecognitionResult;
import biz.smartengines.smartid.swig.StringField;
import biz.smartengines.smartid.swig.StringVector;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

public class SmartIDActivity extends Activity implements SmartIDCallback {

    private static final String TAG = "SmartIDReaderActivity";
    private SmartIDView view = new SmartIDView();
    private final int REQUEST_CAMERA_PERMISSION = 1;
    private String document_mask = "rus.passport.*";
    private String time_out = "5.0";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        try {
            this.requestWindowFeature(Window.FEATURE_NO_TITLE);

            Bundle bundle = getIntent().getExtras();
            if (bundle != null) {
                String mask = bundle.getString("mask");
                String timeout = bundle.getString("timeout");
                if (mask != null) this.document_mask = mask;
                if (timeout != null) this.time_out = timeout;
            }

            setContentView(getResources().getIdentifier("activity_main", "layout", getPackageName()));

            if (permission(Manifest.permission.CAMERA)) {
                request(Manifest.permission.CAMERA, REQUEST_CAMERA_PERMISSION);
            }

            initEngine();
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
    }

    private void initEngine() {
        try {
            view.initializeEngine(this, this);
        } catch (Exception e) {
            Log.d(TAG, "Engine initialization failed: " + e.toString());
        }

        SurfaceView preview = (SurfaceView) findViewById(getResources().getIdentifier("preview", "id", getPackageName()));
        RelativeLayout drawing = (RelativeLayout) findViewById(getResources().getIdentifier("drawing", "id", getPackageName()));
        view.setSurface(preview, drawing);
    }

    public boolean permission(String permission) {
        int result = ContextCompat.checkSelfPermission(this, permission);
        return result != PackageManager.PERMISSION_GRANTED;
    }

    public void request(String permission, int request_code) {
        ActivityCompat.requestPermissions(this, new String[]{permission}, request_code);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case REQUEST_CAMERA_PERMISSION: {
                boolean granted = false;
                for (int grantResult : grantResults) {
                    if (grantResult == PackageManager.PERMISSION_GRANTED) {
                        granted = true;
                    }
                }
                if (granted) {
                    view.updatePreview();
                } else {
                    Intent intent = new Intent();
                    setResult(Activity.RESULT_CANCELED, intent);
                    finish();
                    return;
                }
            }
            default: {
                super.onRequestPermissionsResult(requestCode, permissions, grantResults);
            }
        }
    }

    @Override
    public void recognized(RecognitionResult result) {

        if (result.IsTerminal()) {
            view.stopRecognition();

            if (result.GetDocumentType().isEmpty()) {
                Intent intent = new Intent();
                setResult(Activity.RESULT_CANCELED, intent);
                finish();
                return;
            }

            JSONObject json = this.getFormattedResult(result);

            Intent intent = new Intent();
            intent.putExtra("result", json.toString());
            setResult(Activity.RESULT_OK, intent);
            finish();
        }
    }

    private JSONObject getFormattedResult(RecognitionResult data) {
        HashMap result = new HashMap();
        StringVector fieldsNames = data.GetStringFieldNames();

        for (int i = 0; i < fieldsNames.size(); i++) {
            String key = fieldsNames.get(i);
            StringField field = data.GetStringField(key);

            HashMap item = new HashMap();
            item.put("value", field.GetUtf8Value());
            item.put("isAccepted", field.IsAccepted());

            result.put(key, item);
        }

        return new JSONObject(result);
    }

    @Override
    public void initialized(boolean success) {
        view.startRecognition(this.document_mask, this.time_out);
    }

    @Override
    public void started() {}

    @Override
    public void stopped() {}

    @Override
    public void error(String message) {
        // TODO: notify user
        Log.d(TAG, "ERROR: " + message.toString());
        Intent intent = new Intent();
        setResult(Activity.RESULT_CANCELED, intent);
        finish();
    }

}