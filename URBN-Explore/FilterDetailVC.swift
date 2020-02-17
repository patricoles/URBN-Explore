//
//  FilterDetail.swift
//  URBN-Explore


import UIKit

class FilterDetailVC: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dimView: UIView!
    // Empty String
    var filterList = [String]()
    
    @IBOutlet var clearView: UIView!
    
    @IBOutlet weak var navtitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    // Empty variable for selected option on previous screen
    var selectedOption = ""
    
    // For single selection of a row
    var selectedRow: String = ""
    
    var optionType = ""
    
    @IBOutlet weak var TableView: UITableView!
    let tapBG = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("FilterDetailVC Loaded")
               // Animation
        TableView.transform = CGAffineTransformMakeTranslation(400, 0)
        navBar.transform = CGAffineTransformMakeTranslation(400, 0)

        
        TableView.tableFooterView = UIView(frame: CGRectZero)
        
        if (selectedOption == "Room Type") {
            filterList.append("Classroom")
            filterList.append("Faculty Office")
            filterList.append("Lab")
            filterList.append("Restroom")
            filterList.append("Other")
            optionType = "Room Type"
            self.navtitle.title = "Room Type"
            
        } else if (selectedOption == "Floors") {
            filterList.append("1")
            filterList.append("1A")
            filterList.append("2")
            filterList.append("2A")
            filterList.append("3")
            filterList.append("3A")
            filterList.append("4")
            optionType = "Floors"
            self.navtitle.title = "Floors"
            
        }
        // Styling Navigation Bar
        self.navBar.titleTextAttributes =
            [NSFontAttributeName: Font.NavigationTitle!,NSForegroundColorAttributeName: Color.GrayDark]
        

        
        //set the target of the gesture recognizers for each view
        tapBG.addTarget(self, action: #selector(TourModal.tappedOnBG))
        
        //we add the gesture recognizers to the views
        dimView.addGestureRecognizer(tapBG)

        
    }
    override func viewDidAppear(animated: Bool) {
        print("FilterVC Appeared")
        
        // Background Dim View fade
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.TableView.transform = CGAffineTransformMakeTranslation(0, 0)
            self.navBar.transform = CGAffineTransformMakeTranslation(0, 0)
            
            }, completion: {
                (finished: Bool) -> Void in
        })
        
    }
    
    func tappedOnBG(){
        print("User tapped on bg to dismiss the view")
        self.performSegueWithIdentifier("comingFromFilterDetail", sender: self)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("filterDetailCell", forIndexPath: indexPath) as? FilterDetailCell
        
        let filterOption = filterList[indexPath.row]
        
        if selectedOption == "Floors" {
            cell?.filterDetailOption!.text = "Floor " + filterOption
            
        } else if selectedOption == "Room Type" {
            cell?.filterDetailOption!.text = filterOption
            
        }
        
        
        // Check to see if filter has been selected
        let defaults = NSUserDefaults.standardUserDefaults()
        if let filterName = defaults.stringForKey(optionType)
        {
            // Add checkmark if row was selected on load
            if filterName != filterOption {
                cell!.accessoryType = .None
                cell!.filterDetailOption?.textColor = UIColor(red: 53/255, green: 54/255, blue: 58/255, alpha: 1.0)
            } else {
                cell!.accessoryType = .Checkmark
                cell!.tintColor = UIColor(red: 30/255, green: 172/255, blue: 45/255, alpha: 1.0)
                cell!.filterDetailOption?.textColor = UIColor(red: 30/255, green: 172/255, blue: 45/255, alpha: 1.0)
                
            }
        }
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print("Selected Row")
        
        
        
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? FilterDetailCell {
            
            // Selected cell name string
            let cellName = cell.filterDetailOption.text! as String
            let modifiedName = cellName.stringByReplacingOccurrencesOfString("Floor ", withString:"")
            
            // let cellRowNumber = indexPath.row
            
            
            
            // Store selected row onto phone
            let selectedFilteringOption = NSUserDefaults.standardUserDefaults()
            
            
            // Add checkmark to selected row and update variable
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                selectedFilteringOption.setObject("", forKey: optionType) // Diselect row, make value blank
                selectedFilteringOption.setObject(false, forKey: "isFiltered") // Diselect row, make value blank
                cell.filterDetailOption?.textColor = UIColor(red: 53/255, green: 54/255, blue: 58/255, alpha: 1.0)
                
            } else {
                selectedFilteringOption.setObject(modifiedName, forKey: optionType)
                selectedFilteringOption.setObject(true, forKey: "isFiltered") // Diselect row, make value blank
                
                cell.accessoryType = .Checkmark
                cell.tintColor = UIColor(red: 30/255, green: 172/255, blue: 45/255, alpha: 1.0)
                cell.filterDetailOption?.textColor = UIColor(red: 30/255, green: 172/255, blue: 45/255, alpha: 1.0)
            }
            
            // Reload tableview
            tableView.reloadData()
            
        }
    }
    
    
}
