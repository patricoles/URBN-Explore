//
//  IDMapViewController.m
//  URBN-Explore


#import "IDMapViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>

//Indoors.framework
#import <IndoorsSDK/Indoors.h>
#import <IndoorsSDK/IDSBuilding.h>
#import <IndoorsSDK/IDSFloor.h>
#import <IndoorsSDK/IDSZonePoint.h>

//IndoorsSurface.framework
#import <IndoorsSDK/ISIndoorsSurface.h>
#import <IndoorsSDK/IndoorsSurfaceBuilder.h>
#import <IndoorsSDK/ISIndoorsSurfaceViewController.h>

//Swift Bridge Class
#import "URBN_Explore-Swift.h"

@interface IDMapViewController () <IndoorsServiceDelegate, ISIndoorsSurfaceViewControllerDelegate, RoutingDelegate, WCSessionDelegate>
@end

@implementation IDMapViewController {
    ISIndoorsSurfaceViewController *_indoorsSurfaceViewController;
}

- (void)viewDidLoad
{
    NSLog(@"*** viewDidLoad ***");
    [super viewDidLoad];
    // Defining variables
    self.testAtHome = false;
    self.buildingNorm = 739114274;
    self.buildingAccessible = 771788634;
    self.apiKey = @"2e3ac4f7-fddb-4c7a-87e0-16d2b42c4231";
    self.viewDownloadingBuilding.hidden = false;
    self.restroomTriggerStatus = false;
    self.floorChangeTriggerStatus = false;
    self.accessibilityNeededStatus = false;
    self.startDirectionButton.layer.cornerRadius = 7;
    self.passedDest = true;
    self.isBathroom = false;
    self.inRouteNavView.hidden = true;
    self.currentXCoordinate = 52209; // Dont change unless making new maps
    self.currentYCoordinate = 49648; // Dont change unless making new maps
    self.currentZCoordinate = 1; // Dont change unless making new maps
    self.takeATourBottomNextButton.layer.cornerRadius = 7;
    
    
    
    //    if (self.currentXCoordinate == 0 && self.currentYCoordinate == 0 && self.currentZCoordinate == 0 ) {
    //        [self performSegueWithIdentifier:@"showGettingPositionModal" sender:self];
    //        self.loadingModalisUp = true;
    //    } else {
    //        self.loadingModalisUp = false;
    //
    //    }
    // Set banner off screen than animate when
    [self.offlineBanner setTransform:CGAffineTransformMakeTranslation(0,-50)];
    [self.floor1 setTransform:CGAffineTransformMakeTranslation(0,0)];
    [self.floor1A setTransform:CGAffineTransformMakeTranslation(0,40)];
    [self.floor2 setTransform:CGAffineTransformMakeTranslation(0,80)];
    [self.floor2A setTransform:CGAffineTransformMakeTranslation(0,120)];
    [self.floor3 setTransform:CGAffineTransformMakeTranslation(0,160)];
    [self.floor3A setTransform:CGAffineTransformMakeTranslation(0,200)];
    [self.floor4 setTransform:CGAffineTransformMakeTranslation(0,240)];
    [self.floor4A setTransform:CGAffineTransformMakeTranslation(0,280)];
    [self.restroomMensButton setTransform:CGAffineTransformMakeTranslation(0,150)];
    [self.restroomWomensButton setTransform:CGAffineTransformMakeTranslation(0,100)];
    [self.restroomUnisexButton setTransform:CGAffineTransformMakeTranslation(0,50)];
    
    
    self.floor1.alpha = 0;
    self.floor1A.alpha = 0;
    self.floor2.alpha = 0;
    self.floor2A.alpha = 0;
    self.floor3.alpha = 0;
    self.floor3A.alpha = 0;
    self.floor4.alpha = 0;
    self.floor4A.alpha = 0;
    self.restroomMensButton.alpha = 0;
    self.restroomWomensButton.alpha = 0;
    self.restroomUnisexButton.alpha = 0;
    
    
    // Fix's missing header when app closes
    if (self.viewDownloadingBuilding.hidden == false) {
        NSLog(@"NavBar = hidden");
        
        [self.navigationController setNavigationBarHidden:true animated:false];
        
    } else {
        NSLog(@"NavBar = not hidden");
        [self.navigationController setNavigationBarHidden:false animated:false];
    }
    
    // Title of Navigatoin Bar
    self.floorTitle = @"Floor 1 ";
    self.navTitle.title = _floorTitle;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithRed:51.0f/255.0f
                                                      green:51.0f/255.0f
                                                       blue:51.0f/255.0f
                                                      alpha:1.0f],
       NSFontAttributeName:[UIFont fontWithName:@"SFUIDisplay-Regular" size:20]}];
    self.passedRoomName = @"nil";
    self.tourCurrentDestValue = 1;
    
    // Display Buttons Method
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSLog(@"This device's width = %f", _screenWidth);
    NSLog(@"This device's height =  %f", _screenHeight);
    
    
    
    // Adding Indoors API and View Method
    [self indoorsSetup];
    
    
    // Evaluation Mode (Must be called after "indoorsSetup")- Used to show fake point on map when you're not near the building to test location
    [[Indoors instance] enableEvaluationMode:_testAtHome];
    
    // Register location listener to recieve any location updates.
    [[Indoors instance] registerLocationListener:self];
    
    
    
    [self watchSession];
    
    [self styling];
    
    
    
    //Depending on your specific use case, the user might only be interested to know in which room / shop he's currently located. If that's the case in your app, you should use something like this:
    //[_indoorsSurfaceViewController.surfaceView setZoneDisplayMode:IndoorsSurfaceZoneDisplayModeUserCurrentLocation];
    //    [_indoorsSurfaceViewController.surfaceView setUserPositionDisplayMode:IndoorsSurfaceUserPositionDisplayModeNone];
    
    
    // Show all zones
    //[_indoorsSurfaceViewController.surfaceView setZoneDisplayMode:IndoorsSurfaceZoneDisplayModeAllAvailable];
    
    
    
    
    
    
    NSLog(@"SELECTED FLOOR %@", _selectedFloorLevel);
    
    
    
    // Swipe Gestures
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideUpGesture:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.takeATourBottomView addGestureRecognizer:swipeUp];
    
    NSMutableArray *tour01 = [[NSMutableArray alloc] init];
    NSMutableArray *tour02 = [[NSMutableArray alloc] init];
    NSMutableArray *tour03 = [[NSMutableArray alloc] init];
    NSMutableArray *tour04 = [[NSMutableArray alloc] init];
    NSMutableArray *tour05 = [[NSMutableArray alloc] init];
    NSMutableArray *tour06 = [[NSMutableArray alloc] init];
    NSMutableArray *tour07 = [[NSMutableArray alloc] init];
    NSMutableArray *tour08 = [[NSMutableArray alloc] init];
    NSMutableArray *tour09 = [[NSMutableArray alloc] init];
    NSMutableArray *tour10 = [[NSMutableArray alloc] init];
    
    
    [tour01 addObject:@"Building Entrance"];
    [tour01 addObject:@"Building Entrance"];
    [tour01 addObject:@"1"];
    [tour01 addObject:@"100"];
    [tour01 addObject:@"Lab"];
    [tour01 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour01 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour01 addObject:@"33796"];
    [tour01 addObject:@"27444"];
    [tour01 addObject:@"1"];
    
    [tour02 addObject:@"Advisors Office"];
    [tour02 addObject:@"lab_103_1"];
    [tour02 addObject:@"1"];
    [tour02 addObject:@"103J"];
    [tour02 addObject:@"Lab"];
    [tour02 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour02 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour02 addObject:@"33796"];
    [tour02 addObject:@"27444"];
    [tour02 addObject:@"1"];
    
    [tour03 addObject:@"Audio Lab"];
    [tour03 addObject:@"lab_103_1"];
    [tour03 addObject:@"1"];
    [tour03 addObject:@"108"];
    [tour03 addObject:@"Lab"];
    [tour03 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour03 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour03 addObject:@"33796"];
    [tour03 addObject:@"27444"];
    [tour03 addObject:@"1"];
    
    [tour04 addObject:@"Archives"];
    [tour04 addObject:@"lab_103_1"];
    [tour04 addObject:@"1"];
    [tour04 addObject:@"110"];
    [tour04 addObject:@"Lab"];
    [tour04 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour04 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour04 addObject:@"33796"];
    [tour04 addObject:@"27444"];
    [tour04 addObject:@"1"];
    
    [tour05 addObject:@"URBN 103"];
    [tour05 addObject:@"lab_103_1"];
    [tour05 addObject:@"1"];
    [tour05 addObject:@"103"];
    [tour05 addObject:@"Lab"];
    [tour05 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour05 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour05 addObject:@"33796"];
    [tour05 addObject:@"27444"];
    [tour05 addObject:@"1"];
    
    
    
    
    [tour06 addObject:@"URBN 115"];
    [tour06 addObject:@"lab_103_1"];
    [tour06 addObject:@"1"];
    [tour06 addObject:@"115"];
    [tour06 addObject:@"Lab"];
    [tour06 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour06 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour06 addObject:@"33796"];
    [tour06 addObject:@"27444"];
    [tour06 addObject:@"1"];
    
    [tour07 addObject:@"URBN 120"];
    [tour07 addObject:@"lab_103_1"];
    [tour07 addObject:@"1"];
    [tour07 addObject:@"120"];
    [tour07 addObject:@"Lab"];
    [tour07 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour07 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour07 addObject:@"33796"];
    [tour07 addObject:@"27444"];
    [tour07 addObject:@"1"];
    
    [tour08 addObject:@"URBN 117"];
    [tour08 addObject:@"lab_103_1"];
    [tour08 addObject:@"1"];
    [tour08 addObject:@"103"];
    [tour08 addObject:@"Lab"];
    [tour08 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour08 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour08 addObject:@"33796"];
    [tour08 addObject:@"27444"];
    [tour08 addObject:@"1"];
    
    [tour09 addObject:@"URBN 117"];
    [tour09 addObject:@"lab_103_1"];
    [tour09 addObject:@"1"];
    [tour09 addObject:@"117"];
    [tour09 addObject:@"Lab"];
    [tour09 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour09 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour09 addObject:@"33796"];
    [tour09 addObject:@"27444"];
    [tour09 addObject:@"1"];
    
    [tour10 addObject:@"URBN 130"];
    [tour10 addObject:@"lab_103_1"];
    [tour10 addObject:@"1"];
    [tour10 addObject:@"130"];
    [tour10 addObject:@"Lab"];
    [tour10 addObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    [tour10 addObject:@"Feature 1, Feature 2, Feature 3"];
    [tour10 addObject:@"33796"];
    [tour10 addObject:@"27444"];
    [tour10 addObject:@"1"];
    
    
    
    _tourStop01 = tour01;
    _tourStop02 = tour02;
    _tourStop03 = tour03;
    _tourStop04 = tour04;
    _tourStop05 = tour05;
    _tourStop06 = tour06;
    _tourStop07 = tour07;
    _tourStop08 = tour08;
    _tourStop09 = tour09;
    _tourStop10 = tour10;
    
    
}

- (void)passLocationToLocator:(IDSCoordinate *)location {
    NSLog(@"testing %@", location);
}

- (void)indoorsSetup
{
    NSLog(@"*** indoorsSetup ***");
    
    
    __unused Indoors *indoors = [[Indoors alloc] initWithLicenseKey:_apiKey andServiceDelegate:self]; // REPLACE WITH YOUR API KEY
    _indoorsSurfaceViewController = [[ISIndoorsSurfaceViewController alloc] init];
    _indoorsSurfaceViewController.delegate = self;
    [self addSurfaceAsChildViewController];
    [_indoorsSurfaceViewController loadBuildingWithBuildingId:_buildingNorm]; // REPLACE WITH YOUR BUILDING ID
}

- (void)addSurfaceAsChildViewController
{
    NSLog(@"*** addSurfaceAsChildViewController ***");
    
    [self addChildViewController:_indoorsSurfaceViewController];
    // _indoorsSurfaceViewController.view.frame = self.view.frame;
    _indoorsSurfaceViewController.view.frame = self.mainView.frame;
    [self.mainView addSubview:_indoorsSurfaceViewController.view];
    //[self.view addSubview:_indoorsSurfaceViewController.view];
    [_indoorsSurfaceViewController didMoveToParentViewController:self];
    
    if ( _accessibilityNeededStatus == false) {
        
        [_indoorsSurfaceViewController.surfaceView setSize:(CGRect){0, 0, _screenWidth, _screenHeight}];
    }
    
    // Change background color of child view
    _indoorsSurfaceViewController.surfaceView.backgroundColor  = [UIColor colorWithRed:102.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0];
}



#pragma mark - IndoorsServiceDelegate
- (void)connected
{
    NSLog(@"*** Building Connected ***");
}

- (void)onError:(IndoorsError *)indoorsError
{
    NSLog(@"*** onError ***");
}

- (void)locationAuthorizationStatusDidChange:(IDSLocationAuthorizationStatus)status
{
    NSLog(@"*** locationAuthorizationStatusDidChange ***");
    if (status == 0) {
        // 0 = bluetooth on
        NSLog(@"locationAuthorizationStatusDidChange is ON (0)");
    } else if (status == 1) {
        // 1 = bluetooth off
        NSLog(@"locationAuthorizationStatusDidChange is OFF (1)");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops"
                                                                       message:@"Looks like your bluetooh is turned off. Please turn on your bluetooh in order for this app to work. "
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Turn on Bluetooth"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                            //do the CONFIRM stuff here
                                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
                                                        }];
        
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)bluetoothStateDidChange:(IDSBluetoothState)bluetoothState
{
    NSLog(@"*** bluetoothStateDidChange ***");
    
    if (bluetoothState == 0) {
        // 0 = bluetooth on
        
        NSLog(@"Bluetooth is ON (0)");
        
    } else if (bluetoothState == 1) {
        // 1 = bluetooth off
        
        NSLog(@"Bluetooth is OFF (1)");
        //
        //        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops"
        //                                                                       message:@"Looks like your bluetooh is turned off. Please turn on your bluetooh in order for this app to work. "
        //                                                                preferredStyle:UIAlertControllerStyleAlert];
        //
        //        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Turn on Bluetooth"
        //                                                          style:UIAlertActionStyleDefault
        //                                                        handler:^(UIAlertAction * _Nonnull action) {
        //
        //                                                            //do the CONFIRM stuff here
        //                                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
        //                                                        }];
        //
        //        [alert addAction:confirm];
        //
        //        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - ISIndoorsSurfaceViewControllerDelegate
- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController isLoadingBuildingWithBuildingId:(NSUInteger)buildingId progress:(NSUInteger)progress
{
    
    NSLog(@"Building loading progress: %lu", (unsigned long)progress);
    
    NSString* percentage = [NSString stringWithFormat:@"%ld%%", (long)progress];
    _loadingPercentage.text = percentage;
    
    // Replace text when it hits 100%.
    if ([percentage isEqualToString:@"100%"]) {
        _loadingPercentage.hidden = true;
        _buildingDownloadHeaderText.text = @"Just making everything pretty for you";
    }
    
    // Add overlay for loading screen
    
}

- (IBAction)offlineHelperText:(id)sender {
    
    _alertTitle = @"Offline Mode";
    _alertMessage = @"Until our app can find you, it thinks you're at the front entrance to the URBN Center. Once the app finds your current location, we'll be back online!";
    _alertActionTitle = @"I understand";
    _alertURLWithString = @"";
    //commented because bad for user good for developer
    [self alertGlobal];
}


- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController didFinishLoadingBuilding:(IDSBuilding *)building
{
    NSLog(@"*** Building loaded SUCCESS ****");
    
    if (_accessibilityNeededStatus == true) {
        NSLog(@"Modal is up, dismissing this modal.");
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    _viewDownloadingBuilding.hidden = true;
    _accessibilityNeededStatus = false;
    
    
    if (self.currentXCoordinate == 52209 && self.currentYCoordinate == 49648 && self.currentZCoordinate == 1 ) {
        [self performSegueWithIdentifier:@"showGettingPositionModal" sender:self];
        self.loadingModalisUp = true;
    } else {
        self.loadingModalisUp = false;
        
    }
    [self.navigationController setNavigationBarHidden:false animated:false];
    
    //
    //    // Figure out the status of In Route Mode
    //    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"inRouteStatus"];
    //    bool status = value;
    //    NSLog(@"ssss %@", value);
    //
    //
    //    if (status == 0) {
    //        NSLog(@"Building is still inRouteMode");
    //        [self.navigationController setNavigationBarHidden:true animated:false];
    //    } else {
    //        NSLog(@"Building is NOT inRouteMode");
    //        [self.navigationController setNavigationBarHidden:false animated:false];
    //    }
    
    
    // [self canNotFindCurrentPosition];
    
    
    
    NSLog(@"SELECTED FLOOR %@", _selectedFloorLevel);
    
    
    //     Building Info
    NSInteger BuildingID = building.buildingID;
    NSInteger buildingLat = building.latOrigin;
    NSInteger buildingLon = building.lonOrigin;
    NSString *buildingName = building.name;
    NSString *buildingDescription = building.buildingDescription;
    
    NSLog(@"Building ID: %ld", (long)BuildingID);
    NSLog(@"Building Lat: %ld", (long)buildingLat);
    NSLog(@"Building Lon: %ld", (long)buildingLon);
    NSLog(@"Building Name: %ld", (long)buildingName);
    NSLog(@"Building Description: %ld", (long)buildingDescription);
    
    
    
    
    
    
    //    if (_zoneList.count == 0) {
    //        NSLog(@"Zone List is empty. Looping through zones and adding that data to new array");
    //
    //        // Intitate NSMutableArray called allZones
    //        NSMutableArray *allZones = [[NSMutableArray alloc] init];
    //
    //        // NSMutableArray *allZones = [NSMutableArray array];
    //        for (IDSFloor *floor in building.floors.allValues) {
    //            [allZones addObjectsFromArray:floor.zones];
    //
    //            NSUInteger flooI=0;
    //            //NSLog(@"Looping through Floor Round: %lu", (unsigned long)flooI);
    //            flooI ++;
    //
    //            // Current Floor Info
    //            //        NSLog(@"Floor Object: %@", floor);
    //            //        NSLog(@"Floor Name: %@", floor.name);
    //            //        NSLog(@"Floor Level: %ld", floor.level);
    //            //        NSLog(@"Floor ID: %ld", floor.floorID);
    //            //        NSLog(@"Floor Description: %@", floor.floorDescription);
    //            //        NSLog(@"Floor Height: %d", floor.mmHeight);
    //            //        NSLog(@"Floor Width: %d", floor.mmWidth);
    //
    //
    //
    //
    //
    //            // Take interger covert into string
    //            NSString* floorLevel = [NSString stringWithFormat:@"%ld", (long)floor.level];
    //
    //            NSString *floorName = floor.name;
    //
    //            NSUInteger zoneCount = allZones.count;
    //            // NSLog(@"%@'s Zone Count: %lu", floor.name, (unsigned long)zoneCount);
    //
    //            // Loop through all zones on the floor
    //            for (NSUInteger i=0; i<zoneCount; i++) {
    //                //    NSLog(@"Looping through zone round: %lu", (unsigned long)i);
    //
    //                id zone = [allZones objectAtIndex:i];
    //                //            NSLog(@"%@ Zone Object: %@",[zone name], zone);
    //                //            NSLog(@"%@ OBJ Name: %@",[zone name], [zone name]);
    //                //            NSLog(@"%@ OBJ Floor: %lu",[zone name], (unsigned long)[zone floor_id]);
    //                //            NSLog(@"%@ OBJ Zone: %ld",[zone name], [zone zone_id]);
    //                //            NSLog(@"%@ OBJ Description: %@",[zone name], [zone zoneDescription]);
    //                //            NSLog(@"%@ OBJ Points: %@", [zone name],[zone points]);
    //
    //
    //                NSString *zoneName = [zone name];
    //
    //
    //
    //                // Intializing NSMutable Array
    //                NSMutableArray *pointsArray = [NSMutableArray array];
    //
    //                // Add all zone points into points array
    //                [pointsArray addObjectsFromArray:[zone points]];
    //
    //
    //                //  NSString *currentZoneName = [zone name];
    //
    //                // Grab value from first points
    //                id firstZone = [pointsArray objectAtIndex:0];
    //                //            NSLog(@"Points at: %@", firstZone);
    //                //
    //                //            //Key-Value Coding (KVC):
    //                //            NSLog(@"%@ First Point Object %lu: X Coordinate: %@", currentZoneName, (unsigned long)i,[firstZone valueForKey:@"x"]);
    //                //            NSLog(@"%@ First Point Object %lu: Zonepoint ID: %@", currentZoneName, (unsigned long)i, [firstZone valueForKey:@"zonepoint_id"]);
    //                //            NSLog(@"%@ First Point Object %lu: Y Coordinate: %@", currentZoneName, (unsigned long)i,[firstZone valueForKey:@"y"]);
    //                //            NSLog(@"%@ First Point Object %lu: Points Sort Order: %@", currentZoneName, (unsigned long)i,[firstZone valueForKey:@"sortOrder"]);
    //
    //
    //                // Creating Variables
    //                NSString *zoneXCoordinate = [firstZone valueForKey:@"x"];
    //                NSString *zoneYCoordinate = [firstZone valueForKey:@"y"];
    //
    //
    //
    //                // Creating Dictionary to hold data
    //                NSDictionary *zoneInfo = @{
    //                                           @"name": zoneName,
    //                                           @"floorName": floorName,
    //                                           @"floorLevel": floorLevel,
    //                                           @"xCoordinate": zoneXCoordinate,
    //                                           @"yCoordinate": zoneYCoordinate
    //                                           };
    //                // Add object to zonelist Array
    //                [self.zoneList addObject:zoneInfo];
    //
    //
    //            }
    //        }
    //        //  NSLog(@"list of zones%@", _zoneList);
    //    } else {
    //        NSLog(@"Zone List is filled with %ld zones", _zoneList.count);
    //    }
    
    
}

-(void)loadMainBuilding {
    [self addSurfaceAsChildViewController];
    [_indoorsSurfaceViewController loadBuildingWithBuildingId:_buildingNorm]; // REPLACE WITH YOUR BUILDING ID
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:_currentZCoordinate];
}

-(void)loadAccessibleBuilding {
    [self addSurfaceAsChildViewController];
    [_indoorsSurfaceViewController loadBuildingWithBuildingId:_buildingAccessible];
    [self canNotFindCurrentPosition];
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:_currentZCoordinate];
    
}


- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController didFailLoadingBuildingWithBuildingId:(NSUInteger)buildingId error:(NSError *)error
{
    NSLog(@"*** Loading Building Failed with error: %@ ***", error);
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Whoops, there was an error"
                                  message: error.localizedFailureReason
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
}


/*
 Defining user position image.
 - Will be used when orientation is known
 - when userPositionIconIndicatesUserOrientation is set to YES.
 
 Define circle accruacy color.
 
 */
-(void) styling {
    NSLog(@"*** styling ***");
    
    [_indoorsSurfaceViewController.surfaceView setUserPositionDisplayMode:IndoorsSurfaceUserPositionDisplayModeCustom];
    // This icon will be used when the user's orientation is known
    // and userPositionIconIndicatesUserOrientation is set to YES.
    _indoorsSurfaceViewController.surfaceView.userPositionIcon = [UIImage imageNamed:@"icon_map-arrow"];
    
    // Change color of accuracy to clearColror
    [_indoorsSurfaceViewController.surfaceView setUserPositionAccuracyCircleColor:[UIColor clearColor]];
    
}







-(void)slideUpGesture:(UISwipeGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"User Swiped Up from view");
        [self performSegueWithIdentifier:@"showTourTableView" sender:self];
    }];
}

-(void)slideDownGesture:(UISwipeGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"swippeeeee");
        
        
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"*** viewWillAppear ***");
    
    
    //    BOOL notificationIsActive = [[NSUserDefaults standardUserDefaults] boolForKey:@"notificationIsActive"];
    //    if (notificationIsActive == true) {
    //        NSLog(@"Notication is active");
    //    } else {
    //        NSLog(@"Notication is not active");
    //
    //    }
}


#pragma mark - Watch Methods
-(void) watchSession {
    NSLog(@"*** watchSession ***");
    
    // Create WCSession
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    [self updateWatch];
    
}

-(void) updateWatch {
    NSLog(@"*** updateWatch ***");
    
    if (_floorTitle == nil) {
        _floorTitle = @"nil";
    }
    if (_passedRoomName == nil) {
        _passedRoomName = @"nil";
    }
    if (_passedRoomNumber == nil) {
        _passedRoomNumber = @"nil";
    }
    if (_passedDesc == nil) {
        _passedDesc = @"nil";
    }
    if (_passedFeat == nil) {
        _passedFeat = @"nil";
    }
    
    
    
    
    WCSession* session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];
    
    [session sendMessage:@{
                           @"currentFloor":_floorTitle,
                           @"roomDestination":_passedRoomName,
                           @"roomNumber":_passedRoomNumber,
                           @"roomDesc":_passedDesc,
                           @"roomFeat":_passedFeat
                           
                           } replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                               
                           } errorHandler:^(NSError * _Nonnull error) {
                               
                           }];
    
    NSLog(@"Current Floor Label: %@, Current Destination Label: %@, Current Room Number: %@, Current Room Description: %@, Current Room feature %@", _floorTitle, _passedRoomName, _passedRoomNumber, _passedDesc, _passedFeat);
    
    
    
}






#pragma mark - Displaying Buttons



-(void) stopCalculation
{
    NSLog(@"*** stopCalculation ***");
    
    [self viewDidLoad];
}


#pragma mark - Removing Views
-(void) test
{
    NSLog(@"*** test ***");
}

#pragma mark - Button Actions
- (IBAction)tappedSearchButton:(id)sender {
    
    
    [self removingAnyPopups];
    
    NSLog(@"*** tappedSearchButton ***");
    
}


- (IBAction)tappedTourButton:(id)sender {
    NSLog(@"*** tappedTourButton ***");
    
}

- (IBAction)tappedFindRestroomButton:(id)sender {
    
    NSLog(@"*** tappedFindRestroomButton ***");
    
    // Button has been clicked and is no active
    if (self.restroomTriggerStatus == false) {
        NSLog(@" Restroom button status: Active");
        [self removingAnyPopups];
        self.restroomTriggerStatus = true;
        self.restroomButton.selected = YES;// Change the image state of the button
        
        // Display the hidden buttons
        self.restroomUnisexButton.hidden = false;
        self.restroomWomensButton.hidden = false;
        self.restroomMensButton.hidden = false;
        
        self.floor3A.hidden = true;
        self.floor4.hidden = true;
        self.floor4A.hidden = true;
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             
                             [self.restroomMensButton setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.restroomWomensButton setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.restroomUnisexButton setTransform:CGAffineTransformMakeTranslation(0,0)];
                             self.restroomMensButton.alpha = 1;
                             self.restroomWomensButton.alpha = 1;
                             self.restroomUnisexButton.alpha = 1;
                             
                         }
                         completion:^(BOOL finished){
                         }];
        
    } else if (self.restroomTriggerStatus == true ){// Button has been clicked and now is not active so hide everything
        NSLog(@" Restroom button status: Normal");
        [self removingAnyPopups];
        self.restroomTriggerStatus = false;
        self.restroomButton.selected = NO;// Change button status to default
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             [self.restroomMensButton setTransform:CGAffineTransformMakeTranslation(0,150)];
                             [self.restroomWomensButton setTransform:CGAffineTransformMakeTranslation(0,100)];
                             [self.restroomUnisexButton setTransform:CGAffineTransformMakeTranslation(0,50)];
                             self.restroomMensButton.alpha = 0;
                             self.restroomWomensButton.alpha = 0;
                             self.restroomUnisexButton.alpha = 0;
                             
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (IBAction)tappedFloorChangeButton:(id)sender {
    NSLog(@"*** tappedFloorChangeButton ***");
    
    
    
    // Button has been triggered
    if (self.floorChangeTriggerStatus == false) {
        NSLog(@" Triggered On");
        
        [self removingAnyPopups];
        self.floorChangeTriggerStatus = true;
        
        // Change button status to selected
        self.selectFloorButton.selected = YES;
        
        
        // Hide bathroom buttons if exist
        self.restroomUnisexButton.hidden = true;
        self.restroomWomensButton.hidden = true;
        self.restroomMensButton.hidden = true;
        
        // Show all possible floors
        self.floor1.hidden = false;
        self.floor1A.hidden = false;
        self.floor2.hidden = false;
        self.floor2A.hidden = false;
        self.floor3.hidden = false;
        self.floor3A.hidden = false;
        self.floor4.hidden = false;
        self.floor4A.hidden = false;
        
        
        
        [UIView animateWithDuration:0.4
                         animations:^{
                             [self.floor1 setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.floor1A setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.floor2 setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.floor2A setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.floor3 setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.floor3A setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.floor4 setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.floor4A setTransform:CGAffineTransformMakeTranslation(0,0)];
                             self.floor1.alpha = 1;
                             self.floor1A.alpha = 1;
                             self.floor2.alpha = 1;
                             self.floor2A.alpha = 1;
                             self.floor3.alpha = 1;
                             self.floor3A.alpha = 1;
                             self.floor4.alpha = 1;
                             self.floor4A.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        
        
        
        
        
    } else if (self.floorChangeTriggerStatus == true ){
        NSLog(@" Triggered Off");
        
        [self removingAnyPopups];
        self.floorChangeTriggerStatus = false;
        
        // Change button status to default
        self.selectFloorButton.selected = NO;
        
        // Show all possible floors
        self.floor1.hidden = true;
        self.floor1A.hidden = true;
        self.floor2.hidden = true;
        self.floor2A.hidden = true;
        self.floor3.hidden = true;
        self.floor3A.hidden = true;
        self.floor4.hidden = true;
        self.floor4A.hidden = true;
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self.floor1 setTransform:CGAffineTransformMakeTranslation(0,0)];
                             [self.floor1A setTransform:CGAffineTransformMakeTranslation(0,40)];
                             [self.floor2 setTransform:CGAffineTransformMakeTranslation(0,80)];
                             [self.floor2A setTransform:CGAffineTransformMakeTranslation(0,120)];
                             [self.floor3 setTransform:CGAffineTransformMakeTranslation(0,160)];
                             [self.floor3A setTransform:CGAffineTransformMakeTranslation(0,200)];
                             [self.floor4 setTransform:CGAffineTransformMakeTranslation(0,240)];
                             [self.floor4A setTransform:CGAffineTransformMakeTranslation(0,280)];
                             
                             self.floor1.alpha = 0;
                             self.floor1A.alpha = 0;
                             self.floor2.alpha = 0;
                             self.floor2A.alpha = 0;
                             self.floor3.alpha = 0;
                             self.floor3A.alpha = 0;
                             self.floor4.alpha = 0;
                             self.floor4A.alpha = 0;
                             
                         }
                         completion:^(BOOL finished){
                         }];
        
        
        
    }
    
}

/*!
 This looks for your current Z index and switches the floor to be your current floor.
 */
- (IBAction)tappedCurrentPosition:(id)sender {
    NSLog(@"*** tappedCurrentPosition ***");
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:_currentZCoordinate];
}

- (IBAction)accessibilitySwitchAction:(id)sender {
    NSLog(@"*** accessibilitySwitchAction ***");
//    
//    
//    if([sender isSelected]){
//        NSLog(@"Switch is disabled (gray)");
//        
//        // Regular Map
//        [sender setSelected:NO];
//        self.accessibilityNeededStatus = false;
//        [self loadMainBuilding];
//        [self inRouteStatusYES];
//        [self inRouteModeLayout];
//        
//        
//    } else {
//        NSLog(@"Switch is enabled (green)");
//        
//        // Map with Elevators
//        [sender setSelected:YES];
//        self.accessibilityNeededStatus = true;
//        [self loadAccessibleBuilding];
//        [self inRouteStatusYES];
//        [self inRouteModeLayout];
//        [self.navigationController setNavigationBarHidden:true animated:false];
//        
//        
//    }
//    
}
/*!
 This calls the calculate route method
 - In Route Status = YES
 */
- (IBAction)startCalculationRouteMethod:(id)sender {
    NSLog(@"*** startCalculationRouteMethod ***");
    [self inRouteStatusYES];
    [self calculateRoute];
}

- (IBAction)getCurrentPositionButton:(id)sender {
    NSLog(@"*** getCurrentPositionButton ***");
    
}



#pragma mark - Floor Selection

- (IBAction)tappedFloor1:(id)sender {
    NSLog(@"*** tappedFloor1 ***");
    self.floorSelected = 1;
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:1];
}

- (IBAction)tappedFloor1A:(id)sender {
    NSLog(@"*** tappedFloor1A ***");
    self.floorSelected = 2;
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:2];
    
}
- (IBAction)tappedFloor2:(id)sender {
    NSLog(@"*** tappedFloor2 ***");
    self.floorSelected = 3;
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:3];
    
}
- (IBAction)tappedFloor2A:(id)sender {
    NSLog(@"*** tappedFloor2A ***");
    self.floorSelected = 4;
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:4];
    
}
- (IBAction)tappedFloor3:(id)sender {
    NSLog(@"*** tappedFloor3 ***");
    self.floorSelected = 5;
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:5];
    
}
- (IBAction)tappedFloor3A:(id)sender {
    NSLog(@"*** tappedFloor3A ***");
    self.floorSelected = 6;
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:6];
    
}
- (IBAction)tappedFloor4:(id)sender {
    NSLog(@"*** tappedFloor4 ***");
    self.floorSelected = 7;
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:7];
}

- (IBAction)tappedFloor4A:(id)sender {
    NSLog(@"*** tappedFloor4A ***");
    self.floorSelected = 8;
    [_indoorsSurfaceViewController.surfaceView setFloorLevel:8];
}
#pragma mark - Restroom Routing
- (IBAction)tappedFindMensBathroom:(id)sender {
    NSLog(@"*** tappedFindMensBathroom ***");
    
    //set for the calculate route for passing the restroom cordinates
    _isBathroom = true;
    [self removingAnyPopups];
    [self inRouteModeLayout];
    if (_currentZCoordinate == 1) { // Floor 1
        
        _inRouteDestinationLabel.text = @"Mens Restroom Floor 1";
        _accessibilityDestName = @"Mens Restroom Floor 1";
        _restroomXCoordinate = 52605;
        _restroomYCoordinate = 20974;
        _restroomZCoordinate = _currentZCoordinate;
        
        
        
        
        
    }else if (_currentZCoordinate == 2) { // Floor 1A
        _inRouteDestinationLabel.text = @"Mens Restroom Floor 1A";
        _accessibilityDestName = @"Mens Restroom Floor 2";
        _restroomXCoordinate = 51346;
        _restroomYCoordinate = 20652;
        _restroomZCoordinate = 3;
        
        
        
        
    }
    
    else if (_currentZCoordinate == 3) { // Floor 2
        _inRouteDestinationLabel.text = @"Mens Restroom Floor 2";
        _accessibilityDestName = @"Mens Restroom Floor 2";
        _restroomXCoordinate = 51346;
        _restroomYCoordinate = 20652;
        _restroomZCoordinate = _currentZCoordinate;
        
        
        
    } else if (_currentZCoordinate == 4) { // Floor 2A
        _inRouteDestinationLabel.text = @"Mens Restroom Floor 2A";
        _accessibilityDestName = @"Mens Restroom Floor 2A";
        _restroomXCoordinate = 51346;
        _restroomYCoordinate = 20652;
        _restroomZCoordinate = 3;
        
        
        
    }
    
    else if (_currentZCoordinate == 5) { // Floor 3
        _inRouteDestinationLabel.text = @"Mens Restroom Floor 3";
        _accessibilityDestName = @"Mens Restroom Floor 3";
        _restroomXCoordinate = 52019;
        _restroomYCoordinate = 20403;
        _restroomZCoordinate = _currentZCoordinate;
        
        
    }  else if (_currentZCoordinate == 6) { // Floor 3A
        
        _inRouteDestinationLabel.text = @"Mens Restroom Floor 3A";
        _accessibilityDestName = @"Mens Restroom Floor 3A";
        _restroomXCoordinate = 52019;
        _restroomYCoordinate = 20403;
        _restroomZCoordinate = 5;
        
        
    }
    else if (_currentZCoordinate == 7) { // Floor 4
        
        _inRouteDestinationLabel.text = @"Mens Restroom Floor 4";
        _accessibilityDestName = @"Mens Restroom Floor 4";
        _restroomXCoordinate = 51112;
        _restroomYCoordinate = 19730;
        _restroomZCoordinate = _currentZCoordinate;
        
        
    }else if (_currentZCoordinate == 8) { // Floor 4A
        
        _inRouteDestinationLabel.text = @"Mens Restroom Floor 4A";
        _accessibilityDestName = @"Mens Restroom Floor 4A";
        _restroomXCoordinate = 51112;
        _restroomYCoordinate = 19730;
        _restroomZCoordinate = 7;
        
        
    }  else { // Floor is an "A" level
        //for error checking
        NSLog(@"No restroom on this floor");
        _alertTitle = @"Sorry";
        _alertMessage = @"They are no restrooms on this floor";
        _alertActionTitle = @"Ok";
        _alertURLWithString = @"";
    }
    
    IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
    IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
    [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
    
    
}

- (IBAction)tappedFindWomensBathroom:(id)sender {
    
    //set for the calculate route for passing the restroom cordinates
    _isBathroom = true;
    
    [self removingAnyPopups];
    [self inRouteModeLayout];
    NSLog(@"*** tappedFindWomensBathroom ***");
    if (_currentZCoordinate == 1) { // Floor 1
        _inRouteDestinationLabel.text = @"Womens Restroom Floor 1";
        _accessibilityDestName = @"Womens Restroom Floor 1";
        _restroomXCoordinate = 52605;
        _restroomYCoordinate = 20974;
        _restroomZCoordinate = _currentZCoordinate;
        
    }else if (_currentZCoordinate == 2) { // Floor 1A
        
        _inRouteDestinationLabel.text = @"Womens Restroom Floor 1A";
        _accessibilityDestName = @"Womens Restroom Floor 1A";
        _restroomXCoordinate = 51668;
        _restroomYCoordinate = 25278;
        _restroomZCoordinate = 3;
        
    }
    else if (_currentZCoordinate == 3) { // Floor 2
        
        _inRouteDestinationLabel.text = @"Womens Restroom Floor 2";
        _accessibilityDestName = @"Womens Restroom Floor 2";
        _restroomXCoordinate = 51668;
        _restroomYCoordinate = 25278;
        _restroomZCoordinate = _currentZCoordinate;
        
    }else if (_currentZCoordinate == 4) { // Floor 2A
        
        _inRouteDestinationLabel.text = @"Womens Restroom Floor 2A";
        _accessibilityDestName = @"Womens Restroom Floor 2A";
        _restroomXCoordinate = 51668;
        _restroomYCoordinate = 25278;
        _restroomZCoordinate = 3;
        
    }
    
    else if (_currentZCoordinate == 5) { // Floor 3
        
        _inRouteDestinationLabel.text = @"Womens Restroom Floor 3";
        _accessibilityDestName = @"Womens Restroom Floor 3";
        _restroomXCoordinate = 52195;
        _restroomYCoordinate = 24385;
        _restroomZCoordinate = _currentZCoordinate;
        
    }
    else if (_currentZCoordinate == 6) { // Floor 3A
        
        _inRouteDestinationLabel.text = @"Womens Restroom Floor 3A";
        _accessibilityDestName = @"Womens Restroom Floor 3A";
        _restroomXCoordinate = 52195;
        _restroomYCoordinate = 24385;
        _restroomZCoordinate = 5;
        
    }
    
    
    else if (_currentZCoordinate == 7) { // Floor 4
        
        _inRouteDestinationLabel.text = @"Womens Restroom Floor 4";
        _accessibilityDestName = @"Womens Restroom Floor 4";
        _restroomXCoordinate = 51112;
        _restroomYCoordinate = 19730;
        _restroomZCoordinate = _currentZCoordinate;
        
    }  else if (_currentZCoordinate == 8) { // Floor 4A
        
        _inRouteDestinationLabel.text = @"Womens Restroom Floor 4A";
        _accessibilityDestName = @"Womens Restroom Floor 4A";
        _restroomXCoordinate = 51112;
        _restroomYCoordinate = 19730;
        _restroomZCoordinate = 7;
        
    }
    else { // Floor is an "A" level
        NSLog(@"No restroom on this floor");
        _alertTitle = @"Sorry";
        _alertMessage = @"They are no restrooms on this floor";
        _alertActionTitle = @"Ok";
        _alertURLWithString = @"";
        //commented because annoiying for user good for developer
        //[self alertGlobal];
    }
    
    
    IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
    IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
    [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
    
    
}
- (IBAction)tappedFindUnisexBathroom:(id)sender {
    
    //set for the calculate route for passing the restroom cordinates
    _isBathroom = true;
    
    
    NSLog(@"*** tappedFindUnisexBathroom ***");
    
    [self removingAnyPopups];
    [self inRouteModeLayout];
    if (_currentZCoordinate == 1) { // Floor 1
        _inRouteDestinationLabel.text = @"Unisex Restroom Floor 1";
        _accessibilityDestName = @"Unisex Restroom Floor 1";
        _restroomXCoordinate = 52605;
        _restroomYCoordinate = 20974;
        _restroomZCoordinate = _currentZCoordinate;
        
    }else if (_currentZCoordinate == 2) { // Floor 1A
        
        _inRouteDestinationLabel.text = @"Unisex Restroom Floor 1A";
        _accessibilityDestName = @"Unisex Restroom Floor 1A";
        _restroomXCoordinate = 47672;
        _restroomYCoordinate = 21926;
        _restroomZCoordinate = 3;
        
    }
    else if (_currentZCoordinate == 3) { // Floor 2
        
        _inRouteDestinationLabel.text = @"Unisex Restroom Floor 2";
        _accessibilityDestName = @"Unisex Restroom Floor 2";
        _restroomXCoordinate = 47672;
        _restroomYCoordinate = 21926;
        _restroomZCoordinate = _currentZCoordinate;
        
    }  else if (_currentZCoordinate == 4) { // Floor 2A
        
        _inRouteDestinationLabel.text = @"Unisex Restroom Floor 2A";
        _accessibilityDestName = @"Unisex Restroom Floor 2A";
        _restroomXCoordinate = 47672;
        _restroomYCoordinate = 21926;
        _restroomZCoordinate = 3;
        
    }
    else if (_currentZCoordinate == 5) { // Floor 3
        
        _inRouteDestinationLabel.text = @"Unisex Restroom Floor 3";
        _accessibilityDestName = @"Unisex Restroom Floor 3";
        _restroomXCoordinate = 52195;
        _restroomYCoordinate = 24385;
        _restroomZCoordinate = _currentZCoordinate;
        
    }else if (_currentZCoordinate == 6) { // Floor 3A
        
        _inRouteDestinationLabel.text = @"Unisex Restroom Floor 3";
        _accessibilityDestName = @"Unisex Restroom Floor 4";
        _restroomXCoordinate = 52195;
        _restroomYCoordinate = 24385;
        _restroomZCoordinate = 5;
        
    }
    else if (_currentZCoordinate == 7) { // Floor 4
        
        _inRouteDestinationLabel.text = @"Unisex Restroom Floor 4";
        _accessibilityDestName = @"Unisex Restroom Floor 5";
        _restroomXCoordinate = 47775;
        _restroomYCoordinate = 21662;
        _restroomZCoordinate = _currentZCoordinate;
        
    }    else if (_currentZCoordinate == 8) { // Floor 4A
        
        _inRouteDestinationLabel.text = @"Unisex Restroom Floor 4A";
        _accessibilityDestName = @"Unisex Restroom Floor 4A";
        _restroomXCoordinate = 47775;
        _restroomYCoordinate = 21662;
        _restroomZCoordinate = 7;
        
    } else { // Floor is an "A" level
        NSLog(@"No restroom on this floor");
        //alert good for eror checking
        _alertTitle = @"Sorry";
        _alertMessage = @"They are no restrooms on this floor";
        _alertActionTitle = @"Ok";
        _alertURLWithString = @"";
        //commented because annoiying for user good for developer
        //[self alertGlobal];
    }
    
    
    IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
    IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
    [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
    
}



#pragma mark - inRouteStatus
-(void) inRouteStatusYES {
    NSLog(@"*** inRouteStatusYES ***");
    bool inRouteStatus = true;
    [[NSUserDefaults standardUserDefaults] setValue:@(inRouteStatus) forKey:@"inRouteStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"inRouteStatus = Yes");
    
}

-(void) inRouteStatusNO {
    NSLog(@"*** inRouteStatusNO ***");
    bool inRouteStatus = false;
    [[NSUserDefaults standardUserDefaults] setValue:@(inRouteStatus) forKey:@"inRouteStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"inRouteStatus = No");
    self.inRouteNavView.hidden = true;
    
}

// Routing
- (void)calculateRoute
{
    NSLog(@"*** calculateRoute ***");
    
    // Figure out the status of In Route Mode
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"inRouteStatus"];
    bool status = value;
    if (status == true) {
        NSLog(@"*** inRouteStatus = YES ***");
        self.inRouteView.hidden = true;
        
        // If inRouteMode is currently enabled. When user close's the app, send a local nofication.
        [self inRouteStatusYES];
        
        
        // Change layout to "In Route Mode"
        
        //if its for the bathroom button use the restroom coordinates
        if ( _isBathroom){
            
            // Convert Strings to intergers
            _destXCoordinate = _restroomXCoordinate;
            _destYCoordinate = _restroomYCoordinate;
            _destZCoordinate = _restroomZCoordinate;
            _isBathroom = false;
            
        } else{
            // Convert Strings to intergers
            _destXCoordinate = _passedX.integerValue;
            _destYCoordinate = _passedY.integerValue;
            _destZCoordinate = _passedZ.integerValue;
            
        }
        
        if (_passedDest == false){
            _destZCoordinate = 0;
        }
        
        // Added User current Position
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        
        
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_destXCoordinate andY:_destYCoordinate andFloorLevel:_destZCoordinate];
        
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        
        
        
    } else {
        NSLog(@"*** inRouteStatus = NO ***");
        // Disable notifaction
        [self inRouteStatusNO];
        
        
    }
    
    
    
    
    
}
//when closing the the route
//set the desitation to zero
//call calculateRoute to nuffily the path that is being displayed
- (IBAction)cancleInRouteMode:(id)sender {
    NSLog(@"*** cancelInRouteMode ***");
    
    // Clear Route
    IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
    IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_destXCoordinate andY:_destYCoordinate andFloorLevel:0];
    
    [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];    _passedDest = true;
    
    
    _takingATourStatus = false;
    
    [self removingAnyPopups];
    
    self.selectFloorButton.hidden = false;
    self.takeTourButton.hidden = false;
    self.currentPositionButton.hidden = false;
    self.restroomButton.hidden = false;
    
    
    // Add new view
    self.inRouteView.hidden = true;
    self.takeATourBottomView.hidden = true;
    
    
    
    // Disable inRoute Notificatoin
    [self inRouteStatusNO];
    
    
    // Change variable values for watch to show/hide correct labels. Watch looks for string named "nil"
    _passedRoomName = @"nil";
    _passedRoomNumber = @"nil";
    _passedDesc = @"nil";
    _passedFeat = @"nil";
    [self updateWatch];
    
    
    
    // Show original Navigation Bar
    [self.navigationController setNavigationBarHidden:false animated:false];
    
}




- (IBAction)takeATourInfoButton:(id)sender {
    NSLog(@"*** takeATourInfoButton ***");
    [self performSegueWithIdentifier: @"segueToRoomDetailsModal" sender: self];
    
    
}






#pragma mark - RoutingDelegate
- (void)setRoute:(NSArray *)path
{
    NSLog(@"*** setRoute ***");
    
    // IDSCoordinate objects representing the path and color change and line width
    [_indoorsSurfaceViewController.surfaceView showPathWithPoints:path color:[UIColor colorWithRed:15.0/255 green:191.0/255 blue:0.0/255 alpha:1.0] lineWidth:4];
    
    //NSLog(@"Paths:  %@", path);
    
    NSLog(@"setRoute Ran");
}
/*!
 This removes any views on the scren that isnt needed for the inRouteLayout.
 
 - Hides bottom bar
 - Removes CTA on screen
 */
-(void) removeLayoutForInRouteMode {
    NSLog(@"*** removeLayoutForInRouteMode ***");
    
    // Remove default buttons
    // self.selectFloorButton.hidden = true;
    self.takeTourButton.hidden = true;
    //  self.currentPositionButton.hidden = true;
    self.restroomButton.hidden = true;
}
/*!
 This enables the view for "In Route Mode".
 
 - Hides main nav and display a new one
 
 - Removes the take a tour and find restroom buttons
 */
-(void) inRouteModeLayout
{
    NSLog(@"*** inRouteModeLayout ***");
    [self.navigationController setNavigationBarHidden:true animated:false];
    [self removeLayoutForInRouteMode];
    
    
    [self updateWatch];
    
    self.inRouteHelperText.text = @"DIRECTIONS TO";
    self.inRouteDestinationLabel.text = _accessibilityDestName;
    self.inRouteNavView.hidden = false; // Adding inRoute Nav
    
    if (_takingATourStatus == true) {
        NSLog(@"Currently taking a tour and displaying inRoute layout");
        //pass tour info to applewatch
        _passedRoomName = _currentTourName;
        _passedRoomNumber = _currentTourNumber;
        _passedDesc =  _currentTourDesc ;
        _passedFeat = _currentTourFeatures;
        self.inRouteInfo.hidden = false;
        self.takeATourBottomView.hidden = false;
        
        NSString *label = [NSString stringWithFormat:@"Location %ld/10", (long)_tourCurrentDestValue];
        self.takeATourBottomLabel.text =  label;
        
        _currentTourName = [_tourStop01 objectAtIndex:0];
        _currentTourNumber = [_tourStop01 objectAtIndex:3];
        _currentTourType = [_tourStop01 objectAtIndex:4];
        _currentTourDesc = [_tourStop01 objectAtIndex:5];
        _currentTourFeatures = [_tourStop01 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop01 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop01 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop01 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_destXCoordinate andY:_destYCoordinate andFloorLevel:_destZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        
    } else {
        NSLog(@"Displaying inRoute layout");
        self.inRouteInfo.hidden = true;
        self.inRouteView.hidden = false;
        self.takeATourBottomView.hidden = true;
        self.inRouteDestinationLabel.text = _passedRoomName;
        
        
        // Convert to String to interger
        _destXCoordinate = [_passedX integerValue];
        _destYCoordinate = [_passedY integerValue];
        _destZCoordinate = [_passedZ integerValue];
        
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_destXCoordinate andY:_destYCoordinate andFloorLevel:_destZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        NSLog(@"asdfs  %@", _inRouteDestinationLabel.text);
    }
    
    
}

-(void) updateTourList {
    NSLog(@"*** updateTourList ***");
    
    _tourCurrentDestValue++;
    NSString *label = [NSString stringWithFormat:@"Location %ld/10", (long)_tourCurrentDestValue];
    if (_tourCurrentDestValue == 1) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop01 objectAtIndex:0];
        _currentTourNumber = [_tourStop01 objectAtIndex:3];
        _currentTourType = [_tourStop01 objectAtIndex:4];
        _currentTourDesc = [_tourStop01 objectAtIndex:5];
        _currentTourFeatures = [_tourStop01 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop01 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop01 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop01 objectAtIndex:9];
        
        
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        
    } else if (_tourCurrentDestValue == 2) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop02 objectAtIndex:0];
        _currentTourNumber = [_tourStop02 objectAtIndex:3];
        _currentTourType = [_tourStop02 objectAtIndex:4];
        _currentTourDesc = [_tourStop02 objectAtIndex:5];
        _currentTourFeatures = [_tourStop02 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop02 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop02 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop02 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        
    } else if (_tourCurrentDestValue == 3) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop03 objectAtIndex:0];
        _currentTourNumber = [_tourStop03 objectAtIndex:3];
        _currentTourType = [_tourStop03 objectAtIndex:4];
        _currentTourDesc = [_tourStop03 objectAtIndex:5];
        _currentTourFeatures = [_tourStop03 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop03 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop03 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop03 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        
    } else if (_tourCurrentDestValue == 4) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop04 objectAtIndex:0];
        _currentTourNumber = [_tourStop04 objectAtIndex:3];
        _currentTourType = [_tourStop04 objectAtIndex:4];
        _currentTourDesc = [_tourStop04 objectAtIndex:5];
        _currentTourFeatures = [_tourStop04 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop04 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop04 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop04 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        
    } else if (_tourCurrentDestValue == 5) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop05 objectAtIndex:0];
        _currentTourNumber = [_tourStop05 objectAtIndex:3];
        _currentTourType = [_tourStop05 objectAtIndex:4];
        _currentTourDesc = [_tourStop05 objectAtIndex:5];
        _currentTourFeatures = [_tourStop05 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop05 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop05 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop05 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        
    } else if (_tourCurrentDestValue == 6) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop06 objectAtIndex:0];
        _currentTourNumber = [_tourStop06 objectAtIndex:3];
        _currentTourType = [_tourStop06 objectAtIndex:4];
        _currentTourDesc = [_tourStop06 objectAtIndex:5];
        _currentTourFeatures = [_tourStop06 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop06 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop06 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop06 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        
    } else if (_tourCurrentDestValue == 7) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop07 objectAtIndex:0];
        _currentTourNumber = [_tourStop07 objectAtIndex:3];
        _currentTourType = [_tourStop07 objectAtIndex:4];
        _currentTourDesc = [_tourStop07 objectAtIndex:5];
        _currentTourFeatures = [_tourStop07 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop07 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop07 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop07 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        
    } else if (_tourCurrentDestValue == 8) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop08 objectAtIndex:0];
        _currentTourNumber = [_tourStop08 objectAtIndex:3];
        _currentTourType = [_tourStop08 objectAtIndex:4];
        _currentTourDesc = [_tourStop08 objectAtIndex:5];
        _currentTourFeatures = [_tourStop08 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop08 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop08 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop08 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = @"hey";
        
    } else if (_tourCurrentDestValue == 9) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop09 objectAtIndex:0];
        _currentTourNumber = [_tourStop09 objectAtIndex:3];
        _currentTourType = [_tourStop09 objectAtIndex:4];
        _currentTourDesc = [_tourStop09 objectAtIndex:5];
        _currentTourFeatures = [_tourStop09 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop09 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop09 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop09 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;
        _accessibilityDestName = _currentTourName;
        
    } else if (_tourCurrentDestValue == 10) {
        self.takeATourBottomLabel.text =  label;
        _currentTourName = [_tourStop10 objectAtIndex:0];
        _currentTourNumber = [_tourStop10 objectAtIndex:3];
        _currentTourType = [_tourStop10 objectAtIndex:4];
        _currentTourDesc = [_tourStop10 objectAtIndex:5];
        _currentTourFeatures = [_tourStop10 objectAtIndex:6];
        _currentTourXCoordinate = [_tourStop10 objectAtIndex:7];
        _currentTourYCoordinate = [_tourStop10 objectAtIndex:8];
        _currentTourZCoordinate = [_tourStop10 objectAtIndex:9];
        
        // Convert to String to interger
        _destXCoordinate = [_currentTourXCoordinate integerValue];
        _destYCoordinate = [_currentTourYCoordinate integerValue];
        _destZCoordinate = [_currentTourZCoordinate integerValue];
        
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:_currentXCoordinate andY:_currentYCoordinate andFloorLevel:_currentZCoordinate];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:_restroomXCoordinate andY:_restroomYCoordinate andFloorLevel:_restroomZCoordinate];
        [[Indoors instance] routeFromLocation:start toLocation:end delegate:self];
        
        _inRouteDestinationLabel.text = _currentTourName;        _tourCurrentDestValue = 0;
        _accessibilityDestName = _currentTourName;
    }
    
    //pass tour info to watch
    _passedRoomName = _currentTourName;
    _passedRoomNumber = _currentTourNumber;
    _passedDesc =  _currentTourDesc ;
    _passedFeat = _currentTourFeatures;
    
    
    [self updateWatch];
    
    
}

- (IBAction)nextTourRoomButton:(id)sender {
    NSLog(@"*** nextTourRoomButton ***");
    [self updateTourList];
}



//If you want to react to position changes, you might add something like this
// Add "[[Indoors instance] registerLocationListener:self];" In View did Load
#pragma mark - IndoorsLocationListener
- (void)positionUpdated:(IDSCoordinate *)userPosition
{
    
    
    // NSLog(@"Context Updated %@", userPosition);
    
    if (_currentXCoordinate == 52209 && _currentYCoordinate == 49648 && _currentZCoordinate == 1) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        self.offlineBanner.hidden = true;
    }
    // Updating variable values
    _currentXCoordinate = userPosition.x;
    _currentYCoordinate = userPosition.y;
    _currentZCoordinate = userPosition.z;
    
}

- (void)contextUpdated:(IDSContext *)context {
    NSLog(@"Context Updated %@", context);
    
}

- (void)orientationUpdated:(float)orientation {
    /**
     Current orientation in degrees.
     
     For convenience the angle is relative to the building map, not relative to North.
     More precisely the returned value is the clockwise oriented angle on the x,y
     plane starting at the y-axis.
     
     @param orientation Current orientation in degrees.
     */
    
    
    // Assign orientation degree to this variable.
    self.deviceOrientation = orientation;
    
    
}

- (void)zonesEntered:(NSArray *)zones {
    /**
     The user entered or left a zone.
     
     @param zones All zones containing the current user position.
     */
    NSLog(@"*** zonesEntered ***");
    
    
}

- (void)changedFloor:(int)floorLevel withName:(NSString*)name {
    // The floor has changed. This will be called before you receive position updates for the new floor.
    
    if (self.loadingModalisUp == true) {
        NSLog(@"Modal is up, dismissing this modal.");
        [self dismissViewControllerAnimated:NO completion:nil];
        //self.offlineBanner.hidden = true;
    }
    
    
    ///objective C is not equal to string
    //uncomment out first loading sreen thing
    //make isEqualtoString into isNotEqualToString
    
    NSLog(@"Floor change detected. \rYou are on Level: %d, Name: %@", floorLevel, name);
    
    _floorTitle = name;
    
    // Update navigation bar title when floor changes.
    self.navigationItem.title = _floorTitle;
    
    [self updateWatch];
    
}

- (void)weakSignal {
    // The user position could not be determined. You may use this to display a warning like "low signal, computing...".
    //    UIAlertController * alert=   [UIAlertController
    //                                  alertControllerWithTitle:@"Low Signal"
    //                                  message: @"We are having trouble locating you!"
    //                                  preferredStyle:UIAlertControllerStyleAlert];
    //
    //    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"Your signal is week.");
    
    
}


/*!
 This presents a modal if the user position can not be found
 
 - Determines if the title is "loading"
 
 - If the position was found, the title would be the floor title.
 */
- (void) canNotFindCurrentPosition{
    NSLog(@"canNotFindCurrentPosition Ran");
    NSLog(@"Floor title %@", _floorTitle);
    
    
    if (_accessibilityNeededStatus == true) {
        NSLog(@"Show getting position Modal");
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self performSegueWithIdentifier:@"showGettingPositionModal" sender:self];
        });
        NSLog(@"%@", _accessibilityDestName);
        
    } else {
        if ([_floorTitle isEqualToString:@"Floor 1 "])
        {
            // Display loading screen until map is finished loading
            NSLog(@"Show getting position Modal");
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self performSegueWithIdentifier:@"showGettingPositionModal" sender:self];
            });
            
        } else {
            NSLog(@"Dismiss Modal");
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        
    }
}

- (IBAction)legendButtonAction:(id)sender {
    NSLog(@"*** legendButtonAction ***");
    
    
    
}

#pragma mark - theZones

- (void)theZones
{
    NSLog(@"buildingLoaded Ran");
    
    NSLog(@"buildingLoaded End");
}

- (void)setZones:(NSArray *)zones {
    //  NSLog(@"ZONESSSSS: %@", zones);
}


/*!
 This removes all the modules that might be left on the screen.
 
 - Removes all the floor buttons
 
 - Removes all bathroom buttons
 
 - Removes the selected state of any button
 */

-(void) removingAnyPopups {
    NSLog(@"*** removingAnyPopups ***");
    self.restroomTriggerStatus = false;
    self.floorChangeTriggerStatus = false;
    self.restroomButton.selected = FALSE;
    self.selectFloorButton.selected = FALSE;
    
    
    
    // Remove Bathroom
    self.floor1.hidden = true;
    self.floor1A.hidden = true;
    self.floor2.hidden = true;
    self.floor2A.hidden = true;
    self.floor3.hidden = true;
    self.floor3A.hidden = true;
    self.floor4.hidden = true;
    self.floor4A.hidden = true;
    
    
    // Removing bathroom buttons
    self.restroomMensButton.hidden = true;
    self.restroomUnisexButton.hidden = true;
    self.restroomWomensButton.hidden = true;
    
}


-(void) alertGlobal {
    NSLog(@"*** alertGlobal ***");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_alertTitle
                                                                   message:_alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:_alertActionTitle
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                        //do the CONFIRM stuff here
                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_alertURLWithString]];
                                                    }];
    
    [alert addAction:confirm];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearchResults"])
    {
        NSLog(@"*** tappedSearchButton ***");
        // Hide any other buttons
        self.floor1.hidden = true;
        self.floor1A.hidden = true;
        self.floor2.hidden = true;
        self.floor2A.hidden = true;
        self.floor3.hidden = true;
        self.floor3A.hidden = true;
        self.floor4.hidden = true;
        self.floor4A.hidden = true;
        
    }
    
    // Take a Tour Modal
    if ([[segue identifier] isEqualToString:@"showTakeATourModal"])
    {
        NSLog(@"*** prepareForSegue - showTakeATourModal ***");
        
        //self.modalBackgroundView.hidden = false;
        
        
    } else if ([[segue identifier] isEqualToString:@"showTourTableView"]) {
        NSLog(@"*** prepareForSegue - showTourTableView ***");
        
        TourList *controller = (TourList *)segue.destinationViewController;
        controller.tourCurrentRoomValue = _tourCurrentDestValue;
        NSLog(@"Passed Interger: %ld Tour List VC", (long)_tourCurrentDestValue);
        
    } else if ([[segue identifier] isEqualToString:@"segueToRoomDetailsModal"]) {
        NSLog(@"*** prepareForSegue - segueToRoomDetailsModal ***");
        
        TourRoomDetails *controller = (TourRoomDetails *)segue.destinationViewController;
        controller.name = _currentTourName;
        controller.number = _currentTourNumber;
        controller.desc = _currentTourDesc;
        controller.feat = _currentTourFeatures;
        
        
        
        
        
    } else if ([[segue identifier] isEqualToString:@"showGettingPositionModal"]) {
        NSLog(@"*** prepareForSegue - showGettingPositionModal ***");
        
    }
    
    
    
    
    
    
}



- (IBAction)unwindToMap:(UIStoryboardSegue *)unwindSegue
{
    
    // Check to see where the unwindSegue is coming from
    if ([[unwindSegue identifier] isEqualToString:@"unwindFromGetDirections"]) {
        NSLog(@"*** unwindToMap - From SearchPopOver.swfit");
        
        // If Bathroom button was popped up before going to this screen
        [self removingAnyPopups];
        
        
        
        // Create instance of View Controller
        SearchPopOver *PopOverVC = unwindSegue.sourceViewController;
        
        // Assign the varible on this controller from the source view controller values
        self.passedRoomName = PopOverVC.selectedName.text;
        self.passedX = PopOverVC.selectedX.text;
        self.passedY = PopOverVC.selectedY.text;
        self.passedZ = PopOverVC.selectedZ.text;
        self.passedRoomNumber = PopOverVC.selectedNumber.text;
        self.passedDesc = PopOverVC.selectedDesc.text;
        self.passedFeat = PopOverVC.selectedFeatures.text;
        NSLog(@"Passed name: %@, Passed x: %@, Passed y: %@, Passed z: %@", _passedRoomName, _passedX, _passedY, _passedZ);
        
        // Change Map Layout
        _takingATourStatus = false;
        [self inRouteModeLayout];
        
        
        
        
    } else if ([[unwindSegue identifier] isEqualToString:@"unwindFromSearchVC"]) {
        
        NSLog(@"*** unwindToMap - unwindFromSearchVC ***");
        // If Bathroom button was popped up before going to this screen
        [self removingAnyPopups];
        
        
    } else if ([[unwindSegue identifier] isEqualToString:@"tourModalToMapView"]) {
        NSLog(@"*** unwindToMap - From Tour Modal ***");
        [self removingAnyPopups];
        _takingATourStatus = true;
        [self inRouteModeLayout];
        
        
        
    } else if ([[unwindSegue identifier] isEqualToString:@"tourModalToMapViewExit"]) {
        NSLog(@"*** tourModalToMapViewExit - From Tour Modal Exit ***");
        
    }else if ([[unwindSegue identifier] isEqualToString:@"tourTableToMapSelectRow"]) {
        NSLog(@"*** tourTableToMapSelectRow - From Tour Modal Exit ***");
        
        
        
        
        // Create instance of View Controller
        TourList *TourListVC = unwindSegue.sourceViewController;
        
        // Assign the varible on this controller from the source view controller values
        self.tourCurrentDestValue = [TourListVC.tourBottomLabel.text intValue];
        
        NSLog(@"Received Interger Value from Tour VC %ld", (long)_tourCurrentDestValue);
        [self updateTourList];
        
    }else if ([[unwindSegue identifier] isEqualToString:@"comingFromLoadingModal"]) {
        NSLog(@"*** comingFromLoadingModal ***");
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.offlineBanner setTransform:CGAffineTransformMakeTranslation(0,0)];
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        
    }else {
        NSLog(@"*** unwindToMap - No identfier Found ***");
        // If Bathroom button was popped up before going to this screen
        [self removingAnyPopups];
        
        
    }
}





@end
