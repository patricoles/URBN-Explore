//
//  TourRoomDetails.swift
//  URBN-Explore


import UIKit

class TourRoomDetails: UIViewController {
    
    // Images
    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var popupView: UIView!
    // Labels
    @IBOutlet weak var selectedName: UILabel!
    @IBOutlet weak var selectedNumber: UILabel!
    @IBOutlet weak var selectedDesc: UILabel!
    @IBOutlet weak var selectedFeatures: UILabel!
    @IBOutlet var clearView: UIView!
    
    
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var features: UILabel!
    
    var name = ""
    var number = ""
    var desc = ""
    var feat = ""
    var kind = ""
    let tapRec = UITapGestureRecognizer()

    
    override func viewDidLoad() {
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
        
        
        //        if (detailRoom!.Type == "Classroom") {
        //            let image : UIImage = UIImage(named: "icon_room-class")!
        //            selectedImage.image = image
        //        } else if (detailRoom!.Type == "Office")  {
        //            let image : UIImage = UIImage(named: "icon_room-faculty")!
        //            selectedImage.image = image
        //
        //
        //        } else if (detailRoom!.Type == "Lab")  {
        //            let image : UIImage = UIImage(named: "icon_room-lab")!
        //            selectedImage.image = image
        //        }else if (detailRoom!.Type == "Restroom")  {
        //            let image : UIImage = UIImage(named: "icon_room-restroom")!
        //            selectedImage.image = image
        //
        //
        //        }
        //
        selectedName.text = name
        selectedNumber.text = number
        selectedDesc.text = desc
        selectedFeatures.text = feat
        features.text = "Features"
        
        
        //set the target of the gesture recognizers for each view
        tapRec.addTarget(self, action: "tappedOnBG")
        
        
        //we add the gesture recognizers to the views
        dimView.addGestureRecognizer(tapRec)
        
        //e set the userInteractionEnabled property of each view to true
        dimView.userInteractionEnabled = true

        //        
        
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
        self.performSegueWithIdentifier("tourDetailToMap", sender: self)
        
        
        
    }
    
    
    
    
}
