package com.example.flutterappmedigo;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.widget.RemoteViews;
import android.content.ComponentName;
import com.journeyapps.barcodescanner.BarcodeEncoder;
import com.google.zxing.BarcodeFormat;

public class MyAppWidgetProvider extends AppWidgetProvider {

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            // Retrieve the saved QR code data from SharedPreferences
            SharedPreferences prefs = context.getSharedPreferences("WidgetData", Context.MODE_PRIVATE);
            String qrCode = prefs.getString("qrCode", "");

            // Create a RemoteViews object for the widget layout
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_layout);

            if (!qrCode.isEmpty()) {
                try {
                    // Generate the QR code bitmap
                    BarcodeEncoder barcodeEncoder = new BarcodeEncoder();
                    Bitmap bitmap = barcodeEncoder.encodeBitmap(qrCode, BarcodeFormat.QR_CODE, 200, 200);

                    // Set the QR code bitmap to the ImageView in the widget layout
                    views.setImageViewBitmap(R.id.widgetImageView, bitmap);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            // Update the widget with the new data
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }

    // This method will be used to update the widget's QR code data
    public static void updateWidget(Context context, String qrCode) {
        SharedPreferences prefs = context.getSharedPreferences("WidgetData", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("qrCode", qrCode);
        editor.apply();

        // Notify the widget to update itself
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
        int[] appWidgetIds = appWidgetManager.getAppWidgetIds(new ComponentName(context, MyAppWidgetProvider.class));
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widgetImageView);
        appWidgetManager.updateAppWidget(appWidgetIds, new RemoteViews(context.getPackageName(), R.layout.widget_layout));
    }
}
