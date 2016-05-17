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
@property (nonatomic) BOOL anotationIsLoaded;
@end

@implementation MapViewController

- (void)viewDidLoad{
    [super viewDidLoad];
        self.mapView.delegate = self;
    
}
#pragma mark-MKMapViewDelegate
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    if(self.anotationIsLoaded == NO){
        NSMutableArray *anotationArray = [[NSMutableArray alloc] init];
        for(GeolocatedElement *element in self.elements){
            // Add an annotation
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = element.location.coordinate;
            annotation.title = element.name;
            annotation.subtitle = element.textDescription;
            [anotationArray addObject:annotation];
            
        }
        [self.mapView showAnnotations:anotationArray animated:YES];
        self.anotationIsLoaded = YES;
    }
}

@end
