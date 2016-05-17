//
//  GeolocatedElement.m
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 13.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "GeolocatedElement.h"
#import "Utilities.h"

@implementation GeolocatedElement

- (GeolocatedElement*)init{
    if(self = [super init]){
        _creationDate = [NSDate date];
        return self;
    }
    return nil;
}

@end
