package com.example.flutterappmedigo;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;

import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.myapp/widget";
    private static final String IMAGE_PICKER_CHANNEL = "com.example.myapp/image_picker";
    private static final int IMAGE_PICKER_REQUEST_CODE = 1000;
    private MethodChannel.Result pendingResult;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupWidgetChannel();
        setupImagePickerChannel();
    }

    private void setupWidgetChannel() {
        new MethodChannel(getFlutterEngine().getDartExecutor(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if ("updateWidget".equals(call.method)) {
                        String qrCode = call.argument("qrCode");
                        if (qrCode != null) {
                            MyAppWidgetProvider.updateWidget(getApplicationContext(), qrCode);
                            result.success("Widget updated successfully!");
                        } else {
                            result.error("INVALID_ARGUMENT", "QR Code data is null", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

    private void setupImagePickerChannel() {
        new MethodChannel(getFlutterEngine().getDartExecutor(), IMAGE_PICKER_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if ("pickImage".equals(call.method)) {
                        pendingResult = result;
                        pickImageFromGallery();
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

    private void pickImageFromGallery() {
        Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(intent, IMAGE_PICKER_REQUEST_CODE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == IMAGE_PICKER_REQUEST_CODE) {
            if (pendingResult != null) {
                if (resultCode == RESULT_OK && data != null && data.getData() != null) {
                    Uri selectedImageUri = data.getData();
                    pendingResult.success(selectedImageUri.toString());
                } else {
                    pendingResult.error("IMAGE_PICKER_ERROR", "Image picking cancelled or failed", null);
                }
                pendingResult = null; // Clear the pending result
            }
        }
    }
}
