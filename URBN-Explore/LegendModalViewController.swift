//
//  LegendModalViewController.swift
//  URBN-Explore
//


import UIKit

class LegendModalViewController: UIViewController {
    
    
    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var popupView: UIView!
    let tapRec = UITapGestureRecognizer()

    
    override func viewDidLoad() {
        print("LegendModalViewController Loaded")
        // Start view from bottom
        
        popupView.layer.borderColor = UIColor.blackColor().CGColor
        popupView.layer.borderWidth = 0.25
        popupView.layer.shadowColor = UIColor.blackColor().CGColor
        popupView.layer.shadowOpacity = 0.6
        popupView.layer.shadowRadius = 15
        popupView.layer.shadowOffset = CGSize(width: 5, height: 5)
        popupView.layer.masksToBounds = false
        
        
        
        //set the target of the gesture recognizers for each view
        tapRec.addTarget(self, action: "tappedOnBG")
        
        
        //we add the gesture recognizers to the views
        dimView.addGestureRecognizer(tapRec)
    }
    
        func tappedOnBG(){
            
            print("User tapped on bg to dismiss the view")
            self.performSegueWithIdentifier("legendToMap", sender: self)
            
            
            
        }
        
        
}
