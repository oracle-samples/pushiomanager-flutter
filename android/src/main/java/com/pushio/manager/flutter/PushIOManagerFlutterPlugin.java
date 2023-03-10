/**
* Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
*
* Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
*/

package com.pushio.manager.flutter;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.OnLifecycleEvent;
import androidx.lifecycle.LifecycleObserver;

import com.google.firebase.messaging.RemoteMessage;
import com.pushio.manager.PIOBadgeSyncListener;
import com.pushio.manager.PIOBeaconRegion;
import com.pushio.manager.PIOCommonUtils;
import com.pushio.manager.PIOConfigurationListener;
import com.pushio.manager.PIOConversionListener;
import com.pushio.manager.PIODeepLinkListener;
import com.pushio.manager.PIOMessageCenterUpdateListener;
import com.pushio.manager.PIOGeoRegion;
import com.pushio.manager.PIOInteractiveNotificationCategory;
import com.pushio.manager.PIOListener;
import com.pushio.manager.PIOLogger;
import com.pushio.manager.PIOMCMessage;
import com.pushio.manager.PIOMCMessageError;
import com.pushio.manager.PIOMCMessageListener;
import com.pushio.manager.PIOMCRichContentListener;
import com.pushio.manager.PIORegionCompletionListener;
import com.pushio.manager.PIORegionEventType;
import com.pushio.manager.PIORegionException;
import com.pushio.manager.PIORsysIAMHyperlinkListener;
import com.pushio.manager.PushIOManager;
import com.pushio.manager.exception.PIOMCMessageException;
import com.pushio.manager.exception.PIOMCRichContentException;
import com.pushio.manager.exception.ValidationException;
import com.pushio.manager.preferences.PushIOPreference;
import com.pushio.manager.tasks.PushIOEngagementListener;
import com.pushio.manager.tasks.PushIOListener;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;


public class PushIOManagerFlutterPlugin implements FlutterPlugin, MethodCallHandler, NewIntentListener, ActivityAware, LifecycleObserver {
    private MethodChannel channel;
    private PushIOManager mPushIOManager;
    private Context mContext;
    private Activity mActivity;
    private Handler mUIThreadHandler = new Handler(Looper.getMainLooper());
    private SharedPreferences mPreferences;
    private Intent launchIntent;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        PIOLogger.v("FL oATE");

        mContext = flutterPluginBinding.getApplicationContext();

        mPushIOManager = PushIOManager.getInstance(mContext);

        mPreferences = mContext.getSharedPreferences("pushio-flutter", Activity.MODE_PRIVATE);

        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "pushiomanager_flutter");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        PIOLogger.v("FL oATA");
        binding.addOnNewIntentListener(this);
        mActivity = binding.getActivity();

        Lifecycle lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
        lifecycle.addObserver(this);

        handleIntent(mActivity.getIntent());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        PIOLogger.v("FL oDFAFCC");
        mActivity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        PIOLogger.v("FL oRTACC");

        binding.addOnNewIntentListener(this);
        mActivity = binding.getActivity();

        Lifecycle lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
        lifecycle.addObserver(this);
    }

    @Override
    public void onDetachedFromActivity() {
        PIOLogger.v("FL oDFA");
        mActivity = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {

            PushIOManagerFlutterPlugin pushIOFlutterPlugin = this;

            final String methodName = call.method;
            PIOLogger.v("FL oMC Plugin Execute: " + methodName);
            Method method = pushIOFlutterPlugin.getClass().getDeclaredMethod(methodName, MethodCall.class,
                    Result.class);
            method.setAccessible(true);
            method.invoke(pushIOFlutterPlugin, call, result);
            method.setAccessible(false);
        } catch (Exception e) {
            PIOLogger.v("FL oMC Exception: " + e.getMessage());
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        PIOLogger.v("FL oDFE");
        channel.setMethodCallHandler(null);
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        PIOLogger.v("FL oNI");

        if (intent == null) {
            return false;
        }

        return handleIntent(intent);
    }

    private boolean handleIntent(Intent intent){
        final String expectedDeepLinkAction = mContext.getPackageName() + ".intent.action.PROCESS_RSYS_DEEPLINK";
        final String expectedAppLinkHost = PIOUtils.getAppStringResource(mContext, "app_links_url_host");

        PIOLogger.v("FL hI expectedAppLinkHost: " + expectedAppLinkHost);

        final String linkIntentAction = intent.getAction();
        final Uri linkIntentDataUri = intent.getData();

        PIOLogger.v("FL hI linkIntentDataUri: " + linkIntentDataUri);

        PIOLogger.v("FL hI Intent Action: " + linkIntentAction);
        if (expectedDeepLinkAction.equalsIgnoreCase(linkIntentAction)) {
            PIOLogger.v("FL hI "+mPreferences.getBoolean("handlePushDeepLink", false));
            launchIntent = intent;
            return true;
        }else if(linkIntentDataUri != null &&
                !TextUtils.isEmpty(expectedAppLinkHost) &&
                expectedAppLinkHost.equalsIgnoreCase(linkIntentDataUri.getHost())){
            PIOLogger.v("FL hI tracking email conversion");
            launchIntent = null;
            trackEmailConversion(intent);
            return true;
        }else{
            return false;
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    private void notifyApp() {

        mUIThreadHandler.postDelayed(new Runnable() {
            @Override
            public void run() {

                if(launchIntent == null){
                    PIOLogger.v("FL hPDL Launch Intent is null");
                    return;
                }
                
                final String uri = launchIntent.getDataString();

                if(!TextUtils.isEmpty(uri)){
                    channel.invokeMethod("setNotificationDeepLinkHandler", uri);
                    launchIntent = null;
                }
            }
        }, 1500);
    }

    private void getAPIKey(MethodCall call, Result result) {
        result.success(mPushIOManager.getAPIKey());
    }

    private void getLibVersion(MethodCall call, Result result) {
        result.success(PushIOManager.getLibVersion());
    }

    private void getAccountToken(MethodCall call, Result result) {
        result.success(mPushIOManager.getAccountToken());
    }

    private void getExternalDeviceTrackingID(MethodCall call, Result result) {
        result.success(mPushIOManager.getExternalDeviceTrackingID());
    }

    private void setExternalDeviceTrackingID(MethodCall call, Result result) {
        final String edti = call.arguments();
        mPushIOManager.setExternalDeviceTrackingID(edti);
        result.success(null);
    }

    private void getAdvertisingID(MethodCall call, Result result) {
        result.success(mPushIOManager.getAdvertisingID());
    }

    private void setAdvertisingID(MethodCall call, Result result) {
        final String adid = call.arguments();
        mPushIOManager.setAdvertisingID(adid);
        result.success(null);
    }

    private void getRegisteredUserId(MethodCall call, Result result) {
        result.success(mPushIOManager.getRegisteredUserId());
    }

    private void registerUserId(MethodCall call, Result result) {
        final String userId = call.arguments();
        mPushIOManager.registerUserId(userId);
        result.success(null);
    }

    private void unregisterUserId(MethodCall call, Result result) {
        mPushIOManager.unregisterUserId();
        result.success(null);
    }

    private void declarePreference(MethodCall call, Result result) {
        final String key = call.argument("key");
        final String label = call.argument("label");
        final String typeStr = call.argument("type");

        final PushIOPreference.Type type = PushIOPreference.Type.valueOf(typeStr);

        try {
            mPushIOManager.declarePreference(key, label, type);
            result.success(null);
        } catch (ValidationException e) {
            result.error(e.getMessage(), null, null);
        }
    }

    private void getPreferences(MethodCall call, Result result) {
        List<PushIOPreference> preferences = mPushIOManager.getPreferences();

        if (preferences != null) {
            result.success(PIOUtils.preferencesAsList(preferences));
        } else {
            result.success(null);
        }
    }

    private void getPreference(MethodCall call, Result result) {
        PushIOPreference preference = mPushIOManager.getPreference(call.arguments.toString());

        if (preference != null) {
            result.success(PIOUtils.preferenceAsMap(preference));
        } else {
            result.success(null);
        }
    }

    private void setStringPreference(MethodCall call, Result result) {
        final String key = call.argument("key");
        final String value = call.argument("value");

        try {
            mPushIOManager.setPreference(key, value);
            result.success(null);
        } catch (ValidationException e) {
            result.error(e.getMessage(), null, null);
        }
    }

    private void setNumberPreference(MethodCall call, Result result) {
        final String key = call.argument("key");
        final Object value = call.argument("value");

        try {
            if (value instanceof Integer) {
                mPushIOManager.setPreference(key, (Integer) value);
            } else if (value instanceof Long) {
                mPushIOManager.setPreference(key, (Long) value);
            } else if (value instanceof Double) {
                mPushIOManager.setPreference(key, (Double) value);
            }

            result.success(null);
        } catch (ValidationException e) {
            result.error(e.getMessage(), null, null);
        }
    }

    private void setBooleanPreference(MethodCall call, Result result) {
        final String key = call.argument("key");
        final boolean value = call.argument("value");

        try {
            mPushIOManager.setPreference(key, value);
            result.success(null);
        } catch (ValidationException e) {
            result.error(e.getMessage(), null, null);
        }
    }

    private void removePreference(MethodCall call, Result result) {
        mPushIOManager.removePreference(call.arguments.toString());
        result.success(null);
    }

    private void clearAllPreferences(MethodCall call, Result result) {
        mPushIOManager.clearAllPreferences();
        result.success(null);
    }

    private void trackEvent(MethodCall call, Result result) {
        final String eventName = call.argument("eventName");
        final Map<String, Object> properties = call.argument("properties");

        mPushIOManager.trackEvent(eventName, properties);
        result.success(null);
    }

    private void fetchMessagesForMessageCenter(MethodCall call, final Result result) {
        final String messageCenter = call.arguments();

        try {
            mPushIOManager.fetchMessagesForMessageCenter(messageCenter, new PIOMCMessageListener() {
                @Override
                public void onSuccess(String messageCenter, List<PIOMCMessage> list) {
                    result.success(PIOUtils.messageCenterMessagesAsList(list));
                }

                @Override
                public void onFailure(String messageCenter, PIOMCMessageError messageError) {
                    result.error(messageError.getErrorMessage(), null, null);
                }
            });
        } catch (PIOMCMessageException e) {
            result.error(e.getMessage(), null, null);
        }
    }

    private void trackEngagement(MethodCall call, final Result result) {
        final int metric = (Integer) call.argument("metric");
        final Map<String, String> properties = call.argument("properties");

        mPushIOManager.trackEngagement(metric, properties, new PushIOEngagementListener() {
            @Override
            public void onEngagementSuccess() {
                result.success(null);
            }

            @Override
            public void onEngagementError(String error) {
                result.error(error, null, null);
            }
        });
    }

    private void setLogLevel(MethodCall call, Result result) {
        final int logLevel = call.arguments();
        PushIOManager.setLogLevel(logLevel);
        result.success(null);
    }

    private void setLoggingEnabled(MethodCall call, Result result) {
        final boolean isEnabled = call.arguments();

        PushIOManager.setLoggingEnabled(isEnabled);
        result.success(null);
    }

    private void overwriteApiKey(MethodCall call, Result result) {
        final String apiKey = call.arguments();

        mPushIOManager.overwriteApiKey(apiKey);
        result.success(null);
    }

    private void overwriteAccountToken(MethodCall call, Result result) {
        final String accountToken = call.arguments();

        mPushIOManager.overwriteAccountToken(accountToken);
        result.success(null);
    }

    private void configure(MethodCall call, final Result result) {
        final String configFileName = call.arguments();

        mPushIOManager.configure(configFileName, new PIOConfigurationListener() {
            @Override
            public void onSDKConfigured(Exception e) {
                if (e == null) {
                    result.success(null);
                } else {
                    result.error(e.getMessage(), null, null);
                }
            }
        });
    }

    private void registerApp(MethodCall call, final Result result) {
        boolean useLocation = false;
        if (call.arguments != null) {
            useLocation = call.arguments();
        }

        mPushIOManager.registerPushIOListener(new PushIOListener() {
            @Override
            public void onPushIOSuccess() {
                mUIThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        result.success(null);
                    }
                });
            }

            @Override
            public void onPushIOError(final String errorReason) {
                mUIThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        result.error(errorReason, null, null);
                    }
                });
            }
        });

        mPushIOManager.registerApp(useLocation);
    }

    private void setMessageCenterEnabled(MethodCall call, Result result){
        boolean isEnabled = call.arguments();

        PIOLogger.v("setMessageCenterEnabled called");

        mPushIOManager.setMessageCenterEnabled(isEnabled);
    }

    private void unregisterApp(MethodCall call, final Result result) {
        mPushIOManager.unregisterApp(new PIOListener() {
            @Override
            public void onSuccess() {
                result.success(null);
            }

            @Override
            public void onFailure(String errorReason) {
                result.error(errorReason, null, null);
            }
        });
    }

    private void getDeviceID(MethodCall call, Result result) {
        result.success(mPushIOManager.getDeviceId());
    }

    private void setDefaultSmallIcon(MethodCall call, Result result){
        int resId = call.arguments();

        mPushIOManager.setDefaultSmallIcon(resId);
    }

    private void setDefaultLargeIcon(MethodCall call, Result result){
        int resId = call.arguments();

        mPushIOManager.setDefaultLargeIcon(resId);
    }

    private void isMessageCenterEnabled(MethodCall call, Result result) {
        result.success(mPushIOManager.isMessageCenterEnabled());
    }

    private void fetchRichContentForMessage(MethodCall call, final Result result) {
        final String messageID = call.arguments();

        try {
            mPushIOManager.fetchRichContentForMessage(messageID, new PIOMCRichContentListener() {
                @Override
                public void onSuccess(String messageID, String richContent) {
                    Map<String, String> response = new HashMap<>();
                    response.put("messageID", messageID);
                    response.put("richContent", richContent);

                    result.success(response);
                }

                @Override
                public void onFailure(String messageID, PIOMCMessageError messageError) {
                    result.error(messageID, messageError.getErrorMessage(), messageError.getErrorDescription());
                }
            });
        } catch (PIOMCRichContentException e) {
            result.error(e.getMessage(), null, null);
        }
    }

    private void setInAppFetchEnabled(MethodCall call, Result result){
        boolean isEnabled = call.arguments();

        mPushIOManager.setInAppFetchEnabled(isEnabled);
    }

    private void setCrashLoggingEnabled(MethodCall call, Result result){
        boolean isEnabled = call.arguments();

        mPushIOManager.setCrashLoggingEnabled(isEnabled);
    }

    private void isCrashLoggingEnabled(MethodCall call, Result result) {
        result.success(mPushIOManager.isCrashLoggingEnabled());
    }

    private void setDeviceToken(MethodCall call, Result result) {
        final String deviceToken = call.arguments();

        mPushIOManager.setDeviceToken(deviceToken);
        result.success(null);
    }

    private void setMessageCenterBadgingEnabled(MethodCall call, Result result){
        boolean isEnabled = call.arguments();

        mPushIOManager.setMessageCenterBadgingEnabled(isEnabled);
    }

    private void setBadgeCount(MethodCall call, final Result result) {

        int badgeCount = call.argument("badgeCount");

        boolean forceSetBadge = false;

        if (call.hasArgument("forceSetBadge")) {
            forceSetBadge = call.argument("forceSetBadge");
        }

        mPushIOManager.setBadgeCount(badgeCount, forceSetBadge, new PIOBadgeSyncListener() {
            @Override
            public void onBadgeSyncedSuccess(String response) {
                result.success(null);
            }

            @Override
            public void onBadgeSyncedFailure(String errorReason) {
                result.error(errorReason, null, null);
            }
        });
    }

    private void getBadgeCount(MethodCall call, Result result) {
        result.success(mPushIOManager.getBadgeCount());
    }

    private void resetBadgeCount(MethodCall call, final Result result) {
        boolean forceSetBadge = false;

        if (call.hasArgument("forceSetBadge")) {
            forceSetBadge = (Boolean) call.argument("forceSetBadge");
        }

        mPushIOManager.resetBadgeCount(forceSetBadge, new PIOBadgeSyncListener() {
            @Override
            public void onBadgeSyncedSuccess(String response) {
                result.success(null);
            }

            @Override
            public void onBadgeSyncedFailure(String errorReason) {
                result.error(errorReason, null, null);
            }
        });
    }

    private void resetMessageCenter(MethodCall call, Result result) {
        mPushIOManager.resetMessageCenter();
        result.success(null);
    }

    private void onMessageCenterViewVisible(MethodCall call, Result result) {
        try {
            mPushIOManager.onMessageCenterViewVisible();
            result.success(null);
        } catch (PIOMCMessageException e) {
            result.error(e.getMessage(), null, null);
        }
    }

    private void onMessageCenterViewFinish(MethodCall call, Result result) {
        try {
            mPushIOManager.onMessageCenterViewFinish();
            result.success(null);
        } catch (PIOMCMessageException e) {
            result.error(e.getMessage(), null, null);
        }
    }

    private void trackMessageCenterOpenEngagement(MethodCall call, Result result) {
        final String messageID = call.arguments();
        mPushIOManager.trackMessageCenterOpenEngagement(messageID);
        result.success(null);
    }

    private void trackMessageCenterDisplayEngagement(MethodCall call, Result result) {
        final String messageID = call.arguments();
        mPushIOManager.trackMessageCenterDisplayEngagement(messageID);
        result.success(null);
    }

    private void clearInAppMessages(MethodCall call, Result result) {
        mPushIOManager.clearInAppMessages();
        result.success(null);
    }

    private void clearInteractiveNotificationCategories(MethodCall call, Result result) {
        mPushIOManager.clearInteractiveNotificationCategories();
        result.success(null);
    }

    private void deleteInteractiveNotificationCategory(MethodCall call, Result result) {
        final String categoryID = call.arguments();

        mPushIOManager.deleteInteractiveNotificationCategory(categoryID);
        result.success(null);
    }

    private void getInteractiveNotificationCategory(MethodCall call, Result result) {
        final String categoryID = call.arguments();

        PIOInteractiveNotificationCategory notificationCategory = mPushIOManager.getInteractiveNotificationCategory(categoryID);

        Map<String, Object> notificationCategoryMap = PIOUtils.notificationCategoryToMap(notificationCategory);

        result.success(notificationCategoryMap);
    }

    private void addInteractiveNotificationCategory(MethodCall call, Result result) {
        final Map<String, Object>  notificationCategoryMap = call.arguments();

        PIOInteractiveNotificationCategory notificationCategory = PIOUtils.notificationCategoryFromMap(notificationCategoryMap);

        mPushIOManager.addInteractiveNotificationCategory(notificationCategory);

        result.success(null);
    }

    private void isResponsysPush(MethodCall call, Result result){
        if(call.hasArgument("rsys_src")){
            final String src = call.argument("rsys_src");
            result.success(!TextUtils.isEmpty(src) && src.equalsIgnoreCase("orcl"));
        }else{
            result.error("Invalid Message Payload", null, null);
        }
    }

    private void handleMessage(MethodCall call, Result result){
        Map<String, String> message = call.arguments();

        RemoteMessage remoteMessage = PIOUtils.remoteMessageFromMap(message);

        mPushIOManager.handleMessage(remoteMessage);
    }

    private void getExecuteRsysWebUrl(MethodCall call, Result result) {
        result.success(mPushIOManager.getExecuteRsysWebUrl());
    }

    private void getConversionUrl(MethodCall call, Result result) {
        result.success(mPushIOManager.getConversionUrl());
    }

    private void getRIAppId(MethodCall call, Result result) {
        result.success(mPushIOManager.getRIAppId());
    }

    private void getEngagementTimeStamp(MethodCall call, Result result) {
        result.success(mPushIOManager.getEngagementTimestamp());
    }

    private void getEngagementMaxAge(MethodCall call, Result result) {
        result.success(mPushIOManager.getEngagementMaxAge());
    }


    private void resetEngagementContext(MethodCall call, Result result) {
        mPushIOManager.resetEngagementContext();
        result.success(null);
    }

    private void setDelayRichPushDisplay(MethodCall call, Result result) {
        boolean isEnabled = call.arguments();
        mPushIOManager.delayRichPushDisplay(isEnabled);
        result.success(null);
    }

    private void showRichPushMessage(MethodCall call, Result result) {
        mPushIOManager.showRichPushMessage();
        result.success(null);
    }

    private void isRichPushDelaySet(MethodCall call, Result result) {
        result.success(mPushIOManager.isRichPushDelaySet());
    }

    private void trackConversionEvent(MethodCall call, final Result result) {
        Map<String, Object> conversionEventMap = call.arguments();

        mPushIOManager.trackConversionEvent(PIOUtils.conversionEventFromMap(conversionEventMap), new PIOConversionListener() {
            @Override
            public void onSuccess() {
                result.success(null);
            }

            @Override
            public void onFailure(Exception e) {
                result.error(e.getMessage(), null, null);
            }
        });
    }

    private void onGeoRegionEntered(MethodCall call, final Result result) {
        Map<String, Object> regionMap = call.arguments();

        PIOGeoRegion region = PIOUtils.geoRegionFromMap(regionMap, PIORegionEventType.GEOFENCE_ENTRY);

        mPushIOManager.onGeoRegionEntered(region, new PIORegionCompletionListener() {
            @Override
            public void onRegionReported(String regionId, PIORegionEventType regionType, PIORegionException e) {
                if(e == null){
                    Map<String, String> response = new HashMap<>();
                    response.put("regionID", regionId);
                    response.put("regionType", regionType.toString());
                    result.success(response);
                }else{
                    result.error(regionId, e.getErrorMessage(), e.getErrorDescription());
                }
            }
        });
    }

    private void onGeoRegionExited(MethodCall call, final Result result) {
        Map<String, Object> regionMap = call.arguments();

        PIOGeoRegion region = PIOUtils.geoRegionFromMap(regionMap, PIORegionEventType.GEOFENCE_EXIT);

        mPushIOManager.onGeoRegionExited(region, new PIORegionCompletionListener() {
            @Override
            public void onRegionReported(String regionId, PIORegionEventType regionType, PIORegionException e) {
                if(e == null){
                    Map<String, String> response = new HashMap<>();
                    response.put("regionID", regionId);
                    response.put("regionType", regionType.toString());
                    result.success(response);
                }else{
                    result.error(regionId, e.getErrorMessage(), e.getErrorDescription());
                }
            }
        });
    }

    private void onBeaconRegionEntered(MethodCall call, final Result result) {
        Map<String, Object> regionMap = call.arguments();

        PIOBeaconRegion region = PIOUtils.beaconRegionFromMap(regionMap, PIORegionEventType.BEACON_ENTRY);

        mPushIOManager.onBeaconRegionEntered(region, new PIORegionCompletionListener() {
            @Override
            public void onRegionReported(String regionId, PIORegionEventType regionType, PIORegionException e) {
                if(e == null){
                    Map<String, String> response = new HashMap<>();
                    response.put("regionID", regionId);
                    response.put("regionType", regionType.toString());
                    result.success(response);
                }else{
                    result.error(regionId, e.getErrorMessage(), e.getErrorDescription());
                }
            }
        });
    }

    private void onBeaconRegionExited(MethodCall call, final Result result) {
        Map<String, Object> regionMap = call.arguments();

        PIOBeaconRegion region = PIOUtils.beaconRegionFromMap(regionMap, PIORegionEventType.BEACON_EXIT);

        mPushIOManager.onBeaconRegionExited(region, new PIORegionCompletionListener() {
            @Override
            public void onRegionReported(String regionId, PIORegionEventType regionType, PIORegionException e) {
                if(e == null){
                    Map<String, String> response = new HashMap<>();
                    response.put("regionID", regionId);
                    response.put("regionType", regionType.toString());
                    result.success(response);
                }else{
                    result.error(regionId, e.getErrorMessage(), e.getErrorDescription());
                }
            }
        });
    }

    private void setExecuteRsysWebUrl(MethodCall call, Result result){
        boolean isEnabled = call.arguments();
        mPushIOManager.setExecuteRsysWebUrl(isEnabled, new PIORsysIAMHyperlinkListener() {
            @Override
            public void onSuccess(String requestUrl, String deeplinkUrl, String weblinkUrl) {
                Map<String, String> response = new HashMap<>();
                response.put("requestUrl", requestUrl);
                response.put("deeplinkUrl", deeplinkUrl);
                response.put("weblinkUrl", weblinkUrl);

                channel.invokeMethod("setIAMUrlResolveLinkHandler", response);
            }

            @Override
            public void onFailure(String requestUrl, String reason) {
                Map<String, String> response = new HashMap<>();
                response.put("requestUrl", requestUrl);
                response.put("error", reason);

                channel.invokeMethod("setIAMUrlResolveLinkHandler", response);
            }
        });
    }

    private void setInterceptDeepLink(MethodCall call, Result result){
        boolean isEnabled = call.arguments();
        PIOLogger.v("is Intercept DeepLink enabled: "+isEnabled);
        mPreferences.edit().putBoolean("handlePushDeepLink", isEnabled).commit();
        PIOLogger.v("is Intercept DeepLink enabled done: "+mPreferences.getBoolean("handlePushDeepLink", false));
    }

    private void setInterceptAppOpenLink(MethodCall call, Result result){
        boolean isEnabled = call.arguments();
        mPreferences.edit().putBoolean("handleAppOpenLink", isEnabled).commit();
    }

    private void trackEmailConversion(Intent intent) {
        mPushIOManager.trackEmailConversion(intent, new PIODeepLinkListener() {
            @Override
            public void onDeepLinkReceived(final String deeplinkUrl, final String webLinkUrl) {
                Map<String, String> response = new HashMap<>();
                response.put("deeplinkUrl", deeplinkUrl);
                response.put("weblinkUrl", webLinkUrl);

                channel.invokeMethod("setAppOpenLinkHandler", response);
            }
        });
    }

    private void setInAppMessageBannerHeight(MethodCall call, Result result) {
        PIOLogger.v("FL sIAMBH Banner Height: " + call.arguments());
        final double bannerHeight = call.arguments();
        mPushIOManager.setInAppMessageBannerHeight((int)bannerHeight);
        result.success(null);
    }

    private void getInAppMessageBannerHeight(MethodCall call, Result result) {
        final float bannerHeight = (float) mPushIOManager.getInAppMessageBannerHeight();
        result.success(bannerHeight);
    }

    private void setStatusBarHiddenForIAMBannerInterstitial(MethodCall call, Result result) {
        final boolean isStatusBarHidden = call.arguments();
        mPushIOManager.setStatusBarHiddenForIAMBannerInterstitial(isStatusBarHidden);
        result.success(null);
    }

    private void isStatusBarHiddenForIAMBannerInterstitial(MethodCall call, Result result) {
        final boolean isStatusBarHidden = mPushIOManager.isStatusBarHiddenForIAMBannerInterstitial();
        result.success(isStatusBarHidden);
    }

    private void onMessageCenterUpdate(Intent intent) {
        mPushIOManager.addMessageCenterUpdateListener(new PIOMessageCenterUpdateListener() {
            @Override
            public void onUpdate(List<String> messages) {
                channel.invokeMethod("onMessageCenterUpdate", String.join(", ", messages));
            }
        });
    }

    private void setInAppCustomCloseButton(MethodCall call, Result result){
        
        if(mActivity == null){
            PIOLogger.v("FL sIACCB No Activity found to apply the custom button");
            result.error(null, null, null);
            return;
        }

        final String customButtonAsJsonStr = call.arguments();

        if(TextUtils.isEmpty(customButtonAsJsonStr)){
            PIOLogger.v("FL sIACCB Custom button properties not found");
            result.error(null, null, null);
            return;
        }

        try {
            mPushIOManager.setInAppMessageCloseButton(mActivity, PIOUtils.getButtonFromJson(mActivity, customButtonAsJsonStr));
        } catch (Exception e) {
            PIOLogger.v("FL sIACCB "+e.getMessage());
            result.error(null, null, null);
            return;
        }

        result.success(null);
    }
}
