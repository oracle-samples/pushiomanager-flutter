/**
* Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
*
* Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
*/

package com.pushio.manager.flutter;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.widget.Button;
import android.widget.RelativeLayout;

import com.google.firebase.messaging.RemoteMessage;
import com.pushio.manager.PIOBeaconRegion;
import com.pushio.manager.PIOConversionEvent;
import com.pushio.manager.PIOGeoRegion;
import com.pushio.manager.PIOInteractiveNotificationButton;
import com.pushio.manager.PIOInteractiveNotificationCategory;
import com.pushio.manager.PIOLogger;
import com.pushio.manager.PIOMCMessage;
import com.pushio.manager.PIORegionEventType;
import com.pushio.manager.preferences.PushIOPreference;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

public class PIOUtils {

    static List<HashMap<String, Object>> preferencesAsList(List<PushIOPreference> preferences) {

        List<HashMap<String, Object>> preferenceList = new ArrayList<>();

        for (PushIOPreference preference : preferences) {
            HashMap<String, Object> preferenceMap = new HashMap<>();
            preferenceMap.put("key", preference.getKey());
            preferenceMap.put("label", preference.getLabel());
            preferenceMap.put("value", preference.getValue());
            preferenceMap.put("type", preference.getType().toString());

            preferenceList.add(preferenceMap);
        }

        return preferenceList;
    }

    static HashMap<String, Object> preferenceAsMap(PushIOPreference preference) {
        HashMap<String, Object> preferenceMap = new HashMap<>();
        preferenceMap.put("key", preference.getKey());
        preferenceMap.put("label", preference.getLabel());
        preferenceMap.put("value", preference.getValue());
        preferenceMap.put("type", preference.getType().toString());

        return preferenceMap;
    }

    static List<HashMap<String, Object>> messageCenterMessagesAsList(List<PIOMCMessage> messages) {
        List<HashMap<String, Object>> messageList = new ArrayList<>();

        for (PIOMCMessage message : messages) {
            HashMap<String, Object> messageMap = new HashMap<>();
            messageMap.put("messageID", message.getId());
            messageMap.put("subject", message.getSubject());
            messageMap.put("message", message.getMessage());
            messageMap.put("iconURL", message.getIconUrl());
            messageMap.put("messageCenterName", message.getMessageCenterName());
            messageMap.put("deeplinkURL", message.getDeeplinkUrl());
            messageMap.put("richMessageHTML", message.getRichMessageHtml());
            messageMap.put("richMessageURL", message.getRichMessageUrl());
            messageMap.put("sentTimestamp", getDateAsString(message.getSentTimestamp()));
            messageMap.put("expiryTimestamp", getDateAsString(message.getExpiryTimestamp()));

            messageList.add(messageMap);
        }

        return messageList;
    }

    private static String getDateAsString(Date date) {
        if (date != null) {
            DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZZZZZ", Locale.getDefault());
            df.setTimeZone(TimeZone.getDefault());
            return df.format(date);
        }

        return null;
    }

    static PIOGeoRegion geoRegionFromMap(Map<String, Object> regionMap, PIORegionEventType regionEventType) {
        PIOGeoRegion region = new PIOGeoRegion();

        final String geofenceId = (String) regionMap.get("geofenceId");
        final String geofenceName = (String) regionMap.get("geofenceName");

        if (TextUtils.isEmpty(geofenceId) || TextUtils.isEmpty(geofenceName)) {
            return null;
        }

        region.setGeofenceId(geofenceId);
        region.setGeofenceName(geofenceName);
        region.setRegionEventType(regionEventType);
        region.setZoneName((String) regionMap.get("zoneName"));
        region.setZoneId((String) regionMap.get("zoneId"));
        region.setSource((String) regionMap.get("source"));
        region.setDeviceBearing((Double) regionMap.get("deviceBearing"));
        region.setDeviceSpeed((Double) regionMap.get("deviceSpeed"));
        region.setDwellTime((Integer) regionMap.get("dwellTime"));

        if (regionMap.containsKey("extra")) {
            Map<String, String> extraData = (Map<String, String>) regionMap.get("extra");
            if (extraData != null) {
                region.setExtra(extraData);
            }
        }

        return region;
    }

    static PIOBeaconRegion beaconRegionFromMap(Map<String, Object> regionMap, PIORegionEventType regionEventType) {
        PIOBeaconRegion region = new PIOBeaconRegion();

        final String beaconId = (String) regionMap.get("beaconId");
        final String beaconName = (String) regionMap.get("beaconName");

        if (TextUtils.isEmpty(beaconId) || TextUtils.isEmpty(beaconName)) {
            return null;
        }

        region.setBeaconId(beaconId);
        region.setBeaconName(beaconName);

        region.setBeaconTag((String) regionMap.get("beaconTag"));
        region.setBeaconProximity((String) regionMap.get("beaconProximity"));
        region.setiBeaconUUID((String) regionMap.get("iBeaconUUID"));
        region.setiBeaconMajor((Integer) regionMap.get("iBeaconMajor"));
        region.setiBeaconMinor((Integer) regionMap.get("iBeaconMinor"));
        region.setEddyStoneID1((String) regionMap.get("eddyStoneId1"));
        region.setEddyStoneID2((String) regionMap.get("eddyStoneId2"));

        region.setRegionEventType(regionEventType);
        region.setZoneName((String) regionMap.get("zoneName"));
        region.setZoneId((String) regionMap.get("zoneId"));
        region.setSource((String) regionMap.get("source"));
        region.setDwellTime((Integer) regionMap.get("dwellTime"));

        if (regionMap.containsKey("extra")) {
            Map<String, String> extraData = (Map<String, String>) regionMap.get("extra");
            if (extraData != null) {
                region.setExtra(extraData);
            }
        }

        return region;
    }

    static <K, V> void dumpMap(Map<K, V> map) {
        if (map == null) {
            return;
        }

        PIOLogger.v("FL dM dumping map...");

        for (Map.Entry<K, V> entry : map.entrySet()) {
            PIOLogger.v("FL dM " + entry.getKey() + " : " + entry.getValue());
        }
    }

    static Map<String, Object> notificationCategoryToMap(PIOInteractiveNotificationCategory notificationCategory) {
        HashMap<String, Object> notificationCategoryMap = new HashMap<>();

        final String categoryID = notificationCategory.getCategory();

        notificationCategoryMap.put("orcl_category", categoryID);

        List<Map<String, String>> notificationButtons = new ArrayList<>();

        for (PIOInteractiveNotificationButton button : notificationCategory.getInteractiveNotificationButtons()) {
            HashMap<String, String> map = new HashMap<>();
            map.put("id", button.getId());
            map.put("action", button.getAction());
            map.put("label", button.getLabel());

            notificationButtons.add(map);
        }

        notificationCategoryMap.put("orcl_btns", notificationButtons);

        return notificationCategoryMap;
    }

    static PIOInteractiveNotificationCategory notificationCategoryFromMap(Map<String, Object> notificationCategoryMap) {
        final String category = (String) notificationCategoryMap.get("orcl_category");
        final List<Map<String, String>> buttons = (List<Map<String, String>>) notificationCategoryMap.get("orcl_btns");

        if (TextUtils.isEmpty(category) || buttons == null) {
            return null;
        }

        PIOInteractiveNotificationCategory notificationCategory = new PIOInteractiveNotificationCategory();
        notificationCategory.setCategory(category);

        for (int i = 0; i < buttons.size(); ++i) {
            Map<String, String> map = buttons.get(i);
            if (map != null) {
                PIOInteractiveNotificationButton notificationButton = new PIOInteractiveNotificationButton();
                notificationButton.setId(map.get("id"));
                notificationButton.setAction(map.get("action"));
                notificationButton.setLabel(map.get("label"));

                notificationCategory.addInteractiveNotificationButton(notificationButton);
            }
        }

        return notificationCategory;
    }

    static RemoteMessage remoteMessageFromMap(Map<String, String> message) {
        if (message != null) {
            Bundle messageBundle = new Bundle();
            for (Map.Entry<String, String> entry : message.entrySet()) {
                messageBundle.putString(entry.getKey(), entry.getValue());
            }

            return new RemoteMessage(messageBundle);
        } else {
            return null;
        }
    }

    static PIOConversionEvent conversionEventFromMap(Map<String, Object> conversionEventMap) {
        if(conversionEventMap == null){
            return null;
        }

        PIOConversionEvent conversionEvent = new PIOConversionEvent();
        conversionEvent.setConversionType((Integer) conversionEventMap.get("conversionType"));
        conversionEvent.setOrderId((String) conversionEventMap.get("orderId"));

        try{
            conversionEvent.setOrderAmount((Double) conversionEventMap.get("orderTotal"));
            conversionEvent.setOrderQuantity((Integer) conversionEventMap.get("orderQuantity"));
        }catch(NumberFormatException | ClassCastException e){
            PIOLogger.v("FL cEFRM "+e);
        }

        if(conversionEventMap.containsKey("customProperties")){
            Map<String, String> customProperties = (Map<String, String>) conversionEventMap.get("customProperties");

            if(customProperties != null){
                conversionEvent.setProperties(customProperties);
            }
        }

        return conversionEvent;
    }

    static String getContainerAppName(Context context) {
        ApplicationInfo applicationInfo = context.getApplicationInfo();
        int resId = applicationInfo.labelRes;
        return (resId == 0 ? applicationInfo.nonLocalizedLabel.toString() : context.getString(resId));
    }

    static String getAppStringResource(Context context, String res) {
        final int stringRes = context.getResources().getIdentifier(res, "string", context.getPackageName());
        if (stringRes == 0) {
            return null;
        }
        return context.getString(stringRes);
    }

    static Button getButtonFromJson(Activity activity, String buttonAsJsonStr) throws Exception {

        JSONObject obj = new JSONObject(buttonAsJsonStr);

        Button button = new Button(activity);

        final String title = obj.optString("title");
        if (!TextUtils.isEmpty(title)) {
            button.setText(title);
            button.setTextSize(15f);
            button.setTypeface(null, Typeface.BOLD);
            button.setPadding(0, 0, 0, 0);
            button.setGravity(Gravity.CENTER);
        }

        final String titleColorHex = obj.optString("titleColor");
        if (!TextUtils.isEmpty(titleColorHex) && titleColorHex.startsWith("#")) {
            int titleColor = Color.parseColor(titleColorHex);
            button.setTextColor(titleColor);
        }

        String backgroundColorHex = obj.optString("backgroundColor");
        if (!TextUtils.isEmpty(backgroundColorHex) && backgroundColorHex.startsWith("#")) {
            int backgroundColor = Color.parseColor(backgroundColorHex);
            button.setBackgroundColor(backgroundColor);
        }

        final String drawableName = obj.optString("imageName");
        if (!TextUtils.isEmpty(drawableName)) {
            int drawableResId = activity.getResources().getIdentifier(
                    drawableName, "drawable", activity.getPackageName());

            if (drawableResId <= 0) {
                drawableResId = activity.getResources().getIdentifier(
                        drawableName, "mipmap", activity.getPackageName());
            }

            if (drawableResId > 0) {
                button.setBackgroundResource(drawableResId);
            }
        }

        double width = obj.optDouble("width");
        if (width <= 0.0) {
            width = 30.0;
        }

        double height = obj.optDouble("height");
        if (height <= 0.0) {
            height = 30.0;
        }

        button.setLayoutParams(new RelativeLayout.LayoutParams(dpToPx(activity, width), dpToPx(activity, height)));
       
        return button;
    }

    private static int dpToPx(Context context, double dp) {
        DisplayMetrics displayMetrics = context.getResources().getDisplayMetrics();
        return (int) ((dp * displayMetrics.density) + 0.5);
    }
}