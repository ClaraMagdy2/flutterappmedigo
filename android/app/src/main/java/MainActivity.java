package com.example.flutterappmedigo;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class MainActivity extends FlutterActivity {
    private static final String WIDGET_CHANNEL = "com.example.myapp/widget";
    private static final String IMAGE_PICKER_CHANNEL = "com.example.myapp/image_picker";

    private static final int IMAGE_PICKER_REQUEST_CODE = 1000;
    private static final int PERMISSION_REQUEST_CODE = 2000;

    private MethodChannel.Result pendingResult;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // 1) Widget channel (for your widget logic)
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), WIDGET_CHANNEL)
                .setMethodCallHandler((call, result) -> {
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
                });

        // 2) Image picker channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), IMAGE_PICKER_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "pickImage":
                            pendingResult = result;
                            requestStoragePermissionAndPickImage();
                            break;
                        case "getAbsolutePath":
                            // If you need to convert a content:// URI to a direct file path
                            // (but in many cases, you'll just copy the file instead)
                            String contentUriString = call.arguments instanceof String
                                    ? (String) call.arguments
                                    : null;
                            if (contentUriString != null) {
                                String realPath = getRealPathFromURI(contentUriString);
                                if (realPath != null) {
                                    result.success(realPath);
                                } else {
                                    result.error("UNAVAILABLE", "Could not retrieve absolute path.", null);
                                }
                            } else {
                                result.error("INVALID_ARGUMENT", "Argument is null", null);
                            }
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    /**
     * Check and request permission for reading images on Android 13+ (READ_MEDIA_IMAGES)
     * or older devices (READ_EXTERNAL_STORAGE). If granted, pickImageFromGallery() is called.
     */
    private void requestStoragePermissionAndPickImage() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+
            if (ContextCompat.checkSelfPermission(
                    this,
                    android.Manifest.permission.READ_MEDIA_IMAGES
            ) != PackageManager.PERMISSION_GRANTED) {

                ActivityCompat.requestPermissions(
                        this,
                        new String[]{android.Manifest.permission.READ_MEDIA_IMAGES},
                        PERMISSION_REQUEST_CODE
                );
            } else {
                // Permission already granted
                pickImageFromGallery();
            }
        } else {
            // Older Android versions => READ_EXTERNAL_STORAGE
            if (ContextCompat.checkSelfPermission(
                    this,
                    android.Manifest.permission.READ_EXTERNAL_STORAGE
            ) != PackageManager.PERMISSION_GRANTED) {

                ActivityCompat.requestPermissions(
                        this,
                        new String[]{android.Manifest.permission.READ_EXTERNAL_STORAGE},
                        PERMISSION_REQUEST_CODE
                );
            } else {
                // Permission already granted
                pickImageFromGallery();
            }
        }
    }

    /**
     * Called when the user responds to the permission dialog.
     */
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        if (requestCode == PERMISSION_REQUEST_CODE) {
            // If user granted permission, pick the image
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                pickImageFromGallery();
            } else {
                // Permission denied
                if (pendingResult != null) {
                    pendingResult.error("PERMISSION_DENIED", "User denied storage permission.", null);
                    pendingResult = null;
                }
            }
        }
    }

    /**
     * Launches the system gallery to pick an image.
     */
    private void pickImageFromGallery() {
        Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(intent, IMAGE_PICKER_REQUEST_CODE);
    }

    /**
     * Receives the result from the gallery picker.
     * We then copy the content:// URI to our app's cache directory to avoid "Permission denied".
     */
    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == IMAGE_PICKER_REQUEST_CODE) {
            if (pendingResult != null) {
                if (resultCode == RESULT_OK && data != null && data.getData() != null) {
                    Uri selectedImageUri = data.getData();
                    try {
                        // 1) Copy from content:// to a local file in cache
                        String localPath = copyUriToCache(selectedImageUri);

                        // 2) Return the local file path to Flutter
                        pendingResult.success(localPath);
                    } catch (Exception e) {
                        pendingResult.error("IMAGE_COPY_ERROR", "Failed to copy image: " + e, null);
                    }
                } else {
                    pendingResult.error("IMAGE_PICKER_ERROR", "Image picking cancelled or failed", null);
                }
                pendingResult = null; // Clear the pending result.
            }
        }
    }

    /**
     * Copies the image from a content:// URI to a file in getCacheDir().
     * Returns the absolute path to the new file.
     */
    private String copyUriToCache(Uri uri) throws Exception {
        // Open an InputStream from the content URI
        try (InputStream inputStream = getContentResolver().openInputStream(uri)) {
            if (inputStream == null) {
                throw new Exception("Cannot open input stream for URI: " + uri);
            }

            // Create a temp file in cache
            File tempFile = new File(getCacheDir(), "temp_image_" + System.currentTimeMillis());

            // Write the bytes from inputStream into tempFile
            try (FileOutputStream outputStream = new FileOutputStream(tempFile)) {
                byte[] buffer = new byte[1024];
                int length;
                while ((length = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, length);
                }
            }

            return tempFile.getAbsolutePath();
        }
    }

    /**
     * Converts a content:// URI to a local filesystem path (if possible).
     * This is often unreliable on modern Android. Copying is recommended instead.
     */
    private String getRealPathFromURI(String contentUriString) {
        Uri uri = Uri.parse(contentUriString);
        Cursor cursor = null;
        try {
            String[] proj = { MediaStore.Images.Media.DATA };
            cursor = getContentResolver().query(uri, proj, null, null, null);
            if (cursor != null) {
                int columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                if (cursor.moveToFirst()) {
                    return cursor.getString(columnIndex);
                }
            }
            return null;
        } catch (Exception e) {
            return null;
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
    }
}
