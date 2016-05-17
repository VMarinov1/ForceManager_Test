//
//  GeolocatedElement.h
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 13.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface GeolocatedElement : NSObject

@property (nonatomic, strong, nonnull) NSString *name;
@property (nonatomic, assign) long long mId;
@property (nonatomic, strong, nullable) NSString *textDescription;
@property (nonatomic, strong, nonnull) NSDate *creationDate;
@property (nonatomic, strong, nonnull) NSString *type;
@property (nonatomic, assign) double distanceToUser;
@property (nonatomic, strong, nonnull) CLLocation *location;

@end
