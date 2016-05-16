//
//  ElementsTableViewController.h
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 13.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ElementViewController.h"


@interface ElementsTableViewController : UITableViewController<CLLocationManagerDelegate, ElementViewControllerDelegate>


@end

