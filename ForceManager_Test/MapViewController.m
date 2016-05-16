//
//  MapViewController.m
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 15.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "GeolocatedElement.h"

@interface MapViewController()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    for(GeolocatedElement *element in self.elements){
        // Add an annotation
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = element.location.coordinate;
        point.title = element.name;
        point.subtitle = element.textDescription;
        [self.mapView addAnnotation:point];
    }
}



@end
