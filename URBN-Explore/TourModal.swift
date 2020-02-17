//
//  TakeATourModalController.swift
//  URBN-Explore


import UIKit

class TourModal: UIViewController {

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var clearView: UIView!

    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var startTourButton: UIButton!
    
    let tapRec = UITapGestureRecognizer()

    
    var rooms = [Room]()

    
    @IBOutlet weak var popupView: UIView!
    let tourListVC = TourList()
    
    override func viewDidLoad() {
        print("TakeATourModalController Loaded")
        // Start view from bottom
        self.popupView.transform = CGAffineTransformMakeTranslation(0, 600)
        self.dimView.alpha = 0.0
        popupView.layer.cornerRadius = 10
        popupView.layer.borderColor = UIColor.blackColor().CGColor
        popupView.layer.borderWidth = 0.25
        popupView.layer.shadowColor = UIColor.blackColor().CGColor
        popupView.layer.shadowOpacity = 0.6
        popupView.layer.shadowRadius = 15
        popupView.layer.shadowOffset = CGSize(width: 5, height: 5)
        popupView.layer.masksToBounds = false
        
        startTourButton.layer.cornerRadius = 7
        
        
        //set the target of the gesture recognizers for each view
        tapRec.addTarget(self, action: "tappedOnBG")

        
        //we add the gesture recognizers to the views
        dimView.addGestureRecognizer(tapRec)
        
        //e set the userInteractionEnabled property of each view to true
        dimView.userInteractionEnabled = true
        
        
        
        print(tourListVC.rooms.count)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print("TakeATourModalController Appeared")
        
        // Background Dim View fade
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.dimView.alpha = 0.7
            
            }, completion: {
                (finished: Bool) -> Void in
        })
        
        // Popup View slide from bottom to top animation
        UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.popupView.transform = CGAffineTransformMakeTranslation(0, 0)
            
            }, completion: {
                (finished: Bool) -> Void in
        })
    }
    
    func tappedOnBG(){
        
        print("User tapped on bg to dismiss the view")
        self.performSegueWithIdentifier("tourModalToMapViewExit", sender: self)
        
        
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "tourModalToMapView") {
            
//            if let mapView = segue.destinationViewController as? IDMapViewController {
//                let room: Room
//                
//                //mapView.detailRoom = room
//            }
    
        }
    }
    
    func createRoomStructure() {
        rooms = [
            Room(
                Name:"Building Entrance",
                Zone:"Building Entrance",
                Floor:"1",
                Number:"100",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Advisors Office",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103J",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Audio Lab",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"108",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Archives",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"110",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),     Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            )
        ]
    }


}
