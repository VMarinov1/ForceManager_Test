//
//  DatabaseManager.h
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 17.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GeolocatedElement;

@interface DatabaseManager : NSObject

- (NSArray<GeolocatedElement*>*)loadAllElements;
- (long long)insertElement:(GeolocatedElement*)element;
- (BOOL)updateElement:(GeolocatedElement*)element;
- (BOOL)deleteElement:(GeolocatedElement*)element;

+ (instancetype)DBInstance;

@end
