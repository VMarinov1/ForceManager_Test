//
//  ElementsTableViewController.m
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 13.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "ElementsTableViewController.h"
#import "GeolocatedElement.h"


#define CELL_INDENT @"MyIdentifier"
#define ELEMENT_SEGUE @"ElementSegue"
#define VIEW_MAP_SEGUE @"ViewMapSegue"


@interface ElementsTableViewController ()

@property (nonatomic, strong) NSMutableArray<GeolocatedElement*> *elements;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL locationManagerIsStarted;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

@implementation ElementsTableViewController

- (void)loadInitialData{
    
    GeolocatedElement *home = [[GeolocatedElement alloc] init];
    home.name = @"Vladimir's Home";
    home.creationDate = [NSDate date];
    home.type = @"Square";
    home.textDescription = @"Vladimir's Square";
    home.location = [[CLLocation alloc] initWithLatitude:42.666903 longitude:23.282132];
    
    
    GeolocatedElement *barcelona = [[GeolocatedElement alloc] init];
    barcelona.name = @"Barcelona";
    barcelona.textDescription = @"Barcelona Square";
    barcelona.creationDate = [NSDate date];
    barcelona.type = @"Square";
    barcelona.location = [[CLLocation alloc] initWithLatitude:41.38506389 longitude:2.076416];
    self.elements = [[NSMutableArray alloc] initWithObjects:home, barcelona, nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewElement)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"map" style:UIBarButtonItemStylePlain target:self action:@selector(viewMap)];
    self.locationManagerIsStarted = NO;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startLocationManager];
    if(self.refreshTimer.valid == NO){
        [self.refreshTimer fire];
    }
    
}
- (void)startLocationManager{
    if(self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc] init];
    }
    if(self.locationManagerIsStarted == NO){
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter=kCLDistanceFilterNone;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
        self.locationManagerIsStarted = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInitialData];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self
                                           selector:@selector(updatePostions:) userInfo:nil repeats:YES];
}

/*
- (void)
 
 - stop time
 - stop location services
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-MainActions
- (void)addNewElement{
    [self performSegueWithIdentifier:ELEMENT_SEGUE sender:self];
}
- (void)viewMap{
    [self performSegueWithIdentifier:VIEW_MAP_SEGUE sender:self];
}
- (void)viewDetailsForElement:(GeolocatedElement*)element{
    [self performSegueWithIdentifier:ELEMENT_SEGUE sender:self];
}
#pragma mark-
- (void)updatePostions:(id)sender{
    if(self.locationManagerIsStarted == YES && [self.elements count] > 0){
      [self.tableView reloadData];
        NSString *title = [NSString stringWithFormat:@"Lat %f, Long %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
        [self setTitle:title];
    }
    
}

- (void)refresh:(id)sender{
     [self.tableView reloadData];
     [(UIRefreshControl *)sender endRefreshing];
}
#pragma mark- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // recalculate the location
    if([locations count] > 0){
        self.currentLocation = [locations objectAtIndex:0];
        self.locationManagerIsStarted = YES;
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSString *errorText = [NSString stringWithFormat:@"Error code: %ld", (long)error.code ];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Location Service Failed"
                                                                   message:errorText
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    self.locationManagerIsStarted = NO;
}

#pragma mark- UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.elements count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_INDENT];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_INDENT];
    }
    GeolocatedElement *element = [self.elements objectAtIndex:indexPath.row];
    element.distanceFromUser = [element.location distanceFromLocation:self.currentLocation];
    NSString *nameTitle = [NSString stringWithFormat:@"%@(%.02f meters)", element.name, element.distanceFromUser ];
    [cell.textLabel setText:nameTitle];
    [cell.detailTextLabel setText:element.textDescription];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    GeolocatedElement *element = [self.elements objectAtIndex:indexPath.row];
    [self viewDetailsForElement:element];
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    GeolocatedElement *element = [self.elements objectAtIndex:indexPath.row];
    [self viewDetailsForElement:element];
}


@end
