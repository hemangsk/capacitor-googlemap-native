package com.hemangkumar.capacitorgooglemaps;

import android.content.res.Resources;
import android.util.Size;

import androidx.annotation.NonNull;

import com.getcapacitor.JSObject;

class IconDescriptor {
    public final String url;
    public final Size size;

    private float density = Resources.getSystem().getDisplayMetrics().density;

    /**
     * Example source of JSObject:
     * {
     *   url: 'https://www.google.com/favicon.ico',
     *   size: {
     *     width: 64,
     *     height: 64
     *   }
     * }
     * @param jsIcon is a JSObject icon representation
     * @return IconDescriptor
     */
    public IconDescriptor(@NonNull final JSObject jsIcon) {
        url = jsIcon.getString("url", "");

        final JSObject jsSize = JSObjectDefaults.getJSObjectSafe(
                jsIcon,
                "size",
                new JSObject());

        size = new Size(
                (int) Math.round(jsSize.optDouble("width", 30) * density),
                (int) Math.round(jsSize.optDouble("height", 30) * density));
    }

    public boolean isSizeSet() {
        return size.getHeight() > 0 && size.getWidth() > 0;
    }
}