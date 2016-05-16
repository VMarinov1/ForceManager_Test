//
//  MapViewController.h
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 15.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class GeolocatedElement;

@interface MapViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, strong) NSArray<GeolocatedElement *>*elements;

@end
