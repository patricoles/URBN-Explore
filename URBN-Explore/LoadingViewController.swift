//
//  LoadingViewController.swift
//  URBN-Explore


import UIKit


class LoadingViewController: UIViewController {
    @IBOutlet weak var loadingGif: UIImageView!
    @IBOutlet weak var offlineModeButton: UIButton!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet var clearView: UIView!
    var gifList = [UIImage]()
    
    @IBOutlet weak var headingLabel: UILabel!
    override func viewDidLoad() {
        print("LoadingViewController Loaded")

        headingLabel.text = "Trying to locate your position"
        offlineModeButton.setTitle("Offline Mode", forState: UIControlState.Normal)

        // Button rounded corners
        offlineModeButton.layer.cornerRadius = 7
        
        // Looping through all images in gif and assigning them to an UIImage array
        for i in 0...119 {
            let imageName = "layer\(i)"
            gifList.append(UIImage(named: imageName)!)
        }
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print("LoadingViewController Appeared")
        
        // Background Dim View fade
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.dimView.alpha = 0.7
            
            }, completion: {
                (finished: Bool) -> Void in
        })
        
  
        
        // Add images to an array
        loadingGif.animationImages = gifList
        loadingGif.startAnimating()
    }
  
    
}
