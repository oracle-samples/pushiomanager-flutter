/**
* Copyright © 2024, Oracle and/or its affiliates. All rights reserved.
*
* Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
*/


#import <Foundation/Foundation.h>
#import <CX_Mobile_SDK/CX_Mobile_SDK.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary(PIOConvert)
- (PIONotificationCategory *)notificationCategory;
- (PIOConversionEvent *)conversionEvent;
- (UIButton *)customCloseButton;
+ (NSDictionary *)dictionaryFromPreference:(PIOPreference *)preference;
- (NSString *)JSON;
- (PIOGeoRegion *)geoRegion;
- (PIOBeaconRegion *)beaconRegion;
@end

NS_ASSUME_NONNULL_END
