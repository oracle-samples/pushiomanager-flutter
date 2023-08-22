/**
* Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
*
* Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
*/


#import "NSDictionary+PIOConvert.h"

@interface NSDictionary(PIOConvert)
- (UIColor *)colorFromHexString:(unsigned long)hex;
- (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end

@implementation NSDictionary(PIOConvert)

- (PIOGeoRegion *)geoRegion {
    NSString *geofenceId = self[@"geofenceId"];
    NSString *geofenceName = self[@"geofenceName"];
    double speed = [self[@"deviceSpeed"] doubleValue];
    double bearing = [self[@"deviceBearing"] doubleValue];
    NSString *zoneId = self[@"zoneId"];
    NSString *zoneName = self[@"zoneName"];
    NSString *source = self[@"source"];
    NSInteger dwellTime = [self[@"dwellTime"] integerValue];
    NSDictionary *extra = self[@"extra"] ;
    
    if(extra == nil || [extra isEqual:[NSNull  null]]) {
        extra = nil;
    }

    PIOGeoRegion *geoRegion = [[PIOGeoRegion alloc] initWithGeofenceId:geofenceId geofenceName:geofenceName speed:speed bearing:bearing source:source zoneId:zoneId zoneName:zoneName dwellTime:dwellTime extra:extra];
    
    return geoRegion;
}

- (PIOBeaconRegion *)beaconRegion {
    NSString *iBeaconUUID = self[@"iBeaconUUID"];
    NSInteger iBeaconMajor = [self[@"iBeaconMajor"] integerValue];
    NSInteger iBeaconMinor = [self[@"iBeaconMinor"] integerValue];
    NSString *beaconId = self[@"beaconId"];
    NSString *beaconName = self[@"beaconName"];
    NSString *beaconTag = self[@"beaconTag"];
    NSString *proximity = self[@"beaconProximity"];
    NSString *zoneId = self[@"zoneId"];
    NSString *zoneName = self[@"zoneName"];
    NSString *source = self[@"source"];
    NSInteger dwellTime = [self[@"dwellTime"] integerValue];
    NSDictionary *extra = self[@"extra"];
    NSString *eddyStoneId1 = self[@"eddyStoneId1"];
    NSString *eddyStoneId2 = self[@"eddyStoneId2"];
    
    if(extra == nil || [extra isEqual:[NSNull  null]]) {
        extra = nil;
    }
    
    PIOBeaconRegion *beaconRegion = [[PIOBeaconRegion alloc] initWithiBeaconUUID:iBeaconUUID iBeaconMajor:iBeaconMajor iBeaconMinor:iBeaconMinor beaconId:beaconId beaconName:beaconName beaconTag:beaconTag proximity:proximity source:source zoneId:zoneId zoneName:zoneName dwellTime:dwellTime extra:extra];
    beaconRegion.eddyStoneId1 = eddyStoneId1;
    beaconRegion.eddyStoneId2 = eddyStoneId2;
    
    return beaconRegion;
}

- (PIONotificationCategory *)notificationCategory {
    NSArray *oracleButtons = self[@"orcl_btns"];
    NSMutableArray *actions = [NSMutableArray new];
    for (NSDictionary *action in oracleButtons) {
        
        NSString *buttonAction = action[@"action"];
        if(buttonAction != nil && ![buttonAction isEqual:[NSNull null]]) {
            
            PIONotificationAction *newAction = [[PIONotificationAction alloc] initWithIdentifier:action[@"id"] title:action[@"label"] isDestructive:[buttonAction isEqualToString:@"DE"] isForeground:[buttonAction isEqualToString:@"FG"] isAuthenticationRequired:[buttonAction isEqualToString:@"AR"]];
            [actions addObject:newAction];
        }
    }
    return [[PIONotificationCategory alloc] initWithIdentifier:self[@"orcl_category"] actions:actions];
}

- (UIButton *)customCloseButton {
    NSString *title = (self[@"title"] == (id)[NSNull null]) ? nil : self[@"title"];
    NSString *backgroundColor = (NSString *)((self[@"backgroundColor"] == (id)[NSNull null]) ? nil : self[@"backgroundColor"]);
    NSString *titleColor =  (NSString *)((self[@"titleColor"] == (id)[NSNull null]) ? nil : self[@"titleColor"]);
    NSString *imageName = (self[@"imageName"] == (id)[NSNull null]) ? nil : self[@"imageName"];
    if((title == nil || title.length == 0) && (imageName == nil || imageName.length == 0)){
        return nil;
    }
    CGFloat width = (self[@"width"] == (id)[NSNull null]) ? 0 : (CGFloat)[self[@"width"] doubleValue];
    CGFloat height = (self[@"height"] == (id)[NSNull null]) ? 0 :(CGFloat)[self[@"height"] doubleValue];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(0, 0,width, height)];
    if(imageName != nil){
        [closeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [closeButton setContentMode:UIViewContentModeScaleAspectFit];
    }
    if(title != nil){
        [closeButton setTitle:title forState:UIControlStateNormal];
        UIColor *bgColor = [self colorFromHexString:backgroundColor];
        if(bgColor) {
            [closeButton setBackgroundColor:bgColor];
        }
        
        [closeButton setTitleColor:[self colorFromHexString:titleColor] forState:UIControlStateNormal];
        [closeButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return closeButton;
}

+ (NSDictionary *)dictionaryFromPreference:(PIOPreference *)preference {

    if(preference != nil && preference.key != nil) {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"key"] = preference.key;
    dictionary[@"value"] = preference.value;
    dictionary[@"label"] = preference.label;
      switch (preference.type) {
          case PIOPreferenceTypeString:
              dictionary[@"type"] = @"STRING";
              break;
          case PIOPreferenceTypeBoolean:
              dictionary[@"type"] = @"BOOLEAN";
              break;
          case PIOPreferenceTypeNumeric:
              dictionary[@"type"] = @"NUMBER";
              break;
      }
    return dictionary;
    } else {
        return nil;
    } 
}

- (PIOConversionEvent *)conversionEvent {
    NSString *orderId = self[@"orderId"];
    double orderTotal = [self[@"orderTotal"] doubleValue];
    NSInteger orderQuantity = [self[@"orderQuantity"] integerValue];
    int conversionType  = [self[@"conversionType"] intValue];
    NSDictionary *customProperties = self[@"customProperties"];
    if (customProperties == nil) {
        customProperties = [NSDictionary dictionary];
    }
    PIOConversionEvent *event = [[PIOConversionEvent alloc] initWithOrderId:orderId orderTotal:orderTotal orderQuantity:orderQuantity conversionType:conversionType customProperties:customProperties];
    return event;
}


- (NSString *)JSON {
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];
    
    if(err != nil) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// Helper Functions

- (UIColor *) colorFromHexString:(NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
       CGFloat alpha, red, blue, green;
       switch ([colorString length]) {
           case 3: // #RGB
               alpha = 1.0f;
               red   = [self colorComponentFrom: colorString start: 0 length: 1];
               green = [self colorComponentFrom: colorString start: 1 length: 1];
               blue  = [self colorComponentFrom: colorString start: 2 length: 1];
               break;
           case 4: // #ARGB
               alpha = [self colorComponentFrom: colorString start: 0 length: 1];
               red   = [self colorComponentFrom: colorString start: 1 length: 1];
               green = [self colorComponentFrom: colorString start: 2 length: 1];
               blue  = [self colorComponentFrom: colorString start: 3 length: 1];
               break;
           case 6: // #RRGGBB
               alpha = 1.0f;
               red   = [self colorComponentFrom: colorString start: 0 length: 2];
               green = [self colorComponentFrom: colorString start: 2 length: 2];
               blue  = [self colorComponentFrom: colorString start: 4 length: 2];
               break;
           case 8: // #AARRGGBB
               alpha = [self colorComponentFrom: colorString start: 0 length: 2];
               red   = [self colorComponentFrom: colorString start: 2 length: 2];
               green = [self colorComponentFrom: colorString start: 4 length: 2];
               blue  = [self colorComponentFrom: colorString start: 6 length: 2];
               break;
           default:
               alpha = 0.0f;
               red   = 0.0f;
               green = 0.0f;
               blue  = 0.0f;
               NSLog(@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB. Default color set to Black", hexString);
                      break;
               
       }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

- (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end
