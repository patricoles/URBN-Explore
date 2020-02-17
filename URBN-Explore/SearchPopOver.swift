//
//  SearchPopOver.swift
//  URBN-Explore
//


import UIKit

class SearchPopOver: UIViewController {
    
    @IBOutlet weak var dimissModalBg: UIButton!
    // Images
    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var popupView: UIView!
    // Labels
    @IBOutlet weak var selectedName: UILabel!
    @IBOutlet weak var selectedNumber: UILabel!
    @IBOutlet weak var selectedDesc: UILabel!
    @IBOutlet weak var selectedFeatures: UILabel!
    @IBOutlet weak var selectedX: UILabel!
    @IBOutlet weak var selectedY: UILabel!
    @IBOutlet weak var selectedZ: UILabel!
    
    @IBOutlet weak var features: UILabel!
    // Butons
    @IBOutlet weak var getDirections: UIButton!
    
    // Pass Detail array
    var detailRoom: Room?
    var detailRoomX: Room?
    var detailRoomY: Room?
    var detailRoomZ: Room?
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var bottomDivider: UIView!
    
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var topDivider: UIView!
    
    
    override func viewDidLoad() {
        
        
        popupView.layer.cornerRadius = 10
        popupView.layer.borderColor = UIColor.blackColor().CGColor
        popupView.layer.borderWidth = 0.25
        popupView.layer.shadowColor = UIColor.blackColor().CGColor
        popupView.layer.shadowOpacity = 0.6
        popupView.layer.shadowRadius = 15
        popupView.layer.shadowOffset = CGSize(width: 5, height: 5)
        popupView.layer.masksToBounds = false
        
        getDirections.layer.cornerRadius = 7
        
        if (detailRoom!.Type == "Classroom") {
            let image : UIImage = UIImage(named: "icon_room-class")!
            selectedImage.image = image
        } else if (detailRoom!.Type == "Office")  {
            let image : UIImage = UIImage(named: "icon_room-faculty")!
            selectedImage.image = image
            
            
        } else if (detailRoom!.Type == "Lab")  {
            let image : UIImage = UIImage(named: "icon_room-lab")!
            selectedImage.image = image
        }else if (detailRoom!.Type == "Restroom")  {
            let image : UIImage = UIImage(named: "icon_room-restroom")!
            selectedImage.image = image
            
            
        }
        
        
        selectedName.text = detailRoom?.Name
        selectedNumber.text = detailRoom?.Number
        selectedDesc.text = detailRoom?.Description
        selectedFeatures.text = detailRoom?.Features
        selectedX.text = detailRoom?.XCoordinate
        selectedY.text = detailRoom?.YCoordinate
        selectedZ.text = detailRoom?.ZCoordinate
        features.text = "Features"
       
        
    }
    
    @IBAction func getDirection(segue:UIStoryboardSegue) {
        self.performSegueWithIdentifier("unwindFromGetDirections", sender: self)
        
        // Intialzing Main View Controller
         //let controller = self.storyboard?.instantiateViewControllerWithIdentifier("IDMapViewController") as! IDMapViewController
        //        controller.passedRoomName = name
        //        controller.passedX = x
        //        controller.passedY = y
        //        controller.passedZ = z
        // call objective c funtion
        //  let mapController = IDMapViewController()
        //   mapController.calculateRoute()
        // self.presentViewController(controller, animated: false, completion: nil)
        //controller.calculateRoute()
    }
    
    
    
}
