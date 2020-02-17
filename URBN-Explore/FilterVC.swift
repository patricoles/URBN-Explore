//
//  FilterVC.swift
//  URBN-Explore


import UIKit

class FilterVC: UIViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet var clearView: UIView!
    @IBOutlet var currentTableView: UITableView!
    @IBOutlet weak var navtitle: UINavigationItem!
  
    var filterOptions = ["Room Type", "Floors"]
    var filterValue:String = ""
    var floorDetailLabel = ""
    var roomDetailLabel = ""
    
    let tapBG = UITapGestureRecognizer()

     override func viewDidLoad() {
        print("FilterVC Loaded")
        currentTableView.tableFooterView = UIView(frame: CGRectZero)

        // Styling Navigation Bar
        self.navtitle.title="Filter"
        self.navBar.titleTextAttributes =
            [NSFontAttributeName: Font.NavigationTitle!,NSForegroundColorAttributeName: Color.GrayDark]
        
        // Animation
        currentTableView.transform = CGAffineTransformMakeTranslation(400, 0)
        navBar.transform = CGAffineTransformMakeTranslation(400, 0)
       
        // Look for stored value and assign to variables
        let defaults = NSUserDefaults.standardUserDefaults()
        if let floorKey = defaults.stringForKey("Floors")
        {
            print("Key: Floor, Value: \(floorKey)")
            floorDetailLabel = floorKey
            
        }
        if let roomKey = defaults.stringForKey("Room Type") {
            print("Key: Room Type, Value: \(roomKey)")
            roomDetailLabel = roomKey
        }
        
        //set the target of the gesture recognizers for each view
        tapBG.addTarget(self, action: #selector(TourModal.tappedOnBG))
        
        //we add the gesture recognizers to the views
        dimView.addGestureRecognizer(tapBG)
    }
    
    func tappedOnBG(){
        print("User tapped on bg to dismiss the view")
        self.performSegueWithIdentifier("comingFromFilterVC", sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        print("FilterVC Appeared")
        
        // Background Dim View fade
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.currentTableView.transform = CGAffineTransformMakeTranslation(0, 0)
            self.navBar.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: {
                (finished: Bool) -> Void in
        })
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("filterMainCell", forIndexPath: indexPath) as? FilterCell
        let selectedRow = filterOptions[indexPath.row]
        
        cell?.filterTitle!.text = selectedRow
        
        // Asign detail label depending on fitler
        if selectedRow == "Floors" {
            cell?.filterDetailLabel.text = floorDetailLabel
        } else if selectedRow == "Room Type" {
            cell?.filterDetailLabel.text = roomDetailLabel
        }

        return cell!
    }
    
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segure Function with identfier
        self.performSegueWithIdentifier("showFilterDetail", sender: indexPath);
    }
    
    
    
    
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFilterDetail" {
            if let filterDetailVC = segue.destinationViewController as? FilterDetailVC {
                if let filterdSelected = currentTableView.indexPathForSelectedRow?.row {
                    let filterOption = filterOptions[filterdSelected]
                    print("Filter Option \(filterOption)")
                    filterDetailVC.selectedOption = filterOption
                }
            }
        }
    }
    
    // Segues
    @IBAction func unwindToFilterVC(segue: UIStoryboardSegue) {
        // let view2:FilterDetail = segue.sourceViewController as! FilterDetail
        if(segue.sourceViewController .isKindOfClass(FilterDetailVC))
        {
            if segue.identifier == "comingFromFilterDetail" {
                print("Unwind from back button")
                 //let detailVC:FilterDetail = segue.sourceViewController as! FilterDetail

                // Updated Table when selecting a new value
                let defaults = NSUserDefaults.standardUserDefaults()
                if let floorKey = defaults.stringForKey("Floors")
                {
                    print("Key: Floor, Value: \(floorKey)")
                    floorDetailLabel = floorKey
                    
                }
                if let roomKey = defaults.stringForKey("Room Type") {
                    print("Key: Room Type, Value: \(roomKey)")
                    roomDetailLabel = roomKey
                }
                
                currentTableView.reloadData()
            } else if segue.identifier == "clickedCancelButton" {
                print("Unwind from cancel button")

            }
        }
        
    }
    
    
    
}
