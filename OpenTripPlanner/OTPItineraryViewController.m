//
//  OTPItineraryViewController.m
//  OpenTripPlanner
//
//  Created by asutula on 9/14/12.
//  Copyright (c) 2012 OpenPlans. All rights reserved.
//

#import "OTPAppDelegate.h"
#import "OTPItineraryViewController.h"
#import "Leg.h"
#import "ZUUIRevealController.h"
#import "OTPDirectionPanGestureRecognizer.h"
#import "OTPItineraryOverviewCell.h"
#import "OTPArrivalCell.h"
#import "OTPStepCell.h"
#import "OTPDistanceBasedLegCell.h"
#import "OTPStopBasedLegCell.h"
#import "OTPTransferCell.h"
#import "OTPUnitFormatter.h"
#import "OTPUnitData.h"
#import "OTPSelectedSegment.h"

@interface OTPItineraryViewController ()
{
    NSMutableArray *_cellHeights;
    BOOL _mapShowing;
    NSArray *_distanceBasedModes;
    NSArray *_stopBasedModes;
    NSArray *_transferModes;
    NSDictionary *_modeDisplayStrings;
    NSDictionary *_relativeDirectionDisplayStrings;
    NSDictionary *_relativeDirectionIcons;
    NSDictionary *_absoluteDirectionDisplayStrings;
    NSDictionary *_modeIcons;
    NSMutableArray *_shapesForLegs;
    NSDictionary *_popuprModeIcons;
    NSIndexPath *_selectedIndexPath;
    NSArray *_stepModeFilteredLegs;
    NSArray *_allSteps;
    BOOL _shouldDisplaySteps;
}

- (void)resetLegsWithColor:(UIColor *)color;

@end

@implementation OTPItineraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	// Do any additional setup after loading the view.
    
    _cellHeights = [[NSMutableArray alloc] init];
    _mapShowing = NO;
    
    // WALK, BICYCLE, CAR, TRAM, SUBWAY, RAIL, BUS, FERRY, CABLE_CAR, GONDOLA, FUNICULAR, TRANSFER
    
    _distanceBasedModes = @[@"WALK", @"BICYCLE", @"CAR"];
    _stopBasedModes = @[@"TRAM", @"SUBWAY", @"RAIL", @"BUS", @"FERRY", @"CABLE_CAR", @"GONDOLA", @"FUNICULAR"];
    _transferModes = @[@"TRANSFER"];
    
    _modeIcons = @{
    @"WALK" : [UIImage imageNamed:@"walk_52.png"],
    @"BICYCLE" : [UIImage imageNamed:@"bike_52.png"],
    @"CAR" : [UIImage imageNamed:@"car_52.png"],
    @"TRAM" : [UIImage imageNamed:@"cable-car_52.png"],
    @"SUBWAY" : [UIImage imageNamed:@"train_52.png"],
    @"RAIL" : [UIImage imageNamed:@"train_52.png"],
    @"BUS" : [UIImage imageNamed:@"bus_52.png"],
    @"FERRY" : [UIImage imageNamed:@"ferry_52.png"],
    @"CABLE_CAR" : [UIImage imageNamed:@"cable-car_52.png"],
    @"GONDOLA" : [UIImage imageNamed:@"gondola_52.png"],
    @"TRANSFER" : [UIImage imageNamed:@"transfer_52.png"],
    @"FUNICULAR" : [UIImage imageNamed:@"funicular_52.png"]
    };
    
    _modeDisplayStrings = @{
    @"WALK" : @"Walk",
    @"BICYCLE" : @"Bike",
    @"CAR" : @"Drive",
    @"TRAM" : @"Tram",
    @"SUBWAY" : @"Subway",
    @"RAIL" : @"Train",
    @"BUS" : @"Bus",
    @"FERRY" : @"Ferry",
    @"CABLE_CAR" : @"Cable car",
    @"GONDOLA" : @"Gondola",
    @"FUNICULAR" : @"Funicular",
    @"TRANSFER" : @"Transfer"
    };
    
    _relativeDirectionIcons = @{
    @"HARD_LEFT" : [UIImage imageNamed:@"hard-left_52.png"],
    @"LEFT" : [UIImage imageNamed:@"hard-left_52.png"],
    @"SLIGHTLY_LEFT" : [UIImage imageNamed:@"slight-left_52.png"],
    @"CONTINUE" : [UIImage imageNamed:@"continue_52.png"],
    @"SLIGHTLY_RIGHT" : [UIImage imageNamed:@"slight-right_52.png"],
    @"RIGHT" : [UIImage imageNamed:@"hard-right_52.png"],
    @"HARD_RIGHT" : [UIImage imageNamed:@"hard-right_52.png"],
    @"CIRCLE_CLOCKWISE" : [UIImage imageNamed:@"clockwise_52.png"],
    @"CIRCLE_COUNTERCLOCKWISE" : [UIImage imageNamed:@"counterclockwise_52.png"],
    @"ELEVATOR" : [UIImage imageNamed:@"elevator_52.png"]
    };
    
    _relativeDirectionDisplayStrings = @{
    @"HARD_LEFT" : @"Hard left",
    @"LEFT" : @"Left",
    @"SLIGHTLY_LEFT" : @"Slight left",
    @"CONTINUE" : @"Continue",
    @"SLIGHTLY_RIGHT" : @"Slight right",
    @"RIGHT" : @"Right",
    @"HARD_RIGHT" : @"Hard right",
    @"CIRCLE_CLOCKWISE" : @"Circle clockwise",
    @"CIRCLE_COUNTERCLOCKWISE" : @"Circle counterclockwise",
    @"ELEVATOR" : @"Elevator"
    };
    
    _absoluteDirectionDisplayStrings = @{
    @"NORTH" : @"north",
    @"NORTHEAST" : @"northeast",
    @"EAST" : @"east",
    @"SOUTHEAST" : @"southeast",
    @"SOUTH" : @"south",
    @"SOUTHWEST" : @"southwest",
    @"WEST" : @"west",
    @"NORTHWEST" : @"northwest"
    };
    
    _popuprModeIcons = @{
    @"WALK" : [UIImage imageNamed:@"popup-walk.png"],
    @"BICYCLE" : [UIImage imageNamed:@"popup-bike.png"],
    @"CAR" : [UIImage imageNamed:@"popup-car.png"],
    @"TRAM" : [UIImage imageNamed:@"popup-cable-car.png"],
    @"SUBWAY" : [UIImage imageNamed:@"popup-train.png"],
    @"RAIL" : [UIImage imageNamed:@"popup-train.png"],
    @"BUS" : [UIImage imageNamed:@"popup-bus.png"],
    @"FERRY" : [UIImage imageNamed:@"popup-ferry.png"],
    @"CABLE_CAR" : [UIImage imageNamed:@"popup-cable-car.png"],
    @"GONDOLA" : [UIImage imageNamed:@"popup-gondola.png"],
    @"TRANSFER" : [UIImage imageNamed:@"popup-transfer.png"],
    @"FUNICULAR" : [UIImage imageNamed:@"popup-funicular.png"]
    };
    
    _shapesForLegs = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mode == %@ OR mode == %@ OR mode == %@", @"BICYCLE", @"WALK", @"CAR"];
    _stepModeFilteredLegs = [self.itinerary.legs filteredArrayUsingPredicate:predicate];
    _allSteps = [self.itinerary.legs valueForKeyPath:@"@unionOfArrays.steps"];
    if (_stepModeFilteredLegs.count == self.itinerary.legs.count) {
        _shouldDisplaySteps = YES;
    } else {
        _shouldDisplaySteps = NO;
    }
    
    [self calculateCellHeights];
    
    self.itineraryTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ItineraryTableViewController"];
    self.itineraryTableViewController.tableView.dataSource = self;
    self.itineraryTableViewController.tableView.delegate = self;
    
    self.itineraryMapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ItineraryMapViewController"];
    
    self.delegate = self;
    
    self.frontViewController = self.itineraryTableViewController;
    self.rearViewController = self.itineraryMapViewController;
    self.frontViewShadowRadius = 5;
    self.rearViewRevealWidth = 260;
    self.maxRearViewRevealOverdraw = 0;
    self.toggleAnimationDuration = 0.1;
    
    OTPDirectionPanGestureRecognizer *navigationBarPanGestureRecognizer = [[OTPDirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(revealGesture:)];
    navigationBarPanGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.frontViewController.view addGestureRecognizer:navigationBarPanGestureRecognizer];
    
    [super viewDidLoad];
    
    [self.itineraryMapViewController.mapView setDelegate:self];
    self.itineraryMapViewController.mapView.topPadding = 100;
    self.itineraryMapViewController.instructionLabel.hidden = YES;
    self.itineraryMapViewController.mapView.showsUserLocation = self.mapShowedUserLocation;
    
    [self displayItinerary];
    [self displayItineraryOverview];
}

// FIXME: was having trouble dissecting the nexted if/else/elseif structures, so replicated it exactly here
-(void) calculateCellHeights {
    
    for(int i = 0; i < [self cellCount]; i++) {
        [_cellHeights setObject:[NSNumber numberWithFloat:60.0f] atIndexedSubscript:i];
        
        if (i == 0) {
            
        } else if ((!_shouldDisplaySteps && i == self.itinerary.legs.count + 1) || (_shouldDisplaySteps && i == _allSteps.count + 1) || _shouldDisplaySteps) {
            
        } else if ((!_shouldDisplaySteps && i == self.itinerary.legs.count + 2) || (_shouldDisplaySteps && i == _allSteps.count + 2) || _shouldDisplaySteps) {
            
        } else {
            // single leg itinerary: use steps as legs
            Leg *leg = [self.itinerary.legs objectAtIndex:i-1];
            
            if ([_distanceBasedModes containsObject:leg.mode]) {
                
            } else if ([_stopBasedModes containsObject:leg.mode]) {
                NSString *destination = leg.headsign.capitalizedString;
                if(destination == nil) {
                    destination = leg.to.name.capitalizedString;
                }
                
                NSString *labelText = [NSString stringWithFormat: @"%@ towards %@",
                                       [_modeDisplayStrings objectForKey:leg.mode],
                                       destination];
                
                CGSize textSize = [labelText
                                   sizeWithFont:[UIFont boldSystemFontOfSize:14]
                                   constrainedToSize:CGSizeMake(246, MAXFLOAT)
                                   lineBreakMode:UILineBreakModeWordWrap];
                
                [_cellHeights setObject:[NSNumber numberWithFloat:65.0f + textSize.height] atIndexedSubscript:i];
            } else if ([_transferModes containsObject:leg.mode]) {
                
            }
        }
    }
}

-(NSInteger)cellCount {
    
    // Check if we have any BIKE and/or WALK and/or CAR only legs
    if (_shouldDisplaySteps) {
        return _allSteps.count + 3;
    }
    return self.itinerary.legs.count + 3;  // +3 for overview, final arrival info and feedback
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self cellCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mm a";
    
    UITableViewCell *cell = nil;
    
    // first cell
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"OverviewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Set from/to in itinerary overview cell
        ((OTPItineraryOverviewCell *)cell).fromLabel.text = self.fromTextField.text;
        ((OTPItineraryOverviewCell *)cell).toLabel.text = self.toTextField.text;
        
        // last cell
    } else if ((!_shouldDisplaySteps && indexPath.row == self.itinerary.legs.count + 1) || (_shouldDisplaySteps && indexPath.row == _allSteps.count + 1)) {
        
        static NSString *CellIdentifier = @"ArrivalCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        ((OTPArrivalCell *)cell).destinationText.text = self.toTextField.text;
        ((OTPArrivalCell *)cell).arrivalTime.text = [dateFormatter stringFromDate:self.itinerary.endTime];
        
        // Feedback cell
    } else if ((!_shouldDisplaySteps && indexPath.row == self.itinerary.legs.count + 2) || (_shouldDisplaySteps && indexPath.row == _allSteps.count + 2)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FeedbackCell"];
        // everything else
    } else {
        // use steps as segments
        if (_shouldDisplaySteps) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"StepCell"];
            
            Step *step = [_allSteps objectAtIndex:indexPath.row-1];
            Leg *leg;
            for (Leg* legToTest in self.itinerary.legs) {
                if ([legToTest.steps containsObject:step]) {
                    leg = legToTest;
                    break;
                }
            }
            
            if ([leg.steps indexOfObject:step] == 0) {
                NSString *instruction = [NSString stringWithFormat:@"%@ %@ on %@",
                                         [_modeDisplayStrings objectForKey:leg.mode],
                                         [_absoluteDirectionDisplayStrings objectForKey:step.absoluteDirection],
                                         step.streetName];
                ((OTPStepCell *)cell).iconView.image = [_modeIcons objectForKey:leg.mode];
                ((OTPStepCell *)cell).instructionLabel.text = instruction;
                
            } else {
                NSString *instruction = [NSString stringWithFormat:@"%@ on %@",
                                         [_relativeDirectionDisplayStrings objectForKey:step.relativeDirection],
                                         step.streetName];
                ((OTPStepCell *)cell).iconView.image = [_relativeDirectionIcons objectForKey:step.relativeDirection];
                ((OTPStepCell *)cell).instructionLabel.text = instruction;
            }
            // multi-leg, non walk, bike, car itinerary: don't use steps as legs
        } else {
            Leg *leg = [self.itinerary.legs objectAtIndex:indexPath.row-1];
            
            // walk leg
            if ([_distanceBasedModes containsObject:leg.mode]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DistanceBasedLegCell"];
                
                ((OTPDistanceBasedLegCell *)cell).iconView.image = [_modeIcons objectForKey:leg.mode];
                ((OTPDistanceBasedLegCell *)cell).instructionLabel.text = [NSString stringWithFormat:@"%@ to %@", [_modeDisplayStrings objectForKey:leg.mode], leg.to.name.capitalizedString];
                
                NSNumber *duration = [NSNumber numberWithFloat:roundf(leg.duration.floatValue/1000/60)];
                NSString *unitLabel = duration.intValue == 1 ? @"minute" : @"minutes";
                ((OTPDistanceBasedLegCell *)cell).timeLabel.text = [NSString stringWithFormat:@"%i %@", duration.intValue, unitLabel];
                
                OTPUnitFormatter *unitFormatter = [[OTPUnitFormatter alloc] init];
                unitFormatter.cutoffMultiplier = @3.28084F;
                unitFormatter.unitData = @[
                [OTPUnitData unitDataWithCutoff:@100 multiplier:@3.28084F roundingIncrement:@10 singularLabel:@"foot" pluralLabel:@"feet"],
                [OTPUnitData unitDataWithCutoff:@528 multiplier:@3.28084F roundingIncrement:@100 singularLabel:@"foot" pluralLabel:@"feet"],
                [OTPUnitData unitDataWithCutoff:@INT_MAX multiplier:@0.000621371F roundingIncrement:@0.1F singularLabel:@"mile" pluralLabel:@"miles"]
                ];
                
                ((OTPDistanceBasedLegCell *)cell).distanceLabel.text = [unitFormatter numberToString:leg.distance];
                
                // stopbased leg
            } else if ([_stopBasedModes containsObject:leg.mode]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"StopBasedLegCell"];
                
                ((OTPStopBasedLegCell *)cell).iconView.image = [_modeIcons objectForKey:leg.mode];
                ((OTPStopBasedLegCell *)cell).iconLabel.text = leg.route.capitalizedString;
                
                NSString *destination = leg.headsign.capitalizedString;
                if(destination == nil) {
                    destination = leg.to.name.capitalizedString;
                }
                ((OTPStopBasedLegCell *)cell).instructionLabel.text = [NSString stringWithFormat: @"%@ towards %@", [_modeDisplayStrings objectForKey:leg.mode], destination];
                [((OTPStopBasedLegCell *)cell).instructionLabel sizeToFit];
                
                ((OTPStopBasedLegCell *)cell).departureTimeLabel.text = [NSString stringWithFormat:@"Departs %@", [dateFormatter stringFromDate:leg.startTime]];
                
                int intermediateStops = leg.intermediateStops.count + 1;
                NSString *stopUnitLabel = intermediateStops == 1 ? @"stop" : @"stops";
                ((OTPStopBasedLegCell *)cell).stopsLabel.text = [NSString stringWithFormat:@"%u %@", intermediateStops, stopUnitLabel];
                ((OTPStopBasedLegCell *)cell).toLabel.text = [NSString stringWithFormat:@"Get off at %@", leg.to.name.capitalizedString];
                
                // transfer leg
            } else if ([_transferModes containsObject:leg.mode]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TransferBasedLegCell"];
                ((OTPTransferCell *)cell).iconView.image = [_modeIcons objectForKey:leg.mode];
                
                Leg *nextLeg = [self.itinerary.legs objectAtIndex:indexPath.row];
                ((OTPTransferCell *)cell).instructionLabel.text = [NSString stringWithFormat:@"Transfer to the %@", nextLeg.route.capitalizedString];
            }
        }
    }
    
    OTPSelectedSegment *selectedView = [[OTPSelectedSegment alloc] init];
    cell.selectedBackgroundView = selectedView;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height = [_cellHeights objectAtIndex:indexPath.row];
    return [height floatValue];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    
    // Show the map if the selected cell is not the feedback cell
    if (!_mapShowing &&
        !((!_shouldDisplaySteps && indexPath.row == self.itinerary.legs.count + 2) || (_shouldDisplaySteps && indexPath.row == _allSteps.count + 2))) {
        [self revealToggle:self];
    }
    
    // Overview cell selected
    if (indexPath.row == 0) {
        [TestFlight passCheckpoint:@"ITINERARY_DISPLAY_OVERVIEW"];
        [UIView animateWithDuration:0.3 animations:^{
            self.itineraryMapViewController.instructionLabel.center = CGPointMake(self.itineraryMapViewController.instructionLabel.center.x, self.itineraryMapViewController.instructionLabel.center.y - self.itineraryMapViewController.instructionLabel.bounds.size.height);
        } completion:^(BOOL finished) {
            self.itineraryMapViewController.instructionLabel.hidden = YES;
        }];
        self.itineraryMapViewController.mapView.topPadding = 0;
        
        [self resetLegsWithColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5]];
        [self displayItineraryOverview];
        
        // Arrival cell (the last cell) selected
    } else if ((!_shouldDisplaySteps && indexPath.row == self.itinerary.legs.count + 1) ||
               (_shouldDisplaySteps && indexPath.row == _allSteps.count + 1)) {
        [TestFlight passCheckpoint:@"ITINERARY_DISPLAY_ARRIVAL"];
        [self resetLegsWithColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5]];
        Leg *leg = [self.itinerary.legs lastObject];
        self.itineraryMapViewController.instructionLabel.text = [NSString stringWithFormat:@"Arrive at %@.", self.toTextField.text];
        // Ugh. DRY.
        [self.itineraryMapViewController.instructionLabel resizeHeightToFitText];
        if (self.itineraryMapViewController.instructionLabel.isHidden) {
            self.itineraryMapViewController.instructionLabel.center = CGPointMake(self.itineraryMapViewController.instructionLabel.center.x, self.itineraryMapViewController.instructionLabel.center.y - self.itineraryMapViewController.instructionLabel.bounds.size.height);
            self.itineraryMapViewController.instructionLabel.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.itineraryMapViewController.instructionLabel.center = CGPointMake(self.itineraryMapViewController.instructionLabel.center.x, self.itineraryMapViewController.instructionLabel.center.y + self.itineraryMapViewController.instructionLabel.bounds.size.height);
            }];
        }
        self.itineraryMapViewController.mapView.topPadding = self.itineraryMapViewController.instructionLabel.bounds.size.height;
        CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(leg.to.lat.floatValue - 0.001, leg.to.lon.floatValue - 0.001);
        CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(leg.to.lat.floatValue + 0.001, leg.to.lon.floatValue + 0.001);
        [self.itineraryMapViewController.mapView zoomWithLatitudeLongitudeBoundsSouthWest:sw northEast:ne animated:YES];
        // Handle feedback cell
    } else if ((!_shouldDisplaySteps && indexPath.row == self.itinerary.legs.count + 2) ||
               (_shouldDisplaySteps && indexPath.row == _allSteps.count + 2)) {
        //UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
        //[self.itineraryViewController.navigationController pushViewController:vc animated:YES];
        // Handle step based segments
    } else if (_shouldDisplaySteps) {
        [TestFlight passCheckpoint:@"ITINERARY_DISPLAY_STEP"];
        Step *step = [_allSteps objectAtIndex:indexPath.row-1];
        Leg *leg;
        for (Leg* legToTest in self.itinerary.legs) {
            if ([legToTest.steps containsObject:step]) {
                leg = legToTest;
                break;
            }
        }
        
        NSString *instruction;
        if ([leg.steps indexOfObject:step] == 0) {
            instruction = [NSString stringWithFormat:@"%@ %@ on %@.",
                           [_modeDisplayStrings objectForKey:leg.mode],
                           [_absoluteDirectionDisplayStrings objectForKey:step.absoluteDirection],
                           step.streetName];
        } else {
            instruction = [NSString stringWithFormat:@"%@ on %@.",
                           [_relativeDirectionDisplayStrings objectForKey:step.relativeDirection],
                           step.streetName];
        }
        self.itineraryMapViewController.instructionLabel.text = instruction;
        
        // TODO: Fix duplicate code.
        [self.itineraryMapViewController.instructionLabel resizeHeightToFitText];
        if (self.itineraryMapViewController.instructionLabel.isHidden) {
            self.itineraryMapViewController.instructionLabel.center = CGPointMake(self.itineraryMapViewController.instructionLabel.center.x, self.itineraryMapViewController.instructionLabel.center.y - self.itineraryMapViewController.instructionLabel.bounds.size.height);
            self.itineraryMapViewController.instructionLabel.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.itineraryMapViewController.instructionLabel.center = CGPointMake(self.itineraryMapViewController.instructionLabel.center.x, self.itineraryMapViewController.instructionLabel.center.y + self.itineraryMapViewController.instructionLabel.bounds.size.height);
            }];
        }
        
        self.itineraryMapViewController.mapView.topPadding = self.itineraryMapViewController.instructionLabel.bounds.size.height;
        
        CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(step.lat.doubleValue - 0.002, step.lon.doubleValue - 0.002);
        CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(step.lat.doubleValue + 0.002, step.lon.doubleValue + 0.002);
        [self.itineraryMapViewController.mapView zoomWithLatitudeLongitudeBoundsSouthWest:sw northEast:ne animated:YES];
        
        // Handle leg based segments
    } else {
        [TestFlight passCheckpoint:@"ITINERARY_DISPLAY_LEG"];
        [self resetLegsWithColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5]];
        RMShape *shape = [_shapesForLegs objectAtIndex:indexPath.row - 1];
        shape.lineColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
        
        Leg *leg = [self.itinerary.legs objectAtIndex:indexPath.row - 1];
        
        if ([_distanceBasedModes containsObject:leg.mode]) {
            self.itineraryMapViewController.instructionLabel.text = [NSString stringWithFormat:@"%@ to %@.", [_modeDisplayStrings objectForKey:leg.mode], leg.to.name.capitalizedString];
        } else if ([_stopBasedModes containsObject:leg.mode]) {
            self.itineraryMapViewController.instructionLabel.text = [NSString stringWithFormat: @"Take the %@ %@ towards %@ and get off at %@.", leg.route.capitalizedString, ((NSString*)[_modeDisplayStrings objectForKey:leg.mode]).lowercaseString, leg.headsign.capitalizedString, leg.to.name.capitalizedString];
        } else if ([_transferModes containsObject:leg.mode]) {
            Leg *nextLeg = [self.itinerary.legs objectAtIndex:indexPath.row];
            self.itineraryMapViewController.instructionLabel.text = [NSString stringWithFormat:@"Transfer to the %@ %@.", nextLeg.route.capitalizedString, [_modeDisplayStrings objectForKey:nextLeg.mode]];
        }
        
        [self.itineraryMapViewController.instructionLabel resizeHeightToFitText];
        if (self.itineraryMapViewController.instructionLabel.isHidden) {
            self.itineraryMapViewController.instructionLabel.center = CGPointMake(self.itineraryMapViewController.instructionLabel.center.x, self.itineraryMapViewController.instructionLabel.center.y - self.itineraryMapViewController.instructionLabel.bounds.size.height);
            self.itineraryMapViewController.instructionLabel.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.itineraryMapViewController.instructionLabel.center = CGPointMake(self.itineraryMapViewController.instructionLabel.center.x, self.itineraryMapViewController.instructionLabel.center.y + self.itineraryMapViewController.instructionLabel.bounds.size.height);
            }];
        }
        
        self.itineraryMapViewController.mapView.topPadding = self.itineraryMapViewController.instructionLabel.bounds.size.height;
        
        [self displayLeg:leg];
    }
}

- (void)revealController:(ZUUIRevealController *)revealController didRevealRearViewController:(UIViewController *)rearViewController
{
    if (revealController.currentFrontViewPosition == FrontViewPositionLeft) return;
    _mapShowing = YES;
    if (_selectedIndexPath == nil) {
        [TestFlight passCheckpoint:@"ITINERARY_SHOW_MAP_WITH_SWIPE"];
        _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else {
        [TestFlight passCheckpoint:@"ITINERARY_SHOW_MAP_FROM_TAP"];
    }
    [self.itineraryTableViewController.tableView selectRowAtIndexPath:_selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)revealController:(ZUUIRevealController *)revealController didHideRearViewController:(UIViewController *)rearViewController
{
    if (revealController.currentFrontViewPosition != FrontViewPositionLeft) return;
    [TestFlight passCheckpoint:@"ITINERARY_HIDE_MAP_WITH_SWIPE"];
    _mapShowing = NO;
    [self.itineraryTableViewController.tableView deselectRowAtIndexPath:[self.itineraryTableViewController.tableView indexPathForSelectedRow] animated:YES];
}

- (void) displayItinerary
{
    [self.itineraryMapViewController.mapView removeAllAnnotations];
    
    int legCounter = 0;
    for (Leg* leg in self.itinerary.legs) {
        if (legCounter == 0) {
            // start marker:
            RMAnnotation* startAnnotation = [RMAnnotation
                                             annotationWithMapView:self.itineraryMapViewController.mapView
                                             coordinate:CLLocationCoordinate2DMake(leg.from.lat.floatValue, leg.from.lon.floatValue)
                                             andTitle:nil];
            RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-start.png"]];
            startAnnotation.userInfo = [[NSMutableDictionary alloc] init];
            [startAnnotation.userInfo setObject:marker forKey:@"layer"];
            [self.itineraryMapViewController.mapView addAnnotation:startAnnotation];
            
        }
        if (legCounter == self.itinerary.legs.count - 1) {
            // end marker:
            RMAnnotation* endAnnotation = [RMAnnotation
                                           annotationWithMapView:self.itineraryMapViewController.mapView
                                           coordinate:CLLocationCoordinate2DMake(leg.to.lat.floatValue, leg.to.lon.floatValue)
                                           andTitle:leg.from.name];
            RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-end.png"]];
            endAnnotation.userInfo = [[NSMutableDictionary alloc] init];
            [endAnnotation.userInfo setObject:marker forKey:@"layer"];
            [self.itineraryMapViewController.mapView addAnnotation:endAnnotation];
        }
        
        // map mode popup:
        RMAnnotation* modeAnnotation = [RMAnnotation
                                        annotationWithMapView:self.itineraryMapViewController.mapView
                                        coordinate:CLLocationCoordinate2DMake(leg.from.lat.floatValue, leg.from.lon.floatValue)
                                        andTitle:leg.mode];
        
        RMMarker *popupMarker = [[RMMarker alloc] initWithUIImage:[_popuprModeIcons objectForKey:leg.mode]];
        modeAnnotation.userInfo = [[NSMutableDictionary alloc] init];
        [modeAnnotation.userInfo setObject:popupMarker forKey:@"layer"];
        [self.itineraryMapViewController.mapView addAnnotation:modeAnnotation];
        
        RMShape *polyline = [[RMShape alloc] initWithView:self.itineraryMapViewController.mapView];
        polyline.lineColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
        polyline.lineWidth = 6;
        polyline.lineCap = kCALineCapRound;
        polyline.lineJoin = kCALineJoinRound;
        
        int counter = 0;
        
        for (CLLocation *loc in leg.decodedLegGeometry) {
            if (counter == 0) {
                [polyline moveToCoordinate:loc.coordinate];
            } else {
                [polyline addLineToCoordinate:loc.coordinate];
            }
            counter++;
        }
        
        [_shapesForLegs addObject:polyline];
        
        RMAnnotation *polylineAnnotation = [[RMAnnotation alloc] init];
        [polylineAnnotation setMapView:self.itineraryMapViewController.mapView];
        polylineAnnotation.coordinate = ((CLLocation*)[leg.decodedLegGeometry objectAtIndex:0]).coordinate;
        [polylineAnnotation setBoundingBoxFromLocations:leg.decodedLegGeometry];
        polylineAnnotation.userInfo = [[NSMutableDictionary alloc] init];
        [polylineAnnotation.userInfo setObject:polyline forKey:@"layer"];
        [self.itineraryMapViewController.mapView addAnnotation:polylineAnnotation];
        
        
        //        RMShape *bbox = [[RMShape alloc] initWithView:self.itineraryMapViewController.mapView];
        //        bbox.lineColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        //        bbox.lineWidth = 2;
        //        bbox.lineCap = kCALineCapRound;
        //        bbox.lineJoin = kCALineJoinRound;
        //        bbox.zPosition = 0;
        //
        //        [bbox moveToCoordinate:leg.bounds.swCorner];
        //        [bbox addLineToCoordinate:CLLocationCoordinate2DMake(leg.bounds.swCorner.latitude, leg.bounds.neCorner.longitude)];
        //        [bbox addLineToCoordinate:leg.bounds.neCorner];
        //        [bbox addLineToCoordinate:CLLocationCoordinate2DMake(leg.bounds.neCorner.latitude, leg.bounds.swCorner.longitude)];
        //        [bbox closePath];
        //
        //        RMAnnotation *bboxAnnotation = [[RMAnnotation alloc] init];
        //        [bboxAnnotation setMapView:self.itineraryMapViewController.mapView];
        //        bboxAnnotation.coordinate = leg.bounds.swCorner;
        //        [bboxAnnotation setBoundingBoxFromLocations:leg.decodedLegGeometry];
        //        bboxAnnotation.userInfo = [[NSMutableDictionary alloc] init];
        //        [bboxAnnotation.userInfo setObject:bbox forKey:@"layer"];
        //        [self.itineraryMapViewController.mapView addAnnotation:bboxAnnotation];
        
        legCounter++;
    }
}

- (void)displayItineraryOverview
{
    [self.itineraryMapViewController.mapView zoomWithLatitudeLongitudeBoundsSouthWest:self.itinerary.bounds.swCorner northEast:self.itinerary.bounds.neCorner animated:YES];
}

- (void)displayLeg:(Leg *)leg
{
    [self.itineraryMapViewController.mapView zoomWithLatitudeLongitudeBoundsSouthWest:leg.bounds.swCorner northEast:leg.bounds.neCorner animated:YES];
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    RMMapLayer* l = [annotation.userInfo objectForKey:@"layer"];
    if ([l isKindOfClass:[RMShape class]]) {
        l.zPosition = -999.0;
    }
    return l;
}

- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation
{
    self.itineraryMapViewController.userLocation = userLocation;
    if (self.itineraryMapViewController.needsPanToUserLocation) {
        [self.itineraryMapViewController updateViewsForCurrentUserLocation];
    }
}

- (void)resetLegsWithColor:(UIColor *)color
{
    for (RMShape *shape in _shapesForLegs) {
        shape.lineColor = color;
    }
}

- (void)presentFeedbackView
{
    if ([MFMailComposeViewController canSendMail]) {
        OTPAppDelegate *deleage = (OTPAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *line = @"Please provide feedback above this line and leave everything below this line intact.";
        
        NSMutableArray *legStrings = [[NSMutableArray alloc] init];
        [legStrings addObject:self.itinerary.startTime];
        for (Leg *leg in self.itinerary.legs) {
            NSString *legString = [NSString stringWithFormat:@"%@(%@)", leg.mode, leg.route];
            [legStrings addObject:legString];
        }
        NSString *legsString = [legStrings componentsJoinedByString:@", "];
        
        NSString *body = [NSString stringWithFormat:@"\n\n\n\n%@\n\n%@\n\n%@", line, deleage.currentUrlString, legsString];
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        controller.navigationBar.tintColor = [UIColor colorWithRed:0.004 green:0.694 blue:0.831 alpha:1.000];
        [controller setToRecipients:@[@"joyride@openplans.org"]];
        [controller setSubject:@"Joyride Directions Feedback"];
        [controller setMessageBody:body isHTML:NO];
        if (controller) [self presentViewController:controller animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to send feedback on this device" message:@"You can still send us feedback by emailing joyride@openplans.org." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You" message:@"Your feedback will be used to improve Joyride." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(UIBarButtonItem *)sender
{
    [TestFlight passCheckpoint:@"ITINERARY_DONE"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _mapShowing = NO;
}

@end
