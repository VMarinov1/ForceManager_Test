//
//  ElementViewController.h
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 15.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class GeolocatedElement;

@protocol ElementViewControllerDelegate

- (void)didSaveElement:(GeolocatedElement*)element;

@end


@interface ElementViewController : UIViewController <MKMapViewDelegate,
                                                    UITextViewDelegate,
                                                    UIPickerViewDelegate>

@property (nonatomic, strong) GeolocatedElement *element;
@property (nonatomic, weak) id<ElementViewControllerDelegate> delegate;


@end
