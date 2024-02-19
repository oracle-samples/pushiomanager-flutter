/**
* Copyright © 2024, Oracle and/or its affiliates. All rights reserved.
*
* Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
*/

#import "PushIOManagerFlutterPlugin.h"
#import <PushIOManager/PushIOManagerAll.h>
#import "NSDictionary+PIOConvert.h"
#import "NSArray+PIOConvert.h"
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

@interface PushIOManagerFlutterPlugin ()<PIODeepLinkDelegate>
@property (strong, nonatomic) FlutterMethodChannel *channel;
@end


@implementation PushIOManagerFlutterPlugin
+ (instancetype)sharedInstance {
static PushIOManagerFlutterPlugin *sharedInstance = nil;
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    sharedInstance = [PushIOManagerFlutterPlugin new];
    [sharedInstance setUpDeeplinkHandler];
});
return sharedInstance;
}

-(void) setUpDeeplinkHandler {
    
   BOOL isDeepLinkHandlerSet=  [[NSUserDefaults standardUserDefaults] boolForKey:@"PIODeeplinkHandler"];
    if(isDeepLinkHandlerSet) {
        [[PushIOManager sharedInstance] setDeeplinkDelegate:self];
    }
}
    
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* flutterChannel = [FlutterMethodChannel
                                     methodChannelWithName:@"pushiomanager_flutter"
                                     binaryMessenger:[registrar messenger]];
    
    PushIOManagerFlutterPlugin* instance = [PushIOManagerFlutterPlugin sharedInstance];
    [registrar addMethodCallDelegate:instance channel:flutterChannel];

    [registrar addApplicationDelegate:instance];
    instance.channel = flutterChannel;
    
    if ([UNUserNotificationCenter currentNotificationCenter].delegate == nil) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = instance;
    }
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(onDeepLinkReceived:) name:PIORsysWebURLResolvedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(onMessageCenterUpdate:) name:PIOMessageCenterUpdateNotification object:nil];
    [instance setup];
}

- (void)setup {

    [PushIOManager sharedInstance].notificationPresentationOptions = UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound;


}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"setDelayRegistration" isEqualToString:call.method]) {
        [self setDelayRegistration:call withResult:result];
    }else if ([@"isDelayRegistration" isEqualToString:call.method]) {
       [self isDelayRegistration:call withResult:result];
   } else if ([@"configure" isEqualToString:call.method]) {
        [self configure:call withResult:result];
    } else if ([@"registerForAllRemoteNotificationTypes" isEqualToString:call.method]) {
        [self registerForAllRemoteNotificationTypes:call withResult:result];
    } else if ([@"registerApp" isEqualToString:call.method]) {
        [self registerApp:call withResult:result];
    } else if ([@"registerUserId" isEqualToString:call.method]) {
        [self registerUserId:call withResult:result];
    } else if ([@"setLogLevel" isEqualToString:call.method]) {
        [self setLogLevel:call withResult:result];
    } else if ([@"registerForAllRemoteNotificationTypesWithCategories" isEqualToString:call.method]) {
        [self registerForAllRemoteNotificationTypesWithCategories:call withResult:result];
        } else if ([@"registerForNotificationAuthorizations" isEqualToString:call.method]) {
            [self registerForNotificationAuthorizations:call withResult:result];
        } else if ([@"unregisterApp" isEqualToString:call.method]) {
        [self unregisterApp:call withResult:result];
    } else if ([@"trackEngagement" isEqualToString:call.method]) {
        [self trackEngagement:call withResult:result];
    } else if ([@"resetEngagementContext" isEqualToString:call.method]) {
        [self resetEngagementContext:call withResult:result];
    } else if ([@"setMessageCenterEnabled" isEqualToString:call.method]) {
        [self setMessageCenterEnabled:call withResult:result];
    } else if ([@"isMessageCenterEnabled" isEqualToString:call.method]) {
        [self isMessageCenterEnabled:call withResult:result];
    } else if ([@"fetchMessagesForMessageCenter" isEqualToString:call.method]) {
        [self fetchMessagesForMessageCenter:call withResult:result];
    } else if ([@"fetchRichContentForMessage" isEqualToString:call.method]) {
        [self fetchRichContentForMessage:call withResult:result];
    } else if ([@"setInAppFetchEnabled" isEqualToString:call.method]) {
        [self setInAppFetchEnabled:call withResult:result];
    } else if ([@"getAPIKey" isEqualToString:call.method]) {
        [self getAPIKey:call withResult:result];
    } else if ([@"getAccountToken" isEqualToString:call.method]) {
        [self getAccountToken:call withResult:result];
    } else if ([@"getDeviceID" isEqualToString:call.method]) {
        [self getDeviceID:call withResult:result];
    } else if ([@"getEngagementMaxAge" isEqualToString:call.method]) {
        [self getEngagementMaxAge:call withResult:result];
    } else if ([@"getEngagementTimeStamp" isEqualToString:call.method]) {
        [self getEngagementTimeStamp:call withResult:result];
    } else if ([@"getPreferences" isEqualToString:call.method]) {
        [self getPreferences:call withResult:result];
    } else if ([@"getPreference" isEqualToString:call.method]) {
        [self getPreference:call withResult:result];
    } else if ([@"trackEvent" isEqualToString:call.method]) {
        [self trackEvent:call withResult:result];
    } else if ([@"trackConversionEvent" isEqualToString:call.method]) {
        [self trackConversionEvent:call withResult:result];
    } else if ([@"declarePreference" isEqualToString:call.method]) {
        [self declarePreference:call withResult:result];
    } else if ([@"setBooleanPreference" isEqualToString:call.method]) {
        [self setBooleanPreference:call withResult:result];
    } else if ([@"setStringPreference" isEqualToString:call.method]) {
        [self setStringPreference:call withResult:result];
    } else if ([@"setNumberPreference" isEqualToString:call.method]) {
        [self setNumberPreference:call withResult:result];
    } else if ([@"removePreference" isEqualToString:call.method]) {
        [self removePreference:call withResult:result];
    } else if ([@"clearAllPreferences" isEqualToString:call.method]) {
        [self clearAllPreferences:call withResult:result];
    } else if ([@"setBadgeCount" isEqualToString:call.method]) {
        [self setBadgeCount:call withResult:result];
    } else if ([@"resetBadgeCount" isEqualToString:call.method]) {
        [self resetBadgeCount:call withResult:result];
    } else if ([@"getBadgeCount" isEqualToString:call.method]) {
        [self getBadgeCount:call withResult:result];
    } else if ([@"clearInAppMessages" isEqualToString:call.method]) {
        [self clearInAppMessages:call withResult:result];
    } else if ([@"resetMessageCenter" isEqualToString:call.method]) {
        [self resetMessageCenter:call withResult:result];
    } else if ([@"trackMessageCenterOpenEngagement" isEqualToString:call.method]) {
        [self trackMessageCenterOpenEngagement:call withResult:result];
    } else if ([@"trackMessageCenterDisplayEngagement" isEqualToString:call.method]) {
        [self trackMessageCenterDisplayEngagement:call withResult:result];
    } else if ([@"onMessageCenterViewVisible" isEqualToString:call.method]) {
        [self onMessageCenterViewVisible:call withResult:result];
    } else if ([@"onMessageCenterViewFinish" isEqualToString:call.method]) {
        [self onMessageCenterViewFinish:call withResult:result];
    } else if ([@"clearInteractiveNotificationCategories" isEqualToString:call.method]) {
        [self clearInteractiveNotificationCategories:call withResult:result];
    } else if ([@"deleteInteractiveNotificationCategory" isEqualToString:call.method]) {
        [self deleteInteractiveNotificationCategory:call withResult:result];
    } else if ([@"getInteractiveNotificationCategory" isEqualToString:call.method]) {
        [self getInteractiveNotificationCategory:call withResult:result];
    } else if ([@"addInteractiveNotificationCategory" isEqualToString:call.method]) {
        [self addInteractiveNotificationCategory:call withResult:result];
    } else if ([@"isSDKConfigured" isEqualToString:call.method]) {
        [self isSDKConfigured:call withResult:result];
    } else if ([@"setCrashLoggingEnabled" isEqualToString:call.method]) {
        [self setCrashLoggingEnabled:call withResult:result];
    } else if ([@"isCrashLoggingEnabled" isEqualToString:call.method]) {
        [self isCrashLoggingEnabled:call withResult:result];
    } else if ([@"setLoggingEnabled" isEqualToString:call.method]) {
        [self setLoggingEnabled:call withResult:result];
    } else if ([@"isLoggingEnabled" isEqualToString:call.method]) {
        [self isLoggingEnabled:call withResult:result];
    } else if ([@"getRegisteredUserId" isEqualToString:call.method]) {
        [self getRegisteredUserId:call withResult:result];
    } else if ([@"unregisterUserId" isEqualToString:call.method]) {
        [self unregisterUserId:call withResult:result];
    } else if ([@"frameworkVersion" isEqualToString:call.method]) {
        [self frameworkVersion:call withResult:result];
    } else if ([@"setExternalDeviceTrackingID" isEqualToString:call.method]) {
        [self setExternalDeviceTrackingID:call withResult:result];
    } else if ([@"getExternalDeviceTrackingID" isEqualToString:call.method]) {
        [self getExternalDeviceTrackingID:call withResult:result];
    } else if ([@"setAdvertisingID" isEqualToString:call.method]) {
        [self setAdvertisingID:call withResult:result];
    } else if ([@"getAdvertisingID" isEqualToString:call.method]) {
        [self getAdvertisingID:call withResult:result];
    } else if ([@"setExecuteRsysWebUrl" isEqualToString:call.method]) {
        [self setExecuteRsysWebUrl:call withResult:result];
    } else if ([@"getExecuteRsysWebUrl" isEqualToString:call.method]) {
        [self getExecuteRsysWebUrl:call withResult:result];
    } else if ([@"setConfigType" isEqualToString:call.method]) {
        [self setConfigType:call withResult:result];
    } else if ([@"configType" isEqualToString:call.method]) {
        [self configType:call withResult:result];
    } else if ([@"resetAllData" isEqualToString:call.method]) {
        [self resetAllData:call withResult:result];
    } else if ([@"isResponsysPush" isEqualToString:call.method]) {
        [self isResponsysPush:call withResult:result];
    } else if ([@"onGeoRegionEntered" isEqualToString:call.method]) {
        [self onGeoRegionEntered:call withResult:result];
    } else if ([@"onGeoRegionExited" isEqualToString:call.method]) {
        [self onGeoRegionExited:call withResult:result];
    } else if ([@"onBeaconRegionEntered" isEqualToString:call.method]) {
        [self onBeaconRegionEntered:call withResult:result];
    } else if ([@"onBeaconRegionExited" isEqualToString:call.method]) {
        [self onBeaconRegionExited:call withResult:result];
    } else if ([@"handleMessage" isEqualToString:call.method]) {
        [self handleMessage:call withResult:result];
    } else if ([@"frameworkVersion" isEqualToString:call.method]) {
        [self frameworkVersion:call withResult:result];
    } else if ([@"getLibVersion" isEqualToString:call.method]) {
        [self getLibVersion:call withResult:result];
    } else if ([@"setInterceptDeepLink" isEqualToString:call.method]) {
        [self setInterceptDeepLink:call withResult:result];
    }else if ([@"setDelayRichPushDisplay" isEqualToString:call.method]) {
        [self setDelayRichPushDisplay:call withResult:result];
    }else if ([@"showRichPushMessage" isEqualToString:call.method]) {
        [self showRichPushMessage:call withResult:result];
    }else if ([@"isRichPushDelaySet" isEqualToString:call.method]) {
        [self isRichPushDelaySet:call withResult:result];
    }else if ([@"setInAppMessageBannerHeight" isEqualToString:call.method]) {
        [self setInAppMessageBannerHeight:call withResult:result];
    }else if ([@"getInAppMessageBannerHeight" isEqualToString:call.method]) {
        [self getInAppMessageBannerHeight:call withResult:result];
    }else if ([@"setStatusBarHiddenForIAMBannerInterstitial" isEqualToString:call.method]) {
        [self setStatusBarHiddenForIAMBannerInterstitial:call withResult:result];
    }else if ([@"isStatusBarHiddenForIAMBannerInterstitial" isEqualToString:call.method]) {
        [self isStatusBarHiddenForIAMBannerInterstitial:call withResult:result];
    }else if ([@"setInAppCustomCloseButton" isEqualToString:call.method]) {
        [self setInAppCustomCloseButton:call withResult:result];
    }
     else {
        result(FlutterMethodNotImplemented);
    }
}

-(void)setDelayRegistration:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    BOOL delayRegistration = [value boolValue];
    [[PushIOManager sharedInstance] setDelayRegistration:delayRegistration];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)isDelayRegistration:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL isDelayRegistration = [[PushIOManager sharedInstance] delayRegistration];
    result(@(isDelayRegistration));
}

- (void)registerApp:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSError *error;
    [[PushIOManager sharedInstance] registerApp:&error completionHandler:^(NSError *error, NSString *response) {
        [self sendPluginResult:result withResponse:response andError:error];
    }];
}

- (void)registerForAllRemoteNotificationTypes:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[PushIOManager sharedInstance] registerForAllRemoteNotificationTypes:^(NSError *error, NSString *response) {
        [self sendPluginResult:result withResponse:response andError:error];
    }];
}

- (void)registerForAllRemoteNotificationTypesWithCategories:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSArray *categories = call.arguments;
    if (categories == (id)[NSNull null]) {
        categories = nil;
    }
    [[PushIOManager sharedInstance] registerForAllRemoteNotificationTypesWithCategories:[categories notificationCategoryArray] completionHandler:^(NSError *error, NSString *response) {
        [self sendPluginResult:result withResponse:response andError:error];
        
    }];
}



- (void)registerUserId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString* userId = call.arguments;
    if (userId == (id)[NSNull null]) {
        userId = nil;
    }
    NSLog(@"setting user id %@", userId);
    [[PushIOManager sharedInstance] registerUserID:userId];
    [self sendPluginResult:result withResponse:nil andError:nil];
}


- (void)registerForNotificationAuthorizations:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments[@"authOptions"];
    if (value == (id)[NSNull null]) {
        value = nil;
    }

    NSInteger authOptions = [value integerValue];
    NSArray *categories = call.arguments[@"categories"];
    if (categories == (id)[NSNull null]) {
        categories = nil;
    }

    [[PushIOManager sharedInstance] registerForNotificationAuthorizations:authOptions categories:[categories notificationCategoryArray] completionHandler:^(NSError *error, NSString *response) {
        [self sendPluginResult:result withResponse:response andError:error];
    }];
}

- (void)setLogLevel:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    NSInteger logLevel = [value integerValue];
    [[PushIOManager sharedInstance] setLogLevel:logLevel];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

- (void)configure:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString* filename = call.arguments;
    if (filename == (id)[NSNull null]) {
        filename = nil;
    }

    NSLog(@"configureWithFilename %@", filename);
    [[PushIOManager sharedInstance] configureWithFileName:filename completionHandler:^(NSError *error, NSString *response) {
        [self sendPluginResult:result withResponse:response andError:error];
    }];
}


- (void)configureAndRegister:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString* filename = call.arguments[@"filename"];
    if (filename == (id)[NSNull null]) {
        filename = nil;
    }

    NSLog(@"configureWithFilename %@", filename);
    [[PushIOManager sharedInstance] configureWithFileName:filename completionHandler:^(NSError *configError, NSString *response) {
        if(configError != nil) {
            NSLog(@"Unable to configure SDK, reason: %@", configError.description);
            [self sendPluginResult:result withResponse:response andError:configError];

            return;
        }
                
        //5. Register with APNS and request for push permissions
        [[PushIOManager sharedInstance] registerForAllRemoteNotificationTypes:^(NSError *error, NSString *deviceToken) {
            if (nil == error) {

                //Configure other SDK APIs here, if needed eg: [[PushIOManager sharedInstance] registerUserID:@"A1B2C3D4"];
                
                //6. Register application with Responsys server. This API is responsible to send registration signal to Responsys server. This API sends all the values configured on SDK to server.
                NSError *regTrackError = nil;
                [[PushIOManager sharedInstance] registerApp:&regTrackError completionHandler:^(NSError *regAppError, NSString *response) {
                    if (nil == regAppError) {
                        NSLog(@"Application registered successfully!");
                    } else {
                        NSLog(@"Unable to register application, reason: %@", regAppError.description);
                    }
                    [self sendPluginResult:result withResponse:deviceToken andError:regAppError];
                }];
                if (nil == regTrackError) {
                    NSLog(@"Registration locally stored successfully.");
                } else {
                    NSLog(@"Unable to store registration, reason: %@", regTrackError.description);
                }
            } else {
                [self sendPluginResult:result withResponse:deviceToken andError:error];

            }
        }];
    }];
}
                                        
-(void)unregisterApp:(FlutterMethodCall *)call withResult:(FlutterResult)result {

  [[PushIOManager sharedInstance] unregisterApp:nil completionHandler:^(NSError *error, NSString *response) {
    NSLog(@"React unregisterApp %@",(response ?: @"success"));
    [self sendPluginResult:result withResponse:response andError:error];
  }];
}

-(void)trackEngagement:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments[@"metric"];
    if (value == (id)[NSNull null]) {
        value = nil;
    }
  int metric = [value intValue];
  NSDictionary *properties = call.arguments[@"properties"];
    if (properties == (id)[NSNull null]) {
        properties = nil;
    }

  [[PushIOManager sharedInstance] trackEngagementMetric:(int)metric withProperties:properties completionHandler:^(NSError *error, NSString *response) {
    [self sendPluginResult:result withResponse:response andError:error];
  }];
}

-(void)resetEngagementContext:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[PushIOManager sharedInstance] resetEngagementContext];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)setMessageCenterEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    BOOL isMessageCenterEnable = [value boolValue];
    [[PushIOManager sharedInstance] setMessageCenterEnabled:isMessageCenterEnable];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)isMessageCenterEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL isMessageCenterEnable = [[PushIOManager sharedInstance] isMessageCenterEnabled];
    result(@(isMessageCenterEnable));
}

-(void)fetchMessagesForMessageCenter:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString* messageCenter = call.arguments;
    if (messageCenter == (id)[NSNull null]) {
        messageCenter = nil;
    }

    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionary];
    responseDictionary[@"messageCenter"] = messageCenter;

    [[PushIOManager sharedInstance] fetchMessagesForMessageCenter:messageCenter CompletionHandler:^(NSError *error, NSArray *messages) {
        result([messages messageDictionary]);
    }];
}


-(void)fetchRichContentForMessage:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString* messageID = call.arguments;
    if (messageID == (id)[NSNull null]) {
        messageID = nil;
    }

  [[PushIOManager sharedInstance] fetchRichContentForMessage:messageID CompletionHandler:^(NSError *error, NSString *messageID, NSString *richContent) {
      
      if (error) {
          result([self flutterError:error]);
          return;
      }
      NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionary];
      responseDictionary[@"richContent"] = richContent;
      responseDictionary[@"messageID"] = messageID;
      result(responseDictionary);
  }];
}

-(void)setInAppFetchEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    BOOL enableInAppMessageFetch = [value boolValue];
    [[PushIOManager sharedInstance] setInAppMessageFetchEnabled:enableInAppMessageFetch];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)getAPIKey:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *apiKey = [[PushIOManager sharedInstance] getAPIKey];
    [self sendPluginResult:result withResponse:apiKey andError:nil];
}

-(void)getAccountToken:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *accountToken = [[PushIOManager sharedInstance] getAccountToken];
    [self sendPluginResult:result withResponse:accountToken andError:nil];
}


                              
-(void)getDeviceID:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *deviceID = [[PushIOManager sharedInstance] getDeviceID];
    [self sendPluginResult:result withResponse:deviceID andError:nil];
}


-(void)getEngagementMaxAge:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  double engagementAge = [[PushIOManager sharedInstance] getEngagementMaxAge];
    result(@(engagementAge));
}

-(void)getEngagementTimeStamp:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  NSString *engagementTimeStamp = [[PushIOManager sharedInstance] getEngagementTimeStamp];
  [self sendPluginResult:result withResponse:engagementTimeStamp andError:nil];
}


-(void)getPreferences:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *preference = [[[[PushIOManager sharedInstance] getPreferences] preferencesDictionary] JSON];
    result(preference);
}

-(void)getPreference:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString* key = call.arguments;
    if (key == (id)[NSNull null]) {
        key = nil;
    }

    PIOPreference *preference = [[PushIOManager sharedInstance] getPreference:key];
    NSDictionary *jsonDictionary = [NSDictionary dictionaryFromPreference:preference];
    if(jsonDictionary) {
    NSString *prefrenceJSON = [jsonDictionary JSON];
       [self sendPluginResult:result withResponse:prefrenceJSON andError:nil];
    } else {
        [self sendPluginResult:result withResponse:nil andError:nil];
    }
}


-(void)trackEvent:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString* eventName = call.arguments[@"eventName"];
    NSDictionary *properties = call.arguments[@"properties"];
    if (eventName == (id)[NSNull null]) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%i", (int)00] message:@"Eventname can not be null" details:nil]);

        return;
    }

    if (properties == (id)[NSNull null]) {
        properties = nil;
    }
    [[PushIOManager sharedInstance] trackEvent:eventName properties:properties];
    [self sendPluginResult:result withResponse:nil andError:nil];
}


-(void)trackConversionEvent:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *event = call.arguments;
    if (event == (id)[NSNull null]) {
        event = nil;
    }

    [[PushIOManager sharedInstance] trackConversionEvent:[event conversionEvent] completionHandler:^(NSError *error, NSString *response) {
        [self sendPluginResult:result withResponse:response andError:error];

    }];
}


-(void)declarePreference:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString* key = call.arguments[@"key"];
    NSString *label = call.arguments[@"label"];
    if (key == (id)[NSNull null]) {
        key = nil;
    }
    if (label == (id)[NSNull null]) {
        label = nil;
    }
    id value = call.arguments[@"type"];
    if (value == (id)[NSNull null]) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%i", (int)00] message:@"Preference type can't be NULL. Should be \"STRING\" or \"NUMBER\" or \"BOOLEAN\"" details:nil]);
        return;
    }

    int type = ([value isEqualToString:@"STRING"] ? PIOPreferenceTypeString : ([value isEqualToString:@"NUMBER"] ? PIOPreferenceTypeNumeric : PIOPreferenceTypeBoolean)) ;
    NSError *error = nil;
    [[PushIOManager sharedInstance] declarePreference:key label:label type:type error:&error];
    [self sendPluginResult:result withResponse:nil andError:error];
}

                                        
-(void)setBooleanPreference:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments[@"value"];
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    NSString *key = call.arguments[@"key"];
    if (key == (id)[NSNull null]) {
        key = nil;
    }


  [[PushIOManager sharedInstance] setBoolPreference:[value boolValue] forKey:key];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)setStringPreference:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *value = call.arguments[@"value"];
    NSString *key = call.arguments[@"key"];
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    if (key == (id)[NSNull null]) {
        key = nil;
    }

  [[PushIOManager sharedInstance] setStringPreference:value forKey:key];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)setNumberPreference:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSNumber *value = call.arguments[@"value"];
    NSString *key = call.arguments[@"key"];
    if (key == (id)[NSNull null]) {
        key = nil;
    }
    
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    [[PushIOManager sharedInstance] setNumberPreference:value forKey:key];
    [self sendPluginResult:result withResponse:nil andError:nil];

}

-(void)removePreference:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *key = call.arguments;
    if (key == (id)[NSNull null]) {
        key = nil;
    }
    NSError *error = nil;
    [[PushIOManager sharedInstance] removePreference:key error:&error];
    [self sendPluginResult:result withResponse:nil andError:error];
}

-(void)clearAllPreferences:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[PushIOManager sharedInstance] clearAllPreferences];
    [self sendPluginResult:result withResponse:nil andError:nil];

}
                                   
                                       


-(void)setBadgeCount:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSNumber* badgeCount = call.arguments[@"badgeCount"];
    if (badgeCount == (id)[NSNull null]) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%i", (int)00] message:@"Badge Count can't be empty" details:nil]);
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[PushIOManager sharedInstance] setBadgeCount:[badgeCount integerValue] completionHandler:^(NSError *error, NSString *response) {
          [self sendPluginResult:result withResponse:response andError:error];
        }];
    });
}

-(void)resetBadgeCount:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PushIOManager sharedInstance] resetBadgeCountWithCompletionHandler:^(NSError *error, NSString *response) {
            [self sendPluginResult:result withResponse:response andError:error];
        }];
    });
}

-(void)getBadgeCount:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  dispatch_async(dispatch_get_main_queue(), ^{
      NSInteger badgeCount = [[PushIOManager sharedInstance] getBadgeCount];
      result(@(badgeCount));
  });
}


-(void)clearInAppMessages:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[PushIOManager sharedInstance] clearInAppMessages];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)resetMessageCenter:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[PushIOManager sharedInstance] clearMessageCenterMessages];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)trackMessageCenterOpenEngagement:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *messageId = call.arguments;
    if (messageId == (id)[NSNull null]) {
        messageId = nil;
    }

  [[PushIOManager sharedInstance] trackMessageCenterOpenEngagement:messageId];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)trackMessageCenterDisplayEngagement:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *messageId = call.arguments;
    if (messageId == (id)[NSNull null]) {
        messageId = nil;
    }

  [[PushIOManager sharedInstance] trackMessageCenterDisplayEngagement:messageId];
    [self sendPluginResult:result withResponse:nil andError:nil];

}

-(void)onMessageCenterViewVisible:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  [[PushIOManager sharedInstance] messageCenterViewWillAppear];
    [self sendPluginResult:result withResponse:nil andError:nil];

}

-(void)onMessageCenterViewFinish:(FlutterMethodCall *)call withResult:(FlutterResult)result {
  [[PushIOManager sharedInstance] messageCenterViewWillDisappear];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)clearInteractiveNotificationCategories:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)deleteInteractiveNotificationCategory:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [self sendPluginResult:result withResponse:nil andError:nil];
}
-(void)getInteractiveNotificationCategory:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [self sendPluginResult:result withResponse:nil andError:nil];
}
-(void)addInteractiveNotificationCategory:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [self sendPluginResult:result withResponse:nil andError:nil];
}
                                         
                                             

                                         
-(void)isSDKConfigured:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL isSDKConfigured = [[PushIOManager sharedInstance] isSDKConfigured];
    result(@(isSDKConfigured));
}

-(void)setCrashLoggingEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    BOOL enableCrashLogging = [value boolValue];
    [[PushIOManager sharedInstance] setCrashLoggingEnabled:enableCrashLogging];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)isCrashLoggingEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL isCrashLoggingEnabled = [[PushIOManager sharedInstance] isCrashLoggingEnabled];
    result(@(isCrashLoggingEnabled));
}

-(void)setLoggingEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    BOOL enable = [value boolValue];
    [[PushIOManager sharedInstance] setLoggingEnabled:enable];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

//Todo cordova
-(void)isLoggingEnabled:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL isLoggingEnabled = [[PushIOManager sharedInstance] isLoggingEnabled];
    result(@(isLoggingEnabled));
}

-(void)getRegisteredUserId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *userId = [[PushIOManager sharedInstance] getUserID];
    [self sendPluginResult:result withResponse:userId andError:nil];
}

-(void)unregisterUserId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[PushIOManager sharedInstance] registerUserID:nil];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)frameworkVersion:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [self sendPluginResult:result withResponse:[[PushIOManager sharedInstance] frameworkVersion] andError:nil];
}

-(void)setExternalDeviceTrackingID:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *externalDeviceTrackingID = call.arguments;
    if (externalDeviceTrackingID == (id)[NSNull null]) {
        externalDeviceTrackingID = nil;
    }
    [[PushIOManager sharedInstance] setExternalDeviceTrackingID:externalDeviceTrackingID];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)getExternalDeviceTrackingID:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *externalDeviceTrackingID = [[PushIOManager sharedInstance] externalDeviceTrackingID];
    [self sendPluginResult:result withResponse:externalDeviceTrackingID andError:nil];
}


-(void)setAdvertisingID:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *advertisingIdentifier = call.arguments;
    if (advertisingIdentifier == (id)[NSNull null]) {
        advertisingIdentifier = nil;
    }
    [[PushIOManager sharedInstance] setAdvertisingIdentifier:advertisingIdentifier];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)getAdvertisingID:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [self sendPluginResult:result withResponse:[[PushIOManager sharedInstance] advertisingIdentifier] andError:nil];
}


-(void)setExecuteRsysWebUrl:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id executeRsysWebURL = call.arguments;
    if (executeRsysWebURL == (id)[NSNull null]) {
        executeRsysWebURL = nil;
    }

    [[PushIOManager sharedInstance] setExecuteRsysWebURL:[executeRsysWebURL boolValue]];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)getExecuteRsysWebUrl:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    result(@([[PushIOManager sharedInstance] executeRsysWebURL]));
}

                              
                              //TODO
-(void)setConfigType:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    int configType = [value intValue];
    [[PushIOManager sharedInstance] setConfigType:configType];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)configType:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    result(@([[PushIOManager sharedInstance] configType]));
}

-(void)resetAllData:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[PushIOManager sharedInstance] resetAllData];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)isResponsysPush:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *message = call.arguments;
    if (message == (id)[NSNull null]) {
        message = nil;
    }
    result(@([[PushIOManager sharedInstance] isResponsysPayload:message]));
}

-(void)onGeoRegionEntered:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *region = call.arguments;
    if (region == (id)[NSNull null]) {
        region = nil;
    }

    PIOGeoRegion *geoRegion = [region geoRegion];
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionary];
    responseDictionary[@"regionType"] = @"GEOFENCE_ENTRY";
    responseDictionary[@"regionID"] = geoRegion.geofenceId;

    [[PushIOManager sharedInstance] didEnterGeoRegion:geoRegion completionHandler:^(NSError *error, NSString *response) {
        if (error) {
            result([self flutterError:error]);
        } else {
            result(responseDictionary);
        }
    }];
}


-(void)onGeoRegionExited:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *region = call.arguments;
    if (region == (id)[NSNull null]) {
        region = nil;
    }

    PIOGeoRegion *geoRegion = [region geoRegion];
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionary];
    responseDictionary[@"regionType"] = @"GEOFENCE_EXIT";
    responseDictionary[@"regionID"] = geoRegion.geofenceId;

    [[PushIOManager sharedInstance] didExitGeoRegion:[region geoRegion] completionHandler:^(NSError *error, NSString *response) {
        if (error) {
            result([self flutterError:error]);
        } else {
            result(responseDictionary);
        }
    }];
}


-(void)onBeaconRegionEntered:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *region = call.arguments;
    if (region == (id)[NSNull null]) {
        region = nil;
    }

    PIOBeaconRegion *beaconRegion = [region beaconRegion];
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionary];
    responseDictionary[@"regionType"] = @"BEACON_ENTRY";
    responseDictionary[@"regionID"] = beaconRegion.beaconId;

    [[PushIOManager sharedInstance] didEnterBeaconRegion:[region beaconRegion] completionHandler:^(NSError *error, NSString *response) {
        if (error) {
            result([self flutterError:error]);
        } else {
            result(responseDictionary);
        }
    }];
}
-(void)onBeaconRegionExited:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *region = call.arguments;
    if (region == (id)[NSNull null]) {
        region = nil;
    }

    PIOBeaconRegion *beaconRegion = [region beaconRegion];
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionary];
    responseDictionary[@"regionType"] = @"BEACON_EXIT";
    responseDictionary[@"regionID"] = beaconRegion.beaconId;

    
    [[PushIOManager sharedInstance] didExitBeaconRegion:[region beaconRegion] completionHandler:^(NSError *error, NSString *response) {
        if (error) {
            result([self flutterError:error]);
        } else {
            result(responseDictionary);
        }
    }];
}

- (void)setLastLocation:(CLLocation *)lastLocation {
    
}

-(void)handleMessage:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [self sendPluginResult:result withResponse:nil andError:nil];
}


-(void)getLibVersion:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *frameworkVersion = [[PushIOManager sharedInstance] frameworkVersion];
    [self sendPluginResult:result withResponse:frameworkVersion andError:nil];
}


- (void)sendPluginResult:(FlutterResult)result withResponse:(NSString *)response andError:(NSError *)error  {
    if (error) {
        result([self flutterError:error]);
    } else if (response) {
        result(response);
    } else {
        result(nil);
    }
}

-(void)onDeepLinkReceived:(NSNotification *)notification {

    NSMutableDictionary *resolvedURLInfo = [NSMutableDictionary new];

    resolvedURLInfo[@"deeplinkUrl"] = notification.userInfo[PIOResolvedDeeplinkURL];
    resolvedURLInfo[@"weblinkUrl"] = notification.userInfo[PIOResolvedWeblinkURL];
    resolvedURLInfo[@"requestUrl"] = notification.userInfo[PIORequestedWebURL];
    resolvedURLInfo[@"isPubwebURLType"] = ([notification.userInfo[PIORequestedWebURLIsPubWebType] boolValue] == YES)? @"YES" : @"NO";
    NSError *error = notification.userInfo[PIOErrorResolveWebURL];
    resolvedURLInfo[@"error"] = error.description;

    [self.channel invokeMethod:@"setIAMUrlResolveLinkHandler" arguments:resolvedURLInfo];
}

- (void)setInterceptDeepLink:(FlutterMethodCall *)call withResult:(FlutterResult)result {

    id value = call.arguments ;
    if (value == (id)[NSNull null]) {
        value = nil;
    }

    if ([value boolValue] == YES) {
        [[PushIOManager sharedInstance] setDeeplinkDelegate:self];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"PIODeeplinkHandler"];

    } else {
        [[PushIOManager sharedInstance] setDeeplinkDelegate:nil];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"PIODeeplinkHandler"];

    }

    [self sendPluginResult:result withResponse:nil andError:nil];
}
//
- (BOOL)handleOpenURL:(NSURL *)url {
    if (url == nil) {
        return NO;
    }

    [self.channel invokeMethod:@"setNotificationDeepLinkHandler" arguments:[url absoluteString]];
    return YES; //It's intercepted everytime.
}

-(void)setDelayRichPushDisplay:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    [[PushIOManager sharedInstance] setDelayRichPushDisplay:[value boolValue]];

    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)showRichPushMessage:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[PushIOManager sharedInstance] showRichPushMessage];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)isRichPushDelaySet:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL isRichPushDelaySet = [[PushIOManager sharedInstance] isRichPushDelaySet];
    result(@(isRichPushDelaySet));
}

-(void)setInAppCustomCloseButton:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *customCloseBluttonInfo = call.arguments;
    if (customCloseBluttonInfo == (id)[NSNull null]) {
        customCloseBluttonInfo = nil;
    }
    UIButton *closeButton = [customCloseBluttonInfo customCloseButton];
    if(closeButton == nil){
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%i", (int)00] message:@"Provide valid title or button name to create custom close button for InApp messages." details:nil]);
        return;
    }
    
    [[PushIOManager sharedInstance] setInAppMessageCloseButton:closeButton];
    [[PushIOManager sharedInstance] setInAppDelegate:self];
    [self sendPluginResult:result withResponse:nil andError:nil];
}



- (FlutterError *)flutterError: (NSError *)error {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"%i", (int)error.code] message:error.localizedDescription details:nil];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    if ([UNUserNotificationCenter currentNotificationCenter].delegate == nil) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                       ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                       ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                       ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken %@",token);
    [[PushIOManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    [[PushIOManager sharedInstance] didFailToRegisterForRemoteNotificationsWithError:error];
}

- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSLog(@"Received remote notification: %@", userInfo);
    [[PushIOManager sharedInstance] didReceiveRemoteNotification:userInfo
                                           fetchCompletionResult:UIBackgroundFetchResultNewData fetchCompletionHandler:completionHandler];
    return YES;
}

//iOS 10
-(void) userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler{
    NSLog( @"Handle push from background or closed" );
    [[PushIOManager sharedInstance] userNotificationCenter:center didReceiveNotificationResponse:response
                                     withCompletionHandler:completionHandler];
}

-(void) userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"Received remote notification: %@", notification.request.content.userInfo);
    [[PushIOManager sharedInstance] userNotificationCenter:center willPresentNotification:notification
                                     withCompletionHandler:completionHandler];
}


- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    [[PushIOManager sharedInstance] continueUserActivity:userActivity restorationHandler:restorationHandler];
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [[PushIOManager sharedInstance] openURL:url options:options];
    return YES;
}

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    
    [[PushIOManager sharedInstance] didFinishLaunchingWithOptions:launchOptions];
    return true;
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    
    [[PushIOManager sharedInstance] didFinishLaunchingWithOptions:nil];
}

-(void)setInAppMessageBannerHeight:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    
    [[PushIOManager sharedInstance] setInAppMessageBannerHeight:[value floatValue]];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)getInAppMessageBannerHeight:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    float heightOfBanner = [[PushIOManager sharedInstance] getInAppMessageBannerHeight];
    result(@(heightOfBanner));
}

-(void)setStatusBarHiddenForIAMBannerInterstitial:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    
    id value = call.arguments;
    if (value == (id)[NSNull null]) {
        value = nil;
    }
    
    [[PushIOManager sharedInstance] setStatusBarHiddenForIAMBannerInterstitial:[value boolValue]];
    [self sendPluginResult:result withResponse:nil andError:nil];
}

-(void)isStatusBarHiddenForIAMBannerInterstitial:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL hideStatusBar = [[PushIOManager sharedInstance] isStatusBarHiddenForIAMBannerInterstitial];
    result(@(hideStatusBar));
}

-(void)onMessageCenterUpdate:(NSNotification *)notification {

    NSArray *messageCenters =  (NSArray *)[notification object];

    if (messageCenters != nil && messageCenters.count > 0){
        NSString *mcString =  [messageCenters componentsJoinedByString:@","];
        [self.channel invokeMethod:@"onMessageCenterUpdate" arguments:mcString];
    }
}


               
@end


