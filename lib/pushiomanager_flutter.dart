// Copyright © 2024, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// ignore_for_file: await_only_futures

library pushiomanager_flutter;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pushiomanager_flutter/beacon_region.dart';
import 'package:pushiomanager_flutter/conversion_event.dart';
import 'package:pushiomanager_flutter/geo_region.dart';
import 'package:pushiomanager_flutter/interactive_notification.dart';
import 'package:pushiomanager_flutter/messagecenter_message.dart';
import 'package:pushiomanager_flutter/preference.dart';
import 'package:pushiomanager_flutter/utils.dart';
import 'package:pushiomanager_flutter/custom_close_button.dart';

typedef void NotificationDeepLinkHandler(String? url);

typedef void AppOpenLinkHandler(dynamic response);
typedef void InAppMessageUrlResolveLinkHandler(Map<String, String>? response);
typedef void MessageCenterUpdateHandler(String? messageCenter);

enum PreferenceType { STRING, NUMBER, BOOLEAN }

enum EngagementType {
  LAUNCH,
  ACTIVE_SESSION,
  INAPP_PURCHASE,
  PREMIUM_CONTENT,
  SOCIAL,
  PURCHASE,
  OTHER
}

enum LogLevel { NONE, ERROR, WARN, INFO, DEBUG, VERBOSE }

class PushIOManager {
  static MethodChannel _channel = new MethodChannel('pushiomanager_flutter');
  static NotificationDeepLinkHandler? _notificationDeepLinkHandler;
  static AppOpenLinkHandler? _appOpenLinkHandler;
  static InAppMessageUrlResolveLinkHandler? _inAppMessageUrlResolveLinkHandler;
  static PushIOManager shared = new PushIOManager();
  static MessageCenterUpdateHandler? _messageCenterUpdateHandler;

  PushIOManager() {
    _channel.setMethodCallHandler(_handleNativeCallbacks);
  }

  static Future<String?> getAPIKey() async {
    final String? apiKey = await _channel.invokeMethod('getAPIKey');
    return apiKey;
  }

  static Future<String?> getAccountToken() async {
    final String? accountToken = await _channel.invokeMethod('getAccountToken');
    return accountToken;
  }

  static Future<String?> getExternalDeviceTrackingID() async {
    final String? externalDeviceTrackingID =
        await _channel.invokeMethod('getExternalDeviceTrackingID');
    return externalDeviceTrackingID;
  }

  static Future<void> setExternalDeviceTrackingID(String edti) async {
    return await _channel.invokeMethod('setExternalDeviceTrackingID', edti);
  }

  static Future<String?> getAdvertisingID() async {
    final String? advertisingID =
        await _channel.invokeMethod('getAdvertisingID');
    return advertisingID;
  }

  static Future<void> setAdvertisingID(String adid) async {
    return await _channel.invokeMethod('setAdvertisingID', adid);
  }

  static Future<String?> getRegisteredUserId() async {
    final String? userId = await _channel.invokeMethod('getRegisteredUserId');
    return userId;
  }

  static Future<void> registerUserId(String? userId) async {
    return await _channel.invokeMethod('registerUserId', userId);
  }

  static Future<void> unregisterUserId() async {
    return await _channel.invokeMethod('unregisterUserId');
  }

  static Future<void> declarePreference(
      String key, String label, PreferenceType type) async {
    return await _channel.invokeMethod('declarePreference',
        {'key': key, 'label': label, 'type': preferenceTypeToString(type)});
  }

  static Future<List<Preference>?> getPreferences() async {
    var preferences = await _channel.invokeMethod('getPreferences');

    List? preferencesList;

    if (preferences.runtimeType == String) {
      List? pref = jsonDecode(preferences);
      preferencesList = pref;
    } else {
      preferencesList = preferences;
    }

    if (preferencesList == null && preferencesList?.length == 0) {
      return null;
    }

    return preferencesList?.map((dynamic payload) {
      return Preference.fromJson(payload);
    }).toList();
  }

  static Future<Preference?> getPreference(String key) async {
    var preferenceJson = await _channel.invokeMethod('getPreference', key);
    if (preferenceJson == null) {
      return null;
    }

    Map<String, dynamic> json = jsonDecode(preferenceJson);
    return Preference.fromJson(json);
  }

  static Future<void> setStringPreference(String key, String value) async {
    return await _channel
        .invokeMethod('setStringPreference', {"key": key, "value": value});
  }

  static Future<void> setNumberPreference(String key, dynamic value) async {
    return await _channel
        .invokeMethod('setNumberPreference', {"key": key, "value": value});
  }

  static Future<void> setBooleanPreference(String key, bool value) async {
    return await _channel
        .invokeMethod('setBooleanPreference', {"key": key, "value": value});
  }

  static Future<void> removePreference(String key) async {
    return await _channel.invokeMethod('removePreference', key);
  }

  static Future<void> clearAllPreferences() async {
    return await _channel.invokeMethod('clearAllPreferences');
  }

  static Future<void> trackEvent(String eventName,
      {Map<String, String>? properties}) async {
    return await _channel.invokeMethod(
        'trackEvent', {"eventName": eventName, "properties": properties});
  }

  static Future<List<MessageCenterMessage>?> fetchMessagesForMessageCenter(
      String messageCenter) async {
    List? messages = await _channel.invokeMethod(
        'fetchMessagesForMessageCenter', messageCenter);
    if (messages == null) return null;

    return messages.map((dynamic payload) {
      return MessageCenterMessage.fromJson(payload);
    }).toList();
  }

  static Future<void> trackEngagement(EngagementType type,
      {Map<String, String>? properties}) async {
    int engagementMetric = engagementTypeToInt(type);

    if (Platform.isIOS) {
      engagementMetric =
          ((engagementMetric < 6) ? (engagementMetric - 1) : engagementMetric);
    }

    return await _channel.invokeMethod('trackEngagement',
        {"metric": engagementMetric, "properties": properties});
  }

  static Future<void> setLogLevel(LogLevel logLevel) async {
    return await _channel.invokeMethod('setLogLevel', loglevelToInt(logLevel));
  }

  static Future<void> setLoggingEnabled(bool isEnabled) async {
    return await _channel.invokeMethod('setLoggingEnabled', isEnabled);
  }

  static Future<void> overwriteApiKey(String apiKey) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('overwriteApiKey', apiKey);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> overwriteAccountToken(String accountToken) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('overwriteAccountToken', accountToken);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> setDelayRegistration(bool delayRegistration) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          'setDelayRegistration', delayRegistration);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<bool?> isDelayRegistration() async {
    if (Platform.isIOS) {
      dynamic response = await _channel.invokeMethod('isDelayRegistration');
      return response as bool?;
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> configure(String configFileName) async {
    return await _channel.invokeMethod('configure', configFileName);
  }

  static Future<void> registerApp({bool useLocation = false}) async {
    return await _channel.invokeMethod('registerApp', useLocation);
  }

  static Future<void> registerAppForPush(
      bool enablePushNotifications, bool useLocation) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('registerAppForPush', {
        'enablePushNotifications': enablePushNotifications,
        'useLocation': useLocation
      });
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> registerForAllRemoteNotificationTypes() async {
    if (Platform.isIOS) {
      return await _channel
          .invokeMethod('registerForAllRemoteNotificationTypes');
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> registerForAllRemoteNotificationTypesWithCategories(
      List<InteractiveNotificationCategory>? categories) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          'registerForAllRemoteNotificationTypesWithCategories',
          categories?.map((e) => e.toJson()).toList());
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> registerForNotificationAuthorizations(
      int authOptions, List<InteractiveNotificationCategory> categories) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          'registerForNotificationAuthorizations',
          {"authOptions": authOptions, "categories": categories});
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> unregisterApp() async {
    return await _channel.invokeMethod('unregisterApp');
  }

  static Future<String?> getDeviceID() async {
    return await _channel.invokeMethod('getDeviceID');
  }

  static Future<String?> getLibVersion() async {
    return await _channel.invokeMethod('getLibVersion');
  }

  static Future<void> setDefaultSmallIcon(int resourceId) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('setDefaultSmallIcon', resourceId);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> setDefaultLargeIcon(int resourceId) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('setDefaultLargeIcon', resourceId);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> setNotificationSmallIcon(String resourceName) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(
          'setNotificationSmallIcon', resourceName);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> setNotificationLargeIcon(String resourceName) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(
          'setNotificationLargeIcon', resourceName);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<bool> isMessageCenterEnabled() async {
    dynamic response = await _channel.invokeMethod('isMessageCenterEnabled');
    return response as bool;
  }

  static Future<void> setMessageCenterEnabled(bool isEnabled) async {
    return await _channel.invokeMethod('setMessageCenterEnabled', isEnabled);
  }

  static Future<Map<String, String>> fetchRichContentForMessage(
      String messageID) async {
    Map<dynamic, dynamic> response =
        await (_channel.invokeMethod('fetchRichContentForMessage', messageID));
    return response.cast<String, String>();
  }

  static Future<void> setInAppFetchEnabled(bool isEnabled) async {
    return await _channel.invokeMethod('setInAppFetchEnabled', isEnabled);
  }

  static Future<void> setCrashLoggingEnabled(bool isEnabled) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('setCrashLoggingEnabled', isEnabled);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<bool?> isCrashLoggingEnabled() async {
    if (Platform.isAndroid) {
      dynamic response = await _channel.invokeMethod('isCrashLoggingEnabled');
      return response as bool?;
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> setDeviceToken(String deviceToken) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('setDeviceToken', deviceToken);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> setMessageCenterBadgingEnabled(bool isEnabled) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(
          'setMessageCenterBadgingEnabled', isEnabled);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> setBadgeCount(int badgeCount,
      {bool forceSetBadge: false}) async {
    return await _channel.invokeMethod('setBadgeCount',
        {'badgeCount': badgeCount, 'forceSetBadge': forceSetBadge});
  }

  static Future<int?> getBadgeCount() async {
    dynamic response = await _channel.invokeMethod('getBadgeCount');
    return response as int?;
  }

  static Future<void> resetBadgeCount({bool forceSetBadge: false}) async {
    return await _channel
        .invokeMethod('resetBadgeCount', {'forceSetBadge': forceSetBadge});
  }

  static Future<void> resetMessageCenter() async {
    return await _channel.invokeMethod('resetMessageCenter');
  }

  static Future<void> onMessageCenterViewVisible() async {
    return await _channel.invokeMethod('onMessageCenterViewVisible');
  }

  static Future<void> onMessageCenterViewFinish() async {
    return await _channel.invokeMethod('onMessageCenterViewFinish');
  }

  static Future<void> trackMessageCenterOpenEngagement(String messageID) async {
    return await _channel.invokeMethod(
        'trackMessageCenterOpenEngagement', messageID);
  }

  static Future<void> trackMessageCenterDisplayEngagement(
      String messageID) async {
    return await _channel.invokeMethod(
        'trackMessageCenterDisplayEngagement', messageID);
  }

  static Future<void> clearInAppMessages() async {
    return await _channel.invokeMethod('clearInAppMessages');
  }

  static Future<void> clearInteractiveNotificationCategories() async {
    if (Platform.isAndroid) {
      return await _channel
          .invokeMethod('clearInteractiveNotificationCategories');
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> deleteInteractiveNotificationCategory(
      String categoryID) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(
          'deleteInteractiveNotificationCategory', categoryID);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<InteractiveNotificationCategory>
      getInteractiveNotificationCategory(String categoryID) async {
    if (Platform.isAndroid) {
      dynamic response = await _channel.invokeMethod(
          'getInteractiveNotificationCategory', categoryID);
      return InteractiveNotificationCategory.fromJson(
          response.cast<String, dynamic>());
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<void> addInteractiveNotificationCategory(
      InteractiveNotificationCategory notificationCategory) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(
          'addInteractiveNotificationCategory', notificationCategory.toJson());
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<bool?> isResponsysPush(
      Map<String, dynamic> notification) async {
    dynamic response =
        await _channel.invokeMethod('isResponsysPush', notification);
    return response as bool?;
  }

  static Future<void> handleMessage(Map<String, dynamic> notification) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('handleMessage', notification);
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<Map<String, String>> onGeoRegionEntered(
      GeoRegion region) async {
    Map<dynamic, dynamic> response =
        await _channel.invokeMethod('onGeoRegionEntered', region.toJson());
    return response.cast<String, String>();
  }

  static Future<Map<String, String>> onGeoRegionExited(GeoRegion region) async {
    Map<dynamic, dynamic> response =
        await _channel.invokeMethod('onGeoRegionExited', region.toJson());
    return response.cast<String, String>();
  }

  static Future<Map<String, String>> onBeaconRegionEntered(
      BeaconRegion region) async {
    Map<dynamic, dynamic> response =
        await _channel.invokeMethod('onBeaconRegionEntered', region.toJson());
    return response.cast<String, String>();
  }

  static Future<Map<String, String>> onBeaconRegionExited(
      BeaconRegion region) async {
    Map<dynamic, dynamic> response =
        await (_channel.invokeMethod('onBeaconRegionExited', region.toJson()));
    return response.cast<String, String>();
  }

  static Future<bool?> getExecuteRsysWebUrl() async {
    dynamic response = await _channel.invokeMethod('getExecuteRsysWebUrl');
    return response as bool?;
  }

  static Future<String?> getConversionUrl() async {
    if (Platform.isAndroid) {
      dynamic response = await _channel.invokeMethod('getConversionUrl');
      return response as String?;
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<String?> getRIAppId() async {
    if (Platform.isAndroid) {
      dynamic response = await _channel.invokeMethod('getRIAppId');
      return response as String?;
    } else {
      throw PlatformException(code: "API not supported");
    }
  }

  static Future<String?> getEngagementTimeStamp() async {
    dynamic response = await _channel.invokeMethod('getEngagementTimeStamp');
    return response as String?;
  }

  static Future<int?> getEngagementMaxAge() async {
    dynamic response = await _channel.invokeMethod('getEngagementMaxAge');
    return response.toInt();
  }

  static Future<void> resetEngagementContext() async {
    return await _channel.invokeMethod('resetEngagementContext');
  }

  static Future<void> setDelayRichPushDisplay(bool isEnabled) async {
    return await _channel.invokeMethod('setDelayRichPushDisplay', isEnabled);
  }

  static Future<void> showRichPushMessage() async {
    return await _channel.invokeMethod('showRichPushMessage');
  }

  static Future<bool?> isRichPushDelaySet() async {
    dynamic response = await _channel.invokeMethod('isRichPushDelaySet');
    return response as bool?;
  }

  static Future<void> trackConversionEvent(ConversionEvent event) async {
    return await _channel.invokeMethod('trackConversionEvent', event.toJson());
  }

  static Future<void> setExecuteRsysWebUrl(bool booleanValue) async {
    return await _channel.invokeMethod('setExecuteRsysWebUrl', booleanValue);
  }

  static Future<void> setInterceptDeepLink(bool booleanValue) async {
    return await _channel.invokeMethod('setInterceptDeepLink', booleanValue);
  }

  static void setIAMUrlResolveLinkHandler(
      InAppMessageUrlResolveLinkHandler handler) {
    if (shared == null) {
      shared = PushIOManager();
    }
    _inAppMessageUrlResolveLinkHandler = handler;
  }

  static void setNotificationDeepLinkHandler(
      NotificationDeepLinkHandler handler) {
    if (shared == null) {
      shared = PushIOManager();
    }
    _notificationDeepLinkHandler = handler;
  }

  static void setAppOpenLinkHandler(AppOpenLinkHandler handler) {
    if (shared == null) {
      shared = PushIOManager();
    }
    _appOpenLinkHandler = handler;
  }

  Future<void> _handleNativeCallbacks(MethodCall call) async {
    if (call.method == 'setIAMUrlResolveLinkHandler') {
      if (_inAppMessageUrlResolveLinkHandler != null) {
        _inAppMessageUrlResolveLinkHandler!(
            call.arguments.cast<String, String>());
      }
    } else if (call.method == 'setNotificationDeepLinkHandler') {
      if (_notificationDeepLinkHandler != null) {
        _notificationDeepLinkHandler!(call.arguments as String?);
      }
    } else if (call.method == 'setAppOpenLinkHandler') {
      if (_appOpenLinkHandler != null) {
        if (Platform.isAndroid) {
          _appOpenLinkHandler!(call.arguments.cast<String, String>());
        } else {
          _appOpenLinkHandler!(call.arguments['link'] as String?);
        }
      }
    } else if (call.method == 'onMessageCenterUpdate') {
      if (_messageCenterUpdateHandler != null) {
        _messageCenterUpdateHandler!(call.arguments as String?);
      }
    }
  }

  static Future<void> setInAppMessageBannerHeight(double height) async {
    return await _channel.invokeMethod('setInAppMessageBannerHeight', height);
  }

  static Future<double?> getInAppMessageBannerHeight() async {
    dynamic response =
        await _channel.invokeMethod('getInAppMessageBannerHeight');
    return response as double?;
  }

  static Future<void> setStatusBarHiddenForIAMBannerInterstitial(
      bool statusbarHidden) async {
    return await _channel.invokeMethod(
        'setStatusBarHiddenForIAMBannerInterstitial', statusbarHidden);
  }

  static Future<bool?> isStatusBarHiddenForIAMBannerInterstitial() async {
    dynamic response = await _channel
        .invokeMethod('isStatusBarHiddenForIAMBannerInterstitial');
    return response as bool?;
  }

  static void onMessageCenterUpdate(MessageCenterUpdateHandler handler) {
    if (shared == null) {
      shared = PushIOManager();
    }
    _messageCenterUpdateHandler = handler;
  }

  static Future<void> setInAppCustomCloseButton(
      PIOInAppCloseButton customCloseButton) async {
    return await _channel.invokeMethod(
        'setInAppCustomCloseButton', customCloseButton.toJson());
  }
}
