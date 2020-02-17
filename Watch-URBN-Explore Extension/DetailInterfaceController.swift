//
//  DetailInterfaceController.swift
//  URBN-Explore
//
//  Created by Paul Phan on 4/13/16.
//  Copyright © 2016 MrPaulPhan. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class DetailInterfaceController: WKInterfaceController {
    
    
    
    @IBOutlet var currentRoomType: WKInterfaceImage!
    @IBOutlet var currentRoomName: WKInterfaceLabel!
    @IBOutlet var currentRoomNumber: WKInterfaceLabel!
    @IBOutlet var currentRoomDesc: WKInterfaceLabel!
    @IBOutlet var currentRoomFeat: WKInterfaceLabel!
    
    var labelName: String = ""
    var labelNumber: String = ""
    var labelDesc: String = ""
    var labelFeat: String = ""


 
    init(context: AnyObject?) {
        print("Recieved context")
        
        // Receve data from segue
        let name = (context as! NSDictionary)["name"] as! String
        let number = (context as! NSDictionary)["number"] as! String
        let desc = (context as! NSDictionary)["desc"] as! String
        let feature = (context as! NSDictionary)["feature"] as! String
        print("Passed Data: Name: \(name) Number: \(number) Desc: \(desc) Feature: \(feature)")
        
        // Assign values to interface variables
        labelName = name
        labelNumber = number
        labelDesc = desc
        labelFeat = feature
        
    }
 
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("Detail Interface: Awake")
        
    }
    
    override func willActivate() {
        print("Detail Interface: willActivate")
      
        // Assign new data from context to current labels on screen
        currentRoomName.setText(labelName)
        currentRoomNumber.setText(labelNumber)
        currentRoomDesc.setText(labelDesc)
        currentRoomFeat.setText(labelFeat)

        
        
        
        
    }
    
    override func didDeactivate() {
        print("Detail Interface: didDeactivate")
        
    }
    
    
    
    
}
