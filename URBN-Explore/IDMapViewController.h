

#import <UIKit/UIKit.h>

@interface IDMapViewController : UIViewController
// String
@property (nonatomic, strong) NSString *passedRoomName;
@property (nonatomic, strong) NSString *passedX;
@property (nonatomic, strong) NSString *passedY;
@property (nonatomic, strong) NSString *passedZ;
@property (nonatomic, strong) NSString *passedRoomNumber;
@property (nonatomic, strong) NSString *passedDesc;
@property (nonatomic, strong) NSString *passedFeat;
@property (nonatomic, strong) NSString *passedType;
@property (nonatomic, strong) NSString *floorTitle;
@property (nonatomic, assign) NSString *selectedFloorLevel;
@property (nonatomic, strong) NSString *destLabel;
@property (nonatomic, strong) NSString *currentTourName;
@property (nonatomic, strong) NSString *currentTourFeatures;
@property (nonatomic, strong) NSString *currentTourDesc;
@property (nonatomic, strong) NSString *currentTourType;
@property (nonatomic, strong) NSString *currentTourNumber;
@property (nonatomic, strong) NSString *currentTourXCoordinate;
@property (nonatomic, strong) NSString *currentTourYCoordinate;
@property (nonatomic, strong) NSString *currentTourZCoordinate;
@property (nonatomic, strong) NSString *accessibilityDestName;
@property (nonatomic, strong) NSString *alertTitle;
@property (nonatomic, strong) NSString *alertMessage;
@property (nonatomic, strong) NSString *alertActionTitle;
@property (nonatomic, strong) NSString *alertURLWithString;

// Bool
@property (nonatomic) BOOL  passedDest;
@property (nonatomic) BOOL  isBathroom;
@property (nonatomic) BOOL floorTriggerd;
@property (nonatomic) BOOL restroomTriggerd;
@property (nonatomic) BOOL calculateRouteTriggered;
@property (assign) BOOL testAtHome;
@property (assign) BOOL loadingModalisUp;
@property (assign) BOOL takingATourStatus;
@property (assign) BOOL restroomTriggerStatus;
@property (assign) BOOL floorChangeTriggerStatus;
@property (assign) BOOL accessibilityNeededStatus;

// Interger
@property (nonatomic, assign) NSInteger tourCurrentDestValue;
@property (nonatomic, assign) NSInteger currentXCoordinate;
@property (nonatomic, assign) NSInteger currentYCoordinate;
@property (nonatomic, assign) NSInteger currentZCoordinate;
@property (nonatomic, assign) NSInteger destXCoordinate;
@property (nonatomic, assign) NSInteger destYCoordinate;
@property (nonatomic, assign) NSInteger destZCoordinate;
@property (nonatomic, assign) NSInteger restroomXCoordinate;
@property (nonatomic, assign) NSInteger restroomYCoordinate;
@property (nonatomic, assign) NSInteger restroomZCoordinate;
@property (nonatomic, assign) NSInteger floorSelected;


// Array
@property (nonatomic, strong) NSMutableArray *zoneList;
@property (nonatomic, strong) NSMutableArray *tourStop01;
@property (nonatomic, strong) NSMutableArray *tourStop02;
@property (nonatomic, strong) NSMutableArray *tourStop03;
@property (nonatomic, strong) NSMutableArray *tourStop04;
@property (nonatomic, strong) NSMutableArray *tourStop05;
@property (nonatomic, strong) NSMutableArray *tourStop06;
@property (nonatomic, strong) NSMutableArray *tourStop07;
@property (nonatomic, strong) NSMutableArray *tourStop08;
@property (nonatomic, strong) NSMutableArray *tourStop09;
@property (nonatomic, strong) NSMutableArray *tourStop10;
// Float
@property (nonatomic) float screenHeight;
@property (nonatomic) float screenWidth;
@property (nonatomic) float deviceOrientation;

// Navigation
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;


// Views
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *offlineBanner;
@property (weak, nonatomic) IBOutlet UIView *viewDownloadingBuilding;
@property (weak, nonatomic) IBOutlet UIView *dimView;
@property (weak, nonatomic) IBOutlet UIView *takeATourBottomView;
@property (weak, nonatomic) IBOutlet UIView *loadingDimView;
@property (weak, nonatomic) IBOutlet UIView *inRouteView;
@property (weak, nonatomic) IBOutlet UIView *inRouteNavView;


// Buttons
@property (weak, nonatomic) IBOutlet UIButton *closeInRouteMode;
@property (weak, nonatomic) IBOutlet UIButton *restroomButton;
@property (weak, nonatomic) IBOutlet UIButton *restroomUnisexButton;
@property (weak, nonatomic) IBOutlet UIButton *restroomWomensButton;
@property (weak, nonatomic) IBOutlet UIButton *restroomMensButton;
@property (weak, nonatomic) IBOutlet UIButton *selectFloorButton;
@property (weak, nonatomic) IBOutlet UIButton *currentPositionButton;
@property (weak, nonatomic) IBOutlet UIButton *floor1;
@property (weak, nonatomic) IBOutlet UIButton *floor1A;
@property (weak, nonatomic) IBOutlet UIButton *floor2;
@property (weak, nonatomic) IBOutlet UIButton *floor2A;
@property (weak, nonatomic) IBOutlet UIButton *floor3;
@property (weak, nonatomic) IBOutlet UIButton *floor3A;
@property (weak, nonatomic) IBOutlet UIButton *floor4;
@property (weak, nonatomic) IBOutlet UIButton *floor4A;
@property (weak, nonatomic) IBOutlet UIButton *takeTourButton;
@property (weak, nonatomic) IBOutlet UIButton *inRouteInfo;
@property (weak, nonatomic) IBOutlet UIButton *takeATourBottomNextButton;
@property (weak, nonatomic) IBOutlet UIButton *offlineHelpButton;
@property (weak, nonatomic) IBOutlet UIButton *legendButton;

// Label
@property (weak, nonatomic) IBOutlet UILabel *loadingPercentage;
@property (weak, nonatomic) IBOutlet UILabel *inRouteDestinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *inRouteHelperText;
@property (weak, nonatomic) IBOutlet UILabel *takeATourBottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildingDownloadHeaderText;

// Switch
@property (weak, nonatomic) IBOutlet UISwitch *accessibilitySwitch;

-(void)slideUpGesture:(UISwipeGestureRecognizer *)gestureRecognizer;
-(void)enablePredefinedRouteSnapping;


// Buidling ids
@property (nonatomic, assign) int buildingNorm;
@property (nonatomic, assign) int buildingAccessible;
@property (nonatomic, strong) NSString *apiKey;
@property (weak, nonatomic) IBOutlet UIButton *startDirectionButton;

@end

@interface FloorView : UIView

@end
