//
//  InterfaceController.swift
//  URBN-Explore
//
//  Created by Paul Phan on 3/30/16.
//  Copyright © 2016 MrPaulPhan. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var session : WCSession!
    
    @IBOutlet var currentFloorImage: WKInterfaceImage!
    @IBOutlet var currentFloorHelperText: WKInterfaceLabel!
    @IBOutlet var helperText: WKInterfaceLabel!
    @IBOutlet var routeDetail: WKInterfaceButton!

    
    var name: String = ""
    var number: String = ""
    var desc: String = ""
    var feature: String = ""

    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("InterfaceController loaded")
        
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            print("WCSession is supported")
        } else {
            print("WCSession is NOT supported")
            
        }
        currentFloorImage.setHidden(true)
        currentFloorHelperText.setHidden(true)
        routeDetail.setHidden(true)
        
        
        
        
        
    }
    
    
    override func willActivate() {
        print("willActivate")
 
    
    }
    
    override func didDeactivate() {
        print("didDeactivate")
        
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        //recieving message from iphone
        print("Recieving Data From iPhone")
        let currentFloorFromPhone = message["currentFloor"] as! String
        let roomDestination = message["roomDestination"] as! String
        let roomNumber = message["roomNumber"] as! String
        let roomDesc = message["roomDesc"] as! String
        let roomFeat = message["roomFeat"] as! String
        
        
        
        
        
        
        print("Passed Floor: \(currentFloorFromPhone), Passed Room Name: \(roomDestination),Passed Room Number: \(roomNumber),Passed Room Description: \(roomDesc),Passed Room Feat: \(roomFeat)")
        
        
        
        name = roomDestination
        number = roomNumber
        desc = roomDesc
        feature = roomFeat
        
        helperText.setHidden(true)
        currentFloorImage.setHidden(false)
        currentFloorHelperText.setHidden(false)
        
        
        
        
        
        let theImage = UIImage(named: "d")
        currentFloorImage.setImage(theImage)
        
        if currentFloorFromPhone == "Floor 1" {
            print("Current Floor: 1")
            let theImage = UIImage(named: "watch_floor_1")
            currentFloorImage.setImage(theImage)
        }
        else if currentFloorFromPhone == "Floor 1a" {
            print("Current Floor: 1A")
            let theImage = UIImage(named: "watch_floor_1A")
            currentFloorImage.setImage(theImage)
            
        }
        else if currentFloorFromPhone == "Floor 2" {
            print("Current Floor: 2")
            let theImage = UIImage(named: "watch_floor_2")
            currentFloorImage.setImage(theImage)
            
        }
        else if currentFloorFromPhone == "Floor 2a" {
            print("Current Floor: 2A")
            let theImage = UIImage(named: "watch_floor_2A")
            currentFloorImage.setImage(theImage)
            
        }
        else if currentFloorFromPhone == "Floor 3" {
            print("Current Floor: 3")
            let theImage = UIImage(named: "watch_floor_3")
            currentFloorImage.setImage(theImage)
            
        }
        else if currentFloorFromPhone == "Floor 3a" {
            print("Current Floor: 3A")
            let theImage = UIImage(named: "watch_floor_3A")
            currentFloorImage.setImage(theImage)
        }
        else if currentFloorFromPhone == "Floor 4" {
            print("Current Floor: 4")
            let theImage = UIImage(named: "watch_floor_4")
            currentFloorImage.setImage(theImage)
            
        } else {
            print("Current Floor: 1")
            let theImage = UIImage(named: "watch_floor_1")
            currentFloorImage.setImage(theImage)
        }
        
        if roomDestination != "nil" {
            routeDetail.setHidden(false)

        } else {
            routeDetail.setHidden(true)

        }
        
        WKInterfaceDevice.currentDevice().playHaptic(.Notification)
    }
    
    
    
    
    /*
     * Pass data to segue
     */
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        if segueIdentifier == "routeDetail"{
            print("Passing Data to routeDetail segue")
            return [
                "name": name,
                "number": number,
                "desc": desc,
                "feature": feature
            ]
        }
        return nil
    }
    
}
