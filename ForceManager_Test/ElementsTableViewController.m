//
//  ElementsTableViewController.m
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 13.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "ElementsTableViewController.h"
#import "GeolocatedElement.h"
#import "MapViewController.h"
#import "ElementViewController.h"
#import "Constants.h"
#import "Utilities.h"
#import "DatabaseManager.h"


@interface ElementsTableViewController ()

@property (nonatomic, strong) NSMutableArray<GeolocatedElement*> *elements;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL locationManagerIsStarted;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) GeolocatedElement *selectedElement;
@property (nonatomic, strong) UITextField *titleField;

- (NSString*)textForDistance:(double)distance forElement:(GeolocatedElement*)element;
- (void)loadInitialData;
- (void)startLocationManager;
- (void)addNewElement;
- (void)viewMap;
- (void)viewDetailsForElement:(GeolocatedElement*)element;
- (void)updatePostions:(id)sender;
- (void)refresh:(id)sender;
- (void)didSaveElement:(GeolocatedElement*)element;

@end

@implementation ElementsTableViewController

/*!
 * @discussion Load initial/dummy data
 */
- (void)loadInitialData{
    
    GeolocatedElement *home = [[GeolocatedElement alloc] init];
    home.name = @"Vladimir Marinov";
    home.creationDate = [NSDate date];
    home.type = @"Business office";
    home.textDescription = @"Vladimir's Home";
    home.location = [[CLLocation alloc] initWithLatitude:42.666903 longitude:23.282132];
    
    GeolocatedElement *barcelona = [[GeolocatedElement alloc] init];
    barcelona.name = @"Barcelona";
    barcelona.textDescription = @"Barcelona Square";
    barcelona.creationDate = [NSDate date];
    barcelona.type = @"Square";
    barcelona.location = [[CLLocation alloc] initWithLatitude:41.38506389 longitude:2.076416];
    
    self.elements = [[NSMutableArray alloc] initWithArray: [[DatabaseManager DBInstance] loadAllElements]];
    if([self.elements count] == 0){
        barcelona.mId =  [[DatabaseManager DBInstance] insertElement:barcelona];
        home.mId = [[DatabaseManager DBInstance] insertElement:home];
        self.elements = [[NSMutableArray alloc] initWithArray: @[home, barcelona]];
    }
   
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startLocationManager];
    if(self.refreshTimer.valid == NO){
        [self.refreshTimer fire];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString: VIEW_MAP_SEGUE] == YES){
        MapViewController *contrl = (MapViewController*)segue.destinationViewController;
        contrl.elements = self.elements;
    }
    else if([segue.identifier isEqualToString: ELEMENT_SEGUE] == YES){
        ElementViewController *contrl = (ElementViewController*)segue.destinationViewController;
        contrl.element = self.selectedElement;
        contrl.delegate = self;
    }
}
/*!
 * @discussion Start Location Service if NOT started yet
 */
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewElement)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MAP_BUTTON_TITLE style:UIBarButtonItemStylePlain target:self action:@selector(viewMap)];
    self.locationManagerIsStarted = NO;
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 150, 30)];
    [self.titleField setFont:[UIFont boldSystemFontOfSize: 10]];
    [self.titleField setTextAlignment: NSTextAlignmentCenter];
    [self.titleField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.titleField setEnabled:NO];
    self.navigationItem.titleView = self.titleField;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_TIME target:self
                                           selector:@selector(updatePostions:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.refreshTimer invalidate];
    [self.locationManager stopUpdatingLocation];
    // Dispose of any resources that can be recreated.
}
#pragma mark-MainActions
- (void)addNewElement{
    self.selectedElement = [[GeolocatedElement alloc] init];
    self.selectedElement.location = self.currentLocation;
    [self performSegueWithIdentifier:ELEMENT_SEGUE sender:self];
}
/*!
 * @discussion Switch to Map View
 */
- (void)viewMap{
    [self performSegueWithIdentifier:VIEW_MAP_SEGUE sender:self];
}
/*!
 * @discussion Switch to Element's details view
 * @param element Selected element
 */
- (void)viewDetailsForElement:(GeolocatedElement*)element{
    self.selectedElement = element;
    [self performSegueWithIdentifier:ELEMENT_SEGUE sender:self];
}
#pragma mark-
/*!
 * @discussion Caller from Timer to update list in TableView
 * @param sender Timer
 */
- (void)updatePostions:(id)sender{
    if(self.locationManagerIsStarted == YES && [self.elements count] > 0){
      [self.tableView reloadData];
        NSString *title = [NSString stringWithFormat:@"Lat %f, Long %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
        [self.titleField setText:title];
    }
    
}
/*!
 * @discussion Refresh List by Refresh Control
 * @param sender Refresh Control
 */
- (void)refresh:(id)sender{
     [self.tableView reloadData];
     [(UIRefreshControl *)sender endRefreshing];
}
#pragma mark- CLLocationManagerDelegate

/*!
 * @discussion Called when location is updated
 * @param manager Location Manager
 * @return locations Updated locations
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if([locations count] > 0){
        self.currentLocation = [locations objectAtIndex:0];
        self.locationManagerIsStarted = YES;
    }
}

/*!
 * @discussion Called on location service Failed
 * @param manager Location Manager
 * @param error Error description
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(self.locationManagerIsStarted == YES){
        [Utilities showErrorMessage:@"Location Service Failed" withError:error withSender:self];
    }
    self.locationManagerIsStarted = NO;
    [self.titleField setText:@"Location Service Failed"];
}
/*!
 * @discussion Return text for actual distance
 * @param distance
 * @return element
 */
- (NSString*)textForDistance:(double)distance forElement:(GeolocatedElement*)element{
    NSString *distanceString = @"";
    if(distance >= 0){
        if(distance < METERS_CUT_OFF){
            distanceString = [NSString stringWithFormat:@"(%.01f m.)", distance];
        }
        else {
            distanceString = [NSString stringWithFormat:@"(%.01f km.)", (distance/METERS_CUT_OFF)];
        }
    }
    return [element.name stringByAppendingString:distanceString];
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
    element.distanceToUser = [element.location distanceFromLocation:self.currentLocation];
    [[DatabaseManager DBInstance] updateElement:element];
    NSString *nameTitle = [self textForDistance: element.distanceToUser forElement:element];
    [cell.textLabel setText:nameTitle];
    NSString *descText = [NSString stringWithFormat:@"%@(%@)",element.textDescription, element.type ];
    [cell.detailTextLabel setText:descText];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GeolocatedElement *element = [self.elements objectAtIndex:0];
        if([[DatabaseManager DBInstance] deleteElement:element] == YES){
            [self.elements removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}
#pragma mark-ElementViewControllerDelegate
/*!
 * @discussion Called from delegate when Element is Saved
 * @param element Element to save
 */
- (void)didSaveElement:(GeolocatedElement*)element{
    NSUInteger index = [self.elements indexOfObjectPassingTest:^BOOL(GeolocatedElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.mId == element.mId;
    }];
    if(index != NSNotFound){
        [self.elements replaceObjectAtIndex:index withObject:element];
        [[DatabaseManager DBInstance] updateElement:element];
    }
    else {
        element.mId = [[DatabaseManager DBInstance] insertElement:element];
        [self.elements addObject:element];
        
    }
    [self.tableView reloadData];

}

@end
