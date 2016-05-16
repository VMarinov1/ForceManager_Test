//
//  ElementViewController.m
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 15.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "ElementViewController.h"
#import <MapKit/MapKit.h>
#import "GeolocatedElement.h"
#import "Constants.h"
#import "Utilities.h"

@interface ElementViewController()

// Outlets
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *descriptionField;
@property (nonatomic, weak) IBOutlet UITextField *typeField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadTypesActivityView;
@property (nonatomic, weak) IBOutlet UIPickerView *typesPicker;

//
@property (nonatomic, strong) NSArray *typesArray;

- (void)loadElementTypes;
- (void)saveElement;
- (BOOL)viewIsValid;
- (void)showPicker;
- (void)hidePicker;
- (void)updateSelectedType;
- (void)parseTypesFromData:(NSData*)data;

@end

@implementation ElementViewController

#pragma mark- View Delegate
- (void)viewDidLoad{
    [super viewDidLoad];
    [self.typeField setEnabled:NO];
    [self.typesPicker setHidden:YES];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveElement)];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = self.element.location.coordinate;
    point.title = self.element.name;
    point.subtitle = self.element.textDescription;
    [self.mapView addAnnotation:point];
    // center region
    MKCoordinateSpan span;
    span.latitudeDelta = 0.2;     // 0.0 is min value u van provide for zooming
    span.longitudeDelta= 0.2;
    MKCoordinateRegion region;
    region.span = span;
    region.center = self.element.location.coordinate;
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
    
    [self.nameField setText:self.element.name];
    [self.descriptionField setText:self.element.textDescription];
    [self setTitle:self.element.name];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadElementTypes];
    [self.navigationItem.rightBarButtonItem setEnabled:[self viewIsValid]];
    [self.nameField becomeFirstResponder];
}

#pragma mark- Actions
/*!
 * @discussion Check if view is valid and can be saved
 * @return YES if Element can be saved
 */
- (BOOL)viewIsValid{
    if(self.nameField.text.length == 0
       || self.descriptionField.text.length == 0
       || self.typeField.text.length == 0){
        return NO;
    }
    return YES;
}

/*!
 * @discussion Show type's picker
 */
- (void)showPicker{
    [self.typesPicker setHidden:NO];
    [self.mapView setHidden:YES];
    [self.nameField setEnabled:NO];
    [self.descriptionField setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

/*!
 * @discussion Hide picker after type is selected
 */
- (void)hidePicker{
    [self.typesPicker setHidden:YES];
    [self.mapView setHidden:NO];
    [self.nameField setEnabled:YES];
    [self.descriptionField setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:[self viewIsValid]];
}

/*!
 * @discussion Update text in type's filed
 */
- (void)updateSelectedType{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", self.element.type];
    NSArray *founds = [self.typesArray filteredArrayUsingPredicate:predicate];
    if([founds count] > 0){
        NSDictionary *valueDict = [founds objectAtIndex:0];
        [self.typeField setText:[valueDict valueForKey:TYPE_DICT_KEY]];
    }
    else {
        [self.typeField setText:@""];
        [self.typeField setPlaceholder:@"Please Select"];
    }
    [self.navigationItem.rightBarButtonItem setEnabled:[self viewIsValid]];
}

/*!
 * @discussion Parse types JSON
 * @param data Received from URL
 */
- (void)parseTypesFromData:(NSData*)data{
    NSError *parseError = nil;
    [self.loadTypesActivityView stopAnimating];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
    if(parseError == nil){
        self.typesArray = [dict objectForKey:TYPES_DICT_KEY];
        [self.typeField setEnabled:TRUE];
        [self.typesPicker reloadAllComponents];
        [self updateSelectedType];
    }
    else {
        [Utilities showErrorMessage:@"Error parsing response" withError:parseError withSender:self];
    }
}

/*!
 * @discussion Request types from URL
 */
- (void)loadElementTypes {
    [self.loadTypesActivityView startAnimating];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:GET_TYPES_URL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                // handle response
                if(error != nil ){
                    [Utilities showErrorMessage:@"Download types" withError:error withSender:self];
                }
                else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self parseTypesFromData:data];
                     });
                }
            }] resume];
}

#pragma mark-UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
   return self.typesArray == nil ? 0: 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.typesArray == nil ? 0: [self.typesArray count];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSDictionary *valueDict = [self.typesArray objectAtIndex:row];
    [self.typeField setText:[valueDict valueForKey:TYPE_DICT_KEY]];
    [self hidePicker];
    
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *valueDict = [self.typesArray objectAtIndex:row];
    return [valueDict valueForKey:TYPE_DICT_KEY];
}
#pragma mark-UITextViewDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField.tag == SELECT_TYPE_FIELD_TAG){
        [self showPicker];
        return NO;
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * expectText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.navigationItem.rightBarButtonItem setEnabled: expectText.length > 0];
    if(expectText.length > 0){
        [self.navigationItem.rightBarButtonItem setEnabled:[self viewIsValid]];
    }
    return YES;
}


#pragma mark- Actions

/*!
 * @discussion Save current Element
 */
- (void)saveElement{
    if(self.delegate != nil){
        self.element.name = self.nameField.text;
        self.element.textDescription = self.descriptionField.text;
        self.element.type = self.typeField.text;
        [self.delegate didSaveElement:self.element];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
