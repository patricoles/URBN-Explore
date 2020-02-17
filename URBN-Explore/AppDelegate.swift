//
//  AppDelegate.swift
//  URBN-Explore


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    // Access view controller and intialized it
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Ask to allow for local notifcation
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        print("*** didFinishLaunchingWithOptions ***")
        
        
        // App badge number
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        //
        //        // Access the storyboard and fetch an instance of the view controller
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let viewController: IDMapViewController = storyboard.instantiateViewControllerWithIdentifier("IDMapViewController") as! IDMapViewController
        
        // Then push that view controller onto the navigation stack
        // viewController.performSegueWithIdentifier("showLoadingScreen", sender: self)
        
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        print("*** applicationWillResignActive ***")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        print("*** applicationDidEnterBackground ***")
        
        // NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Grab status of inRoute
        let inRouteStatus = defaults.stringForKey("inRouteStatus")
        
        // If user in route and they close the app, send a nofitication reminding them of their status
        if  inRouteStatus == "1" {
            
            print("User was in route when app closed. Send push notification to remind user that they are still in route")
            
            let localNotification = UILocalNotification()
            //fireDate - The time when the notification is delivered. We set it here on 5 seconds.
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
            
            //alertBody - The message displayed in the notification alert.
            localNotification.alertBody = "You're still in routed Have you reached your destination?"
            
            localNotification.soundName = "notification_sound.mp3"
            
            //timeZone - The time zone of the notfication's fire date
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            //applicationIconBadgeNumber - The number to diplay on the icon badge. We will increment this number by one.
            //localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
        }
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("*** applicationWillEnterForeground ***")
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("*** applicationDidBecomeActive ***")
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("*** applicationWillTerminate ***")
        let defaults = NSUserDefaults.standardUserDefaults()
        
        
        print("App has been Terminated. inRouteStatus: false, Filter: false")

        defaults.setObject(false, forKey: "inRouteStatus")
        defaults.setObject("", forKey: "Room Type")
        defaults.setObject("", forKey: "Floors")
        defaults.setObject("false", forKey: "isFiltered")
 
    }
    
    
}

