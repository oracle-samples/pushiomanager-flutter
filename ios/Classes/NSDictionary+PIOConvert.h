/**
* Copyright © 2023, Oracle and/or its affiliates. All rights reserved.
*
* Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
*/


#import <Foundation/Foundation.h>
#import <PushIOManager/PushIOManagerAll.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary(PIOConvert)
- (PIOGeoRegion *)geoRegion;
- (PIOBeaconRegion *)beaconRegion;
- (PIONotificationCategory *)notificationCategory;
- (PIOConversionEvent *)conversionEvent;
- (UIButton *)customCloseButton;
+ (NSDictionary *)dictionaryFromPreference:(PIOPreference *)preference;
- (NSString *)JSON;
@end

NS_ASSUME_NONNULL_END
