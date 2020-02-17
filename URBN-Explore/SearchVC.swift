//
//  SearchVC.swift
//  URBN-Explore
//


import UIKit
import WatchConnectivity


class SearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate,UIPopoverPresentationControllerDelegate, Dimmable, WCSessionDelegate {
  
    @IBOutlet weak var refineButtonLabel: UIBarButtonItem!
    @IBOutlet weak var NavBar: UINavigationBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var navtitle: UINavigationItem!

    var rooms = [Room]()
    var filterdRooms = [Room]()
    var refinedRooms = [Room]()
    var roomsUpdated = [Room]()
    var isFiltered = ""
    var session: WCSession!
    // For Filtering
    var filterFloor = ""
    var filterKind = ""
    
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded SearchVC")

        // Apple Watch
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self;
            session.activateSession()
        }
        
        // Styling Navigation Bar
        self.navtitle.title="Room List"
        self.NavBar.titleTextAttributes =
            [NSFontAttributeName: Font.NavigationTitle!,NSForegroundColorAttributeName: Color.GrayDark]
        
        createRoomStructure()
        
     

        loadingLocalData()
        
       configureSearchController()
        
        
        
    }
    
    

    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a room..."
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barTintColor = Color.White
        searchController.searchBar.tintColor = Color.BlueLight
        definesPresentationContext = true
        // Add to tableview
        searchTableView.tableHeaderView = searchController.searchBar
    }
    
    func loadingLocalData(){
        // Look for stored value and assign to variables
        let defaults = NSUserDefaults.standardUserDefaults()
        if let floorKey = defaults.stringForKey("Floors")
        {
            print("Floor: \(floorKey)")
            filterFloor = floorKey
            
        }
        if let roomKey = defaults.stringForKey("Room Type") {
            print("Key: \(roomKey)")
            filterKind = roomKey
        }
        
        if let Filtered = defaults.stringForKey("isFiltered") {
            print("Filtered Value: \(Filtered)")
            
            if Filtered == "1" {
                print("Is currently being filtered")
                isFiltered = "true"
                
            } else  {
                print("Is not being filtered")
                isFiltered = "false"

            }
        }
        
        // If filtering options have been selected not blank then filter the array and make sure that it filters by both values else filter one or the other
        if filterFloor != "" && filterKind != "" {
            refinedRooms = rooms.filter{$0.Floor == filterFloor && $0.Type == filterKind}
            refineButtonLabel.title = "Refine(2)"
        } else if filterFloor != "" && filterKind == "" {
            refinedRooms = rooms.filter{$0.Floor == filterFloor || $0.Type == filterKind}
            refineButtonLabel.title = "Refine(1)"

        } else if filterFloor == "" && filterKind != "" {
            refinedRooms = rooms.filter{$0.Floor == filterFloor || $0.Type == filterKind}
            refineButtonLabel.title = "Refine(1)"

        }
        
        // Add current structure to a new based on isFiltered status
        if isFiltered == "true" {
            roomsUpdated = refinedRooms
        } else {
            roomsUpdated = rooms
        }
        
        print("List Count: \(roomsUpdated.count)")
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filterdRooms = roomsUpdated.filter { room in
            return room.Name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        searchTableView.reloadData()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if searchController.active && searchController.searchBar.text != "" {
            return filterdRooms.count
        }
        return roomsUpdated.count
        
        
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? SearchCell
        let room: Room
        
        if searchController.active && searchController.searchBar.text != "" {
            room = filterdRooms[indexPath.row]
        } else {
            room = roomsUpdated[indexPath.row]
        }
        cell?.cellName!.text = room.Name
        cell?.cellNumber!.text = room.Number
        
        
        // Change image of cell based off type of room
        if (room.Type == "Classroom") {
            let image : UIImage = UIImage(named: "icon_room-class")!
            cell?.cellImage.image = image
            
            
        } else if (room.Type == "Office")  {
            let image : UIImage = UIImage(named: "icon_room-faculty")!
            cell?.cellImage.image = image
            
            
        } else if (room.Type == "Lab")  {
            let image : UIImage = UIImage(named: "icon_room-lab")!
            cell?.cellImage.image = image
            
            
        }   else if (room.Type == "Restroom")  {
            let image : UIImage = UIImage(named: "icon_room-restroom")!
            cell?.cellImage.image = image
        }
        return cell!
        
    }
//
//        func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let  headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! SearchCell
//            
//            headerCell.filterFloorCell.text = filterFloor
//            headerCell.filterRoomType.text = filterKind
//            
//
//        
//        return headerCell
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segure Function with identfier
        self.performSegueWithIdentifier("showModal", sender: indexPath);
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showModal") {
            let rowSelected = (sender as! NSIndexPath).row
            
            if let detailedVC = segue.destinationViewController as? SearchPopOver {
                let room: Room
                
                if searchController.active && searchController.searchBar.text != "" {
                    room = filterdRooms[rowSelected]
                } else {
                    room = roomsUpdated[rowSelected]
                }
                // Remove presented Search Controller so new view can show
                searchController.active = false
                
                print(rowSelected)
                
                detailedVC.detailRoom = room
                dim(.In, alpha: dimLevel, speed: dimSpeed)
                
            }
            
            if (segue.identifier == "showFilterVC") {
                
                // let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FilterVC") as! Filter
            }
        }
    }
    
    @IBAction func unwindToSearchList(segue: UIStoryboardSegue) {
        
        if(segue.sourceViewController .isKindOfClass(FilterVC))
        {
            print("Unwind from FilterVC")
            loadingLocalData()
            searchTableView.reloadData()
        }
        
        if(segue.sourceViewController .isKindOfClass(SearchPopOver))
        {
            dim(.Out, speed: dimSpeed)
            print("Unwind from SearchPopOver")
            
            //let view2:FilterVC = segue.sourceViewController as! FilterVC
            // searchController.active = true
            
        }
    }
    
    
    
    
    func createRoomStructure() {
        rooms = [
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Office",
                Description:"The Student Services office",
                Features:"Advisors",
                XCoordinate:"42733",
                YCoordinate:"36908",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103A",
                Zone:"office_103a_1",
                Floor:"1",
                Number:"103A",
                Type:"Office",
                Description:"One of the rooms for Student Services Faculty",
                Features:"Advisors",
XCoordinate:"52644",
                YCoordinate:"31365",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103B",
                Zone:"office_103b_1",
                Floor:"1",
                Number:"103B",
                Type:"Office",
                Description:"One of the rooms for Student Services Faculty",
                Features:"Advisors",
                XCoordinate:"51561",
                YCoordinate:"30618",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103C",
                Zone:"office_103c_1",
                Floor:"1",
                Number:"103C",
                Type:"Office",
                Description:"One of the rooms for Student Services Faculty",
                Features:"Advisors",
                XCoordinate:"49114",
                YCoordinate:"30626",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103D",
                Zone:"office_103d_1",
                Floor:"1",
                Number:"103D",
                Type:"Office",
                Description:"One of the rooms for Student Services Faculty",
                Features:"Advisors",
                XCoordinate:"46926",
                YCoordinate:"30610",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103E",
                Zone:"office_103e_1",
                Floor:"1",
                Number:"103E",
                Type:"Office",
                Description:"One of the rooms for Student Services Faculty",
                Features:"Advisors",
                XCoordinate:"44654",
                YCoordinate:"30603",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103F",
                Zone:"office_103f_1",
                Floor:"1",
                Number:"103F",
                Type:"Office",
                Description:"One of the rooms for Student Services Faculty",
                Features:"Advisors",
                XCoordinate:"40659",
                YCoordinate:"34682",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103G",
                Zone:"office_103g_1",
                Floor:"1",
                Number:"103G",
                Type:"Office",
                Description:"One of the rooms for Student Services Faculty",
                Features:"Advisors",
                XCoordinate:"42771",
                YCoordinate:"30603",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103J",
                Zone:"office_103j_1",
                Floor:"1",
                Number:"103J",
                Type:"Office",
                Description:"One of the rooms for Student Services Faculty",
                Features:"Advisors",
                XCoordinate:"43625",
                YCoordinate:"35665",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 105",
                Zone:"lab_105_1",
                Floor:"1",
                Number:"105",
                Type:"Lab",
                Description:"The Hybrid Lab, home to many different tools for the makers of the URBN Center",
                Features:"Wood Cutters, Large Printers, Laser tools",
                XCoordinate:"35894",
                YCoordinate:"40910",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 105a",
                Zone:"lab_105a_1",
                Floor:"1",
                Number:"105a",
                Type:"Lab",
                Description:"The Hybrid Lab, home to many different tools for the makers of the URBN Center",
                Features:"Wood Cutters, Large Printers, Laser tools",
                XCoordinate:"33866",
                YCoordinate:"30313",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 105B",
                Zone:"lab_105b_1",
                Floor:"1",
                Number:"105B",
                Type:"Lab",
                Description:"One of the secondary parts of the Hybrid Lab",
                Features:"Wood Cutters, Large Printers, Laser tools",
                XCoordinate:"38570",
                YCoordinate:"25533",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 106",
                Zone:"classroom_106_1",
                Floor:"1",
                Number:"107",
                Type:"Classroom",
                Description:"The Seminar Room for Mad Dragon",
                Features:"Projector",

                XCoordinate:"17764",
                YCoordinate:"47726",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 108",
                Zone:"classroom_106_1",
                Floor:"1",
                Number:"108",
                Type:"Classroom",
                Description:"A general computer lab that functions as a classroom.",
                Features:"Computers, Projector",
                XCoordinate:"17764",
                YCoordinate:"47726",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 107",
                Zone:"classroom_107_1",
                Floor:"1",
                Number:"107",
                Type:"Classroom",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"26913",
                YCoordinate:"39050",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 109",
                Zone:"classroom_109_1",
                Floor:"1",
                Number:"109",
                Type:"Office",
                Description:"The Home of Mad Dragon Enterprises.",
                Features:"Projector",
                XCoordinate:"27157",
                YCoordinate:"40636",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 110",
                Zone:"office_110_1",
                Floor:"1",
                Number:"110",
                Type:"Office",
                Description:"The Design and Merchandising Faculty office.",
                Features:"Faculty",
                XCoordinate:"12366",
                YCoordinate:"47681",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 110a",
                Zone:"office_110a_1",
                Floor:"1",
                Number:"110a",
                Type:"Office",
                Description:"The Design and Merchandising Faculty office.",
                Features:"Faculty",
XCoordinate:"13372",
                YCoordinate:"48779",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 110b",
                Zone:"office_110b_1",
                Floor:"1",
                Number:"110b",
                Type:"Office",
                Description:"The Design and Merchandising Faculty office.",
                Features:"Faculty",
                XCoordinate:"13372",
                YCoordinate:"50974",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 110c",
                Zone:"office_110c_1",
                Floor:"1",
                Number:"110c",
                Type:"Office",
                Description:"The Design and Merchandising Faculty office.",
                Features:"Faculty",
                XCoordinate:"14089",
                YCoordinate:"52514",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 110d",
                Zone:"office_110d_1",
                Floor:"1",
                Number:"110d",
                Type:"Office",
                Description:"The Design and Merchandising Faculty office.",
                Features:"Faculty",
                XCoordinate:"11786",
                YCoordinate:"48748",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 110e",
                Zone:"office_110e_1",
                Floor:"1",
                Number:"110e",
                Type:"Office",
                Description:"The Design and Merchandising Faculty office.",
                Features:"Faculty",
                XCoordinate:"11085",
                YCoordinate:"52682",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 110f",
                Zone:"office_110f_1",
                Floor:"1",
                Number:"110f",
                Type:"Office",
                Description:"The Design and Merchandising Faculty office.",
                Features:"Faculty",
                XCoordinate:"11771",
                YCoordinate:"51020",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 120",
                Zone:"classroom_120_1",
                Floor:"1",
                Number:"123",
                Type:"Classroom",
                Description:"A large classroom great for lectures and critiques.",
                Features:"Projector",
                XCoordinate:"7974",
                YCoordinate:"44921",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 122",
                Zone:"classroom_122_1",
                Floor:"1",
                Number:"122",
                Type:"Classroom",
                Description:"A large classroom great for lectures and critiques.",
                Features:"Projector",
                XCoordinate:"10567",
                YCoordinate:"44425",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 123",
                Zone:"classroom_123_1",
                Floor:"1",
                Number:"123",
                Type:"Classroom",
                Description:"A large classroom great for lectures and critiques.",
                Features:"Projector",
                XCoordinate:"14013",
                YCoordinate:"44524",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 124",
                Zone:"classroom_124_1",
                Floor:"1",
                Number:"124",
                Type:"Lab",
                Description:"A fully equipped audio lab.",
                Features:"Keyboards, Microphones, Projector",
                XCoordinate:"10399",
                YCoordinate:"40720",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 126",
                Zone:"classroom_126_1",
                Floor:"1",
                Number:"126",
                Type:"Lab",
                Description:"A private fully equipped audio lab that is incredibly soundproof.",
                Features:"Keyboards, Microphones, Instruments",
                XCoordinate:"10071",
                YCoordinate:"30267",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 128",
                Zone:"classroom_128_1",
                Floor:"1",
                Number:"128",
                Type:"Lab",
                Description:"A fully equipped audio lab.",
                Features:"Keyboards, Microphones, Projector",
                XCoordinate:"10376",
                YCoordinate:"23116",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 130",
                Zone:"office_130a_1",
                Floor:"1",
                Number:"130A",
                Type:"Lab",
                Description:"One of the areas of the Historic Costume Collection",
                Features:"Archives, Private Access",
                XCoordinate:"14882",
                YCoordinate:"22292",
                ZCoordinate:"8"
            ),

            Room(
                Name:"URBN 130A",
                Zone:"office_130a_1",
                Floor:"1",
                Number:"130A",
                Type:"Lab",
                Description:"One of the areas of the Historic Costume Collection",
                Features:"Archives, Private Access",                XCoordinate:"13912",
                YCoordinate:"17163",
                ZCoordinate:"8"
            ),
            
            Room(
                Name:"URBN 130C",
                Zone:"classroom_130c_1",
                Floor:"1",
                Number:"130C",
                Type:"Lab",
                Description:"One of the areas of the Historic Costume Collection",
                Features:"Archives, Private Access",
                XCoordinate:"14935",
                YCoordinate:"20295",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 132",
                Zone:"classroom_132_1",
                Floor:"1",
                Number:"132",
                Type:"Classroom",
                Description:"A classroom that is used as the meeting ground for the Lindy Institute",
                Features:"Lindy Institute, Projector",
                XCoordinate:"23245",
                YCoordinate:"15789",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 134",
                Zone:"office_134_1",
                Floor:"1",
                Number:"134",
                Type:"Office",
                Description:"The faculty office for Arts Administration",
                Features:"Faculty",
                XCoordinate:"24724",
                YCoordinate:"11459",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 136",
                Zone:"office_136_1",
                Floor:"1",
                Number:"136",
                Type:"Office",
                Description:"A faculty office.",
                Features:"Faculty",
                XCoordinate:"22513",
                YCoordinate:"10147",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 138",
                Zone:"office_138_1",
                Floor:"1",
                Number:"138",
                Type:"Office",
                Description:"A faculty office.",
                Features:"Faculty",
                XCoordinate:"24153",
                YCoordinate:"9583",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 140",
                Zone:"office_140_1",
                Floor:"1",
                Number:"140",
                Type:"Office",
                Description:"The office home of Westphal IT.",
                Features:"Westphal IT",
                XCoordinate:"24846",
                YCoordinate:"6587",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 141",
                Zone:"classroom_141_1",
                Floor:"1",
                Number:"141",
                Type:"Classroom",
                Description:"A large classroom that's occasionally the place for events in the URBN Center.",
                Features:"Projector, Whiteboard",
                XCoordinate:"27355",
                YCoordinate:"22231",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Floor 1 Unisex Restroom",
                Zone:"bathroomUnisex_172_1",
                Floor:"1",
                Number:"172",
                Type:"Restroom",
                Description:"A unisex restroom with handicap-accessibility",
                Features:"Water Fountain, Restroom",
                XCoordinate:"47787",
                YCoordinate:"20417",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Floor 1 Men's Restroom",
                Zone:"bathroomUnisex_171_1",
                Floor:"1",
                Number:"171",
                Type:"Restroom",
                Description:"A men's restroom.",
                Features:"Water Fountain, Restroom",
                XCoordinate:"49183",
                YCoordinate:"19502",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Floor 1 Women's Restroom",
                Zone:"bathroomUnisex_173_1",
                Floor:"1",
                Number:"173",
                Type:"Restroom",
                Description:"A women's restroom.",
                Features:"Water Fountain, Restroom",
                XCoordinate:"49167",
                YCoordinate:"26417",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 1A10",
                Zone:"office_1a10_1",
                Floor:"1A",
                Number:"1A10",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",
                XCoordinate:"25791",
                YCoordinate:"32043",
                ZCoordinate:"2"
            ),

            Room(
                Name:"URBN 1A10A",
                Zone:"office_1a10A_1a",
                Floor:"1A",
                Number:"1A10A",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",
                XCoordinate:"22803",
                YCoordinate:"30930",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A10C",
                Zone:"office_1a10c_1a",
                Floor:"1A",
                Number:"1A10C",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",
                XCoordinate:"22185",
                YCoordinate:"32638",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A10b",
                Zone:"office_1a10b_1a",
                Floor:"1A",
                Number:"1A10b",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",

                XCoordinate:"21865",
                YCoordinate:"30938",
                ZCoordinate:"2"
            ),

            Room(
                Name:"URBN 1A10D",
                Zone:"office_1a10d_1a",
                Floor:"1A",
                Number:"1A10D",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",

                XCoordinate:"25791",
                YCoordinate:"32043",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A10E",
                Zone:"office_1a10e_1a",
                Floor:"1A",
                Number:"1A10E",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",
                XCoordinate:"22185",
                YCoordinate:"39461",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A10F",
                Zone:"office_1a10f_1a",
                Floor:"1A",
                Number:"1A10F",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",
                XCoordinate:"22193",
                YCoordinate:"40628",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A10G",
                Zone:"office_1a10g_1a",
                Floor:"1A",
                Number:"1A10G",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",
                XCoordinate:"22185",
                YCoordinate:"43365",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A10H",
                Zone:"office_1a10h_1a",
                Floor:"1A",
                Number:"1A10H",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",
                XCoordinate:"23695",
                YCoordinate:"43395",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A10J",
                Zone:"office_1a10j_1a",
                Floor:"1A",
                Number:"1A10J",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",
                XCoordinate:"23474",
                YCoordinate:"39133",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A10K",
                Zone:"office_1a10k_1a",
                Floor:"1A",
                Number:"1A10K",
                Type:"Office",
                Description:"The home of the Admissions and Administration faculty",
                Features:"Faculty, Admissions",

                XCoordinate:"23489",
                YCoordinate:"37769",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A20",
                Zone:"office_1a20_1a",
                Floor:"1A",
                Number:"1A20A",
                Type:"Office",
                Description:"One of the rooms for the faculty of the Dean.",
                Features:"Faculty",                XCoordinate:"30236",
                YCoordinate:"20615",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A20A",
                Zone:"office_1a20a_1a",
                Floor:"1A",
                Number:"1A20A",
                Type:"Office",
                Description:"One of the rooms for the faculty of the Dean.",
                Features:"Faculty",                XCoordinate:"31731",
                YCoordinate:"22962",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A20B",
                Zone:"office_1a20b_1a",
                Floor:"1A",
                Number:"1A20B",
                Type:"Office",
                Description:"One of the rooms for the faculty of the Dean.",
                Features:"Faculty",                XCoordinate:"30892",
                YCoordinate:"18556",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A20D",
                Zone:"office_1a20d_1a",
                Floor:"1A",
                Number:"1A20d",
Type:"Office",
                Description:"One of the rooms for the faculty of the Dean.",
                Features:"Faculty",
                XCoordinate:"31746",
                YCoordinate:"20996",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A20E",
                Zone:"office_1a20e_1a",
                Floor:"1A",
                Number:"1A20E",
                Type:"Office",
                Description:"One of the rooms for the faculty of the Dean.",
                Features:"Faculty",                XCoordinate:"33393",
                YCoordinate:"19532",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 1A22",
                Zone:"office_1a22_1a",
                Floor:"1A",
                Number:"1A22",
                Type:"Office",
                Description:"An open conference room used primarily by faculty.",
                Features:"Projector, Engaging Artwork",
                XCoordinate:"33393",
                YCoordinate:"19532",
                ZCoordinate:"2"
            ),
            Room(
                Name:"URBN 201",
                Zone:"lab_201_2",
                Floor:"2",
                Number:"201",
                Type:"Lab",
                Description:"A large open area filled with desks and projects of product design students",
                Features:"Student Installations, Swing",
                XCoordinate:"43731",
                YCoordinate:"40757",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 201A",
                Zone:"office_201a_2",
                Floor:"2",
                Number:"201A",
                Type:"Lab",
                Description:"An additional section of the large product design space",
                Features:"Student Installations",
                XCoordinate:"32402",
                YCoordinate:"32508",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 202",
                Zone:"classroom_202_2",
                Floor:"2",
                Number:"202",
                Type:"Classroom",
                Description:"One of the graduate labs for Digital Media students",
                Features:"Computers, Whiteboard, Projector",
                XCoordinate:"45926",
                YCoordinate:"48702",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 204",
                Zone:"lab_204_2",
                Floor:"2",
                Number:"204",
                Type:"Lab",
                Description:"A small room with a mounted television in the middle. Perfect for group meetings or presentation practices.",
                Features:"Large TV",
                XCoordinate:"43426",
                YCoordinate:"49098",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 206",
                Zone:"classroom_206_2",
                Floor:"2",
                Number:"206",
                Type:"Classroom",
                Description:"One of the graduate labs for Digital Media students",
                Features:"Computers, Whiteboard, Projector",
                XCoordinate:"40986",
                YCoordinate:"48580",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 210",
                Zone:"office_210_2",
                Floor:"2",
                Number:"210",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"17611",
                YCoordinate:"47680",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210a",
                Zone:"office_210a_2",
                Floor:"2",
                Number:"210a",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"30938",
                YCoordinate:"52056",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210b",
                Zone:"office_210b_2",
                Floor:"2",
                Number:"210b",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"27827",
                YCoordinate:"52071",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210c",
                Zone:"office_210c_2",
                Floor:"2",
                Number:"210c",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"24747",
                YCoordinate:"52087",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210d",
                Zone:"office_210d_2",
                Floor:"2",
                Number:"210d",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"21743",
                YCoordinate:"52102",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210e",
                Zone:"office_210e_2",
                Floor:"2",
                Number:"210e",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                                XCoordinate:"18709",
                YCoordinate:"52071",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210f",
                Zone:"office_210f_2",
                Floor:"2",
                Number:"210f",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"17184",
                YCoordinate:"51538",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210g",
                Zone:"office_210g_2",
                Floor:"2",
                Number:"210g",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"17169",
                YCoordinate:"49693",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210h",
                Zone:"office_210h_2",
                Floor:"2",
                Number:"210h",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"19669",
                YCoordinate:"50882",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210j",
                Zone:"office_210j_2",
                Floor:"2",
                Number:"210j",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"21804",
                YCoordinate:"50882",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210k",
                Zone:"office_210k_2",
                Floor:"2",
                Number:"210k",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"23893",
                YCoordinate:"50897",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 210l",
                Zone:"office_210l_2",
                Floor:"2",
                Number:"210l",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"25997",
                YCoordinate:"50882",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 210m",
                Zone:"office_210m_2",
                Floor:"2",
                Number:"210m",
                Type:"Office",
                Description:"The offices of the Arts and Entertainment Faculty",
                Features:"Faculty",
                XCoordinate:"28208",
                YCoordinate:"50867",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 220",
                Zone:"office_220_2",
                Floor:"2",
                Number:"220",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"8554",
                YCoordinate:"48290",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 220a",
                Zone:"office_220a_2",
                Floor:"2",
                Number:"220a",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"10246",
                YCoordinate:"49312",
                ZCoordinate:"3"
            ),
            
    
            Room(
                Name:"URBN 220c",
                Zone:"office_220c_2",
                Floor:"2",
                Number:"220c",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"10658",
                YCoordinate:"53124",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 220d",
                Zone:"office_220d_2",
                Floor:"2",
                Number:"220d",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"5687",
                YCoordinate:"51202",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 220e",
                Zone:"office_220e_2",
                Floor:"2",
                Number:"220e",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"2698",
                YCoordinate:"52193",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 220f",
                Zone:"office_220f_2",
                Floor:"2",
                Number:"220f",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"2561",
                YCoordinate:"49251",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 220g",
                Zone:"office_220g_2",
                Floor:"2",
                Number:"220g",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"4406",
                YCoordinate:"49845",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 220h",
                Zone:"office_220h_2",
                Floor:"2",
                Number:"220h",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"6800",
                YCoordinate:"49876",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 230",
                Zone:"office_230_2",
                Floor:"2",
                Number:"230",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"6907",
                YCoordinate:"41245",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 230a",
                Zone:"office_230a_2",
                Floor:"2",
                Number:"230a",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"6114",
                YCoordinate:"42236",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 230b",
                Zone:"office_230b_2",
                Floor:"2",
                Number:"230b",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"4391",
                YCoordinate:"42236",
                ZCoordinate:"3"
            ),
            
            
            Room(
                Name:"URBN 230c",
                Zone:"office_230c_2",
                Floor:"2",
                Number:"230c",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"2271",
                YCoordinate:"42801",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 230d",
                Zone:"office_230d_2",
                Floor:"2",
                Number:"230d",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"2332",
                YCoordinate:"40117",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 230e",
                Zone:"office_230e_2",
                Floor:"2",
                Number:"230e",

                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"4315",
                YCoordinate:"40712",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 230f",
                Zone:"office_230f_2",
                Floor:"2",
                Number:"230f",
                Type:"Office",
                Description:"Half of the offices of the Digital Media Faculty",
                Features:"Faculty",
                XCoordinate:"6160",
                YCoordinate:"40727",
                ZCoordinate:"3"
            ),
            
            
            Room(
                Name:"URBN 239",
                Zone:"lab_239_2",
                Floor:"2",
                Number:"239",
                Type:"Lab",
                Description:"Known as the Cushion Room, this screening room features a large projector and is primarily used for presentations and events",
                Features:"Cushions, Projector, Whiteboard",                                XCoordinate:"12106",
                YCoordinate:"39248",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 240",
                Zone:"lab_240_2",
                Floor:"2",
                Number:"240",
                Type:"Lab",
                Description:"The equipment room for Digital Media students",
                Features:"Equipment for renting",
                XCoordinate:"7105",
                YCoordinate:"36229",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 241",
                Zone:"office_241_2",
                Floor:"2",
                Number:"241",
                Type:"Office",
                Description:"A separate faculty office, usually for adjunct professors or specialized professionals.",
                Features:"Faculty",
                XCoordinate:"14378",
                YCoordinate:"37479",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 242",
                Zone:"office_242_1",
                Floor:"2",
                Number:"242",
                Type:"Office",
                Description:"A separate faculty office, usually for adjunct professors or specialized professionals.",
                Features:"Faculty",
                XCoordinate:"8470",
                YCoordinate:"35504",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 243",
                Zone:"lab_243_1",
                Floor:"2",
                Number:"243",
                Type:"Lab",
                Description:"One of the graduate labs for Digital Media students",
                Features:"Computers, Whiteboard, Projector",
                XCoordinate:"14424",
                YCoordinate:"28468",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 244",
                Zone:"office_244_2",
                Floor:"2",
                Number:"244",
                Type:"Office",
                Description:"A separate faculty office, usually for adjunct professors or specialized professionals.",
                Features:"Faculty",
                XCoordinate:"11153",
                YCoordinate:"32470",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 245",
                Zone:"lab_245_2",
                Floor:"2",
                Number:"245",
                Type:"Lab",
                Description:"A lab full of computers, one that classes aren't held in.",
                Features:"Computers",
                XCoordinate:"15141",
                YCoordinate:"24000",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 246",
                Zone:"lab_246_2",
                Floor:"2",
                Number:"246",
                Type:"Lab",
                Description:"The motion capture room, one of the more impressive spots of the URBN Center",
                Features:"Motion Capture Studio",
                XCoordinate:"11207",
                YCoordinate:"30221",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 247",
                Zone:"office_247_2",
                Floor:"2",
                Number:"247",
                Type:"Classroom",
                Description:"Dubbed the 'Fishbowl Room' by the students at Drexel, this computer lab has half of its walls acting as windows.",
                Features:"Projector, Computers, Whiteboard",
                XCoordinate:"15476",
                YCoordinate:"12106",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 248",
                Zone:"classroom_248_2",
                Floor:"2",
                Number:"248",
                Type:"Classroom",
                Description:"A computer lab that also acts as a classroom",
                Features:"Computers, Projector, Whiteboard",
                XCoordinate:"10231",
                YCoordinate:"12777",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 250",
                Zone:"office_250_2",
                Floor:"2",
                Number:"250",
                Type:"Classroom",
                Description:"A computer lab that also acts as a classroom",
                Features:"Computers, Projector, Whiteboard",                XCoordinate:"8005",
                YCoordinate:"10414",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 252",
                Zone:"office_252_2",
                Floor:"2",
                Number:"252",
                Type:"Classroom",
                Description:"A computer lab that also acts as a classroom, used heavily as a render farm towards the end of the term",
                Features:"Computers, Projector, Whiteboard, Render Farm",                XCoordinate:"8691",
                YCoordinate:"7761",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 260",
                Zone:"office_260_2",
                Floor:"2",
                Number:"260",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"37250",
                YCoordinate:"7745",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 260a",
                Zone:"office_260a_2",
                Floor:"2",
                Number:"260a",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"31273",
                YCoordinate:"6800",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 260b",
                Zone:"office_260b_2",
                Floor:"2",
                Number:"260b",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"31273",
                YCoordinate:"4681",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 260c",
                Zone:"office_260c_2",
                Floor:"2",
                Number:"260c",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"31685",
                YCoordinate:"1799",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 260d",
                Zone:"office_260d_2",
                Floor:"2",
                Number:"260d",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"36778",
                YCoordinate:"2820",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 260e",
                Zone:"office_260e_2",
                Floor:"2",
                Number:"260e",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"32462",
                YCoordinate:"5900",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 260f",
                Zone:"office_260f_2",
                Floor:"2",
                Number:"260f",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"36701",
                YCoordinate:"6129",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 260g",
                Zone:"office_260g_2",
                Floor:"2",
                Number:"260g",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"37586",
                YCoordinate:"1814",
                ZCoordinate:"3"
            ),
            
            
            Room(
                Name:"URBN 260h",
                Zone:"office_260h_2",
                Floor:"2",
                Number:"260h",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"37845",
                YCoordinate:"4574",
                ZCoordinate:"3"
            ),
            
            Room(
                Name:"URBN 260j",
                Zone:"office_260j_2",
                Floor:"2",
                Number:"260j",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"37860",
                YCoordinate:"6587",
                ZCoordinate:"3"
            ), Room(
                Name:"URBN 261",
                Zone:"lab_261_2",
                Floor:"2",
                Number:"261",
                Type:"Office",
                Description:"The offices of the Music Industry faculty",
                Features:"Faculty",
                XCoordinate:"39965",
                YCoordinate:"13311",
                ZCoordinate:"3"
            ),
         
            Room(
                Name:"URBN 262",
                Zone:"lab_262_2",
                Floor:"2",
                Number:"262",
                Type:"Lab",
                Description:"Dubbed the Make Lab, a product design workshop and studio",
                Features:"3D printer, Wood cutting",
                XCoordinate:"44768",
                YCoordinate:"12472",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 262A",
                Zone:"lab_262a_2",
                Floor:"2",
                Number:"262A",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"46048",
                YCoordinate:"11146",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 262A",
                Zone:"lab_262a_2",
                Floor:"2",
                Number:"262A",
                Type:"Lab",
                Description:"An additional section of the Make Lab for storing and working on projects",
                Features:"Garage",
                XCoordinate:"43777",
                YCoordinate:"15568",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 265",
                Zone:"classroom_265_2",
                Floor:"2",
                Number:"265",
                Type:"Classroom",
                Description:"A general classroom",
                Features:"Projector",
XCoordinate:"43761",
                YCoordinate:"26927",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 270",
                Zone:"office_270_2",
                Floor:"2",
                Number:"270",
                Type:"Office",
                Description:"The offices of the Product Design faculty",
                Features:"Faculty",
                XCoordinate:"47177",
                YCoordinate:"31624",
                ZCoordinate:"3"
            ),
            Room(
                Name:"Floor 2 Men's Restroom",
                Zone:"bathroomMens_271_2",
                Floor:"2",
                Number:"271",
                Type:"Restroom",
                Description:"A men's restroom",
                Features:"Water Fountain, Restroom",
                XCoordinate:"49098",
                YCoordinate:"19532",
                ZCoordinate:"3"
            ),
            Room(
                Name:"Floor 2 Unisex Restroom",
                Zone:"bathroomUnisex_272_2",
                Floor:"2",
                Number:"272",
                Type:"Restroom",
                Description:"A unisex restroom with handicap-accessibility",
                Features:"Water Fountain, Restroom",
             
                XCoordinate:"47863",
                YCoordinate:"20447",
                ZCoordinate:"3"
            ),
            Room(
                Name:"Floor 2 Women's Restroom",
                Zone:"bathroomWomens_273_2",
                Floor:"2",
                Number:"273",
                Type:"Restroom",
                Description:"A women's restroom",
                Features:"Water Fountain, Restroom",
                XCoordinate:"49098",
                YCoordinate:"26470",
                ZCoordinate:"3"
            ),
            Room(
                Name:"URBN 2A10",
                Zone:"lab_2a10_2a",
                Floor:"2A",
                Number:"2A10",
                Type:"Lab",
                Description:"Dubbed the Replay Lab, a game design research facility.",
                Features:"Game consoles and technology",
                XCoordinate:"23870",
                YCoordinate:"29367",
                ZCoordinate:"4"
            ),
            Room(
                Name:"URBN 2A10A",
                Zone:"office_2a10a_2a",
                Floor:"2A",
                Number:"2A10A",
                Type:"Classroom",
                Description:"An additional section of the game research design facility for testing games.",
                Features:"Game consoles and technology",
                XCoordinate:"21789",
                YCoordinate:"35916",
                ZCoordinate:"4"
            ),
            Room(
                Name:"URBN 2A11",
                Zone:"classroom_2a11_2a",
                Floor:"2A",
                Number:"2A11",
                Type:"Classroom",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"25875",
                YCoordinate:"38220",
                ZCoordinate:"4"
            ),
            Room(
                Name:"URBN 2A20",
                Zone:"lab_2a20_2a",
                Floor:"2A",
                Number:"2A20",
                Type:"Lab",
                Description:"A product design lab that benefits from its large windows with lots of space for sticky notes.",
                Features:"Large TV, 3D Printer, Computers",
                XCoordinate:"32020",
                YCoordinate:"19319",
                ZCoordinate:"4"
            ),
            Room(
                Name:"URBN 2A21",
                Zone:"lab_2a21_2a",
                Floor:"2A",
                Number:"2A21",
                Type:"Lab",
                Description:"Dubbed the Den of Sin, a product design lab that has no natural light or light from outside rooms.",
                Features:"Computers",
                XCoordinate:"30236",
                YCoordinate:"18633",
                ZCoordinate:"4"
            ),
            Room(
                Name:"URBN 302",
                Zone:"lab_302_3",
                Floor:"3",
                Number:"302",
                Type:"Lab",
                Description:"A drawing studio with open space for setting up easels.",
                Features:"Projector",
                XCoordinate:"45111",
                YCoordinate:"45972",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 310",
                Zone:"office_310_3",
                Floor:"3",
                Number:"310",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"27065",
                YCoordinate:"48275",
                ZCoordinate:"5"
            ),
            
            
            Room(
                Name:"URBN 310",
                Zone:"office_310_3",
                Floor:"3",
                Number:"310",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"27065",
                YCoordinate:"48275",
                ZCoordinate:"5"
            ),
            
            
            Room(
                Name:"URBN 310a",
                Zone:"office_310a_3",
                Floor:"3",
                Number:"310a",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"39919",
                YCoordinate:"49334",
                ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310b",
                Zone:"office_310b_3",
                Floor:"3",
                Number:"310b",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"39972",
                YCoordinate:"51553",
                ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310c",
                Zone:"office_310c_3",
                Floor:"3",
                Number:"310c",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"38379",
                YCoordinate:"52239",
                ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310d",
                Zone:"office_310d_3",
                Floor:"3",
                Number:"310d",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"35413",
                YCoordinate:"52254",
                ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310e",
                Zone:"office_310e_3",
                Floor:"3",
                Number:"310e",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"32402",
                YCoordinate:"52262",
                ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310f",
                Zone:"office_310f_3",
                Floor:"3",
                Number:"310e",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"29375",
                YCoordinate:"52247",
                ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310g",
                Zone:"office_310g_3",
                Floor:"3",
                Number:"310g",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"26409",
                YCoordinate:"52270",
                ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310h",
                Zone:"office_310h_3",
                Floor:"3",
                Number:"310h",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",

                XCoordinate:"23321",
                YCoordinate:"52247",
                ZCoordinate:"5"
            ),
                Room(
                    Name:"URBN 310j",
                    Zone:"office_310j_3",
                    Floor:"3",
                    Number:"310j",
                    Type:"Office",
                    Description:"The offices of the Department of Design faculty",
                    Features:"Faculty",
                    XCoordinate:"20302",
                    YCoordinate:"52262",
                    ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310k",
                Zone:"office_310k_3",
                Floor:"3",
                Number:"310k",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"22643",
                YCoordinate:"51004",
                ZCoordinate:"5"
            ),  Room(
                Name:"URBN 310m",
                Zone:"office_310m_3",
                Floor:"3",
                Number:"310m",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"32112",
                YCoordinate:"51004",
                ZCoordinate:"5"
            ),
                Room(
                    Name:"URBN 310n",
                    Zone:"office_310n_3",
                    Floor:"3",
                    Number:"310n",
                    Type:"Office",
                    Description:"The offices of the Department of Design faculty",
                    Features:"Faculty",
                    XCoordinate:"35299",
                    YCoordinate:"51004",
                    ZCoordinate:"5"
            ), Room(
                Name:"URBN 310p",
                Zone:"office_310p_3",
                Floor:"3",
                Number:"310p",
                Type:"Office",
                Description:"The offices of the Department of Design faculty",
                Features:"Faculty",
                XCoordinate:"37403",
                YCoordinate:"50989",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 321",
                Zone:"lab_321_3",
                Floor:"3",
                Number:"321",
                Type:"Lab",
                Description:"A large space that acts as fashion research lab.",
                Features:"Projector, Computer",
                XCoordinate:"24793",
                YCoordinate:"44585",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 322",
                Zone:"classroom_322_3",
                Floor:"3",
                Number:"322",
                Type:"Classroom",
                Description:"A large open lab with sewing stations and general fashion work.",
                Features:"Sewing",
                XCoordinate:"8996",
                YCoordinate:"47726",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 323",
                Zone:"lab_323_3",
                Floor:"3",
                Number:"323",
                Type:"Lab",
                Description:"A laundry room for fashion students' projects, not community access.",
                Features:"Washer, Dryer",

                XCoordinate:"10650",
                YCoordinate:"46140",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 324",
                Zone:"lab_324_3",
                Floor:"3",
                Number:"324",
                Type:"Lab",
                Description:"A large open lab with sewing stations and general fashion work.",
                Features:"Sewing",
                XCoordinate:"6038",
                YCoordinate:"46864",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 325",
                Zone:"classroom_325_3",
                Floor:"3",
                Number:"325",
                Type:"Classroom",
                Description:"A lab for research and general design work.",
                Features:"Computers",
                XCoordinate:"9408",
                YCoordinate:"40834",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 326",
                Zone:"lab_326_3",
                Floor:"3",
                Number:"326",
                Type:"Lab",
                Description:"A large open lab with sewing stations and general fashion work.",
                Features:"Sewing",
                XCoordinate:"7380",
                YCoordinate:"40559",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 327",
                Zone:"lab_327_3",
                Floor:"3",
                Number:"327",
                Type:"Lab",
                Description:"A sewing station for fashion students' projects.",
                Features:"Sewing",
                XCoordinate:"9408",
                YCoordinate:"29146",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 328",
                Zone:"classroom_328_3",
                Floor:"3",
                Number:"328",
                Type:"Classroom",
                Description:"A large open lab with sewing stations and general fashion work.",
                Features:"Sewing",
                XCoordinate:"9972",
                YCoordinate:"15202",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 329",
                Zone:"classroom_329_3",
                Floor:"3",
                Number:"329",
                Type:"Classroom",
                Description:"A sewing station for fashion students' projects.",
                Features:"Sewing",
                XCoordinate:"11679",
                YCoordinate:"22002",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 330",
                Zone:"classroom_330_3",
                Floor:"3",
                Number:"330",
                Type:"Classroom",
                Description:"A large open lab with sewing stations and general fashion work.",
                Features:"Sewing",
                XCoordinate:"10795",
                YCoordinate:"8035",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 331",
                Zone:"classroom_331_3",
                Floor:"3",
                Number:"331",
                Type:"Classroom",
                Description:"A classroom that doubles as a storage area for fashions students",
                Features:"Archives",
                XCoordinate:"11710",
                YCoordinate:"15141",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 333",
                Zone:"classroom_333_3",
                Floor:"3",
                Number:"333",
                Type:"Classroom",
                Description:"A studio and storage space for fashion students",
                Features:"Sewing, Archives",
                XCoordinate:"11710",
                YCoordinate:"10521",
                ZCoordinate:"5"
            ),
           
            Room(
                Name:"URBN 340",
                Zone:"classroom_340_3",
                Floor:"3",
                Number:"340",
                Type:"Classroom",
                Description:"Dubbed the Mary McCue Epstein Classroom, a computer lab for general research and work",
                Features:"Computers",
                XCoordinate:"33393",
                YCoordinate:"7791",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 341A",
                Zone:"classroom_341a_3",
                Floor:"3",
                Number:"341A",
                Type:"Classroom",

                Description:"An open area in the hallway that doubles as a meeting place and classroom.",
                Features:"TV, Movable Walls",
                XCoordinate:"30770",
                YCoordinate:"12808",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 341B",
                Zone:"classroom_341b_3",
                Floor:"3",
                Number:"341B",
                Type:"Classroom",
                Description:"An open area in the hallway that doubles as a meeting place and classroom.",
                Features:"TV, Movable Walls",
                XCoordinate:"31639",
                YCoordinate:"20218",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 341C",
                Zone:"classroom_341c_3",
                Floor:"3",
                Number:"341C",
                Type:"Classroom",

                Description:"An open area in the hallway that doubles as a meeting place and classroom.",
                Features:"TV, Movable Walls",
                XCoordinate:"32188",
                YCoordinate:"25311",
                ZCoordinate:"5"
            ),
            
            Room(
                Name:"URBN 347",
                Zone:"office_347_3",
                Floor:"3",
                Number:"347",
                Type:"Office",
                Description:"A computer lab for general research and work",
                Features:"Computers",
                XCoordinate:"35909",
                YCoordinate:"22338",
                ZCoordinate:"5"
            ),
            
            
            Room(
                Name:"URBN 343",
                Zone:"office_343_3",
                Floor:"3",
                Number:"343",
                Type:"Office",
                Description:"An office that doubles as a studio space.",
                Features:"Building stations, Computers",
                XCoordinate:"43655",
                YCoordinate:"13585",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 345",
                Zone:"office_345_3",
                Floor:"3",
                Number:"345",
                Type:"Office",
                Description:"A computer lab for general research and work",
                Features:"Computers",
                XCoordinate:"43670",
                YCoordinate:"19578",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 348",
                Zone:"classroom_348_3",
                Floor:"3",
                Number:"348",
                Type:"Classroom",
                Description:"A room used primarily for presentations or group meetings.",
                Features:"Projector",
                XCoordinate:"45987",
                YCoordinate:"31700",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 349",
                Zone:"lab_349_3",
                Floor:"3",
                Number:"349",
                Type:"Classroom",
                Description:"Dubbed the Screening Room, a larger area used for classes and events",
                Features:"Projector, Theater-style seating",
XCoordinate:"35649",
                YCoordinate:"30267",
                ZCoordinate:"5"
            ),
            
            Room(
                Name:"URBN 301",
                Zone:"lab_301_3",
                Floor:"3",
                Number:"301",
                Type:"Classroom",
                Description:"Dubbed the Screening Room, a larger area used for classes and events",
                Features:"Projector, Theater-style seating",
                XCoordinate:"33286",
                YCoordinate:"37571",
                ZCoordinate:"5"
            ),
            
        
            Room(
                Name:"Floor 3 Men's Restroom",
                Zone:"bathroomMens_371_3",
                Floor:"3",
                Number:"371",
                Type:"Restroom",
                Description:"A men's restroom",
                Features:"Water Fountain, Restroom",
                XCoordinate:"49144",
                YCoordinate:"19502",
                ZCoordinate:"5"
            ),
            Room(
                Name:"Floor 3 Unisex Restroom",
                Zone:"bathroomUnisex_372_3",
                Floor:"3",
                Number:"372",
                Type:"Restroom",
                Description:"A unisex restroom with handicap-accessibility",
                Features:"Water Fountain, Restroom",
                XCoordinate:"47787",
                YCoordinate:"20340",
                ZCoordinate:"5"
            ),
            Room(
                Name:"Floor 3 Women's Restroom",
                Zone:"bathroomWomens_373_3",
                Floor:"3",
                Number:"373",
                Type:"Restroom",
                Description:"A women's restroom",
                Features:"Water Fountain, Restroom",
                XCoordinate:"49266",
                YCoordinate:"26379",
                ZCoordinate:"5"
            ),
            Room(
                Name:"URBN 3A11",
                Zone:"classroom_3a11_3a",
                Floor:"3A",
                Number:"3A11",
                Type:"Classroom",
                Description:"A general computer lab that functions as a classroom",
                Features:"Computers",
                XCoordinate:"25952",
                YCoordinate:"38165",
                ZCoordinate:"6"
            ),
            Room(
                Name:"Floor 3 Computer Lab",
                Zone:"lab_computer_3a",
                Floor:"3A",
                Number:"3A12",
                Type:"Lab",
                Description:"A general computer lab with a large printer used primarily by Architecture students",
                Features:"Computers, Printer",
                XCoordinate:"23969",
                YCoordinate:"29443",
                ZCoordinate:"6"
            ),
            Room(
                Name:"URBN 3A20",
                Zone:"lab_3a20_3a",
                Floor:"3A",
                Number:"3A20",
                Type:"Lab",
                Description:"The Westphal Print Center, that handles quality prints for items around the URBN Center and most students' work",
                Features:"Laser Printing, Large and Small Prints",
                XCoordinate:"32356",
                YCoordinate:"25708",
                ZCoordinate:"6"
            ),
            Room(
                Name:"URBN 3A21",
                Zone:"classroom_3a21_3a",
                Floor:"3A",
                Number:"3A21",
                Type:"Classroom",
                Description:"This classroom also functions as a library of sorts for materials relating to programs housed in the URBN Center",
                Features:"Library, Computer",
                XCoordinate:"30114",
                YCoordinate:"14340",
                ZCoordinate:"6"
            ),
            Room(
                Name:"URBN 401",
                Zone:"lab_401_4",
                Floor:"4",
                Number:"401",
                Type:"Lab",
                Description:"A general computer lab that functions as a classroom and graphic design studio",
                Features:"Computers, Cutting board, Photo studio",
                XCoordinate:"33804",
                YCoordinate:"37708",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 402",
                Zone:"classroom_402_4",
                Floor:"4",
                Number:"402",
                Type:"Classroom",
                Description:"A general computer lab that functions as a classroom and graphic design studio",
                Features:"Computers, Cutting board",
                XCoordinate:"47634",
                YCoordinate:"46674",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 406",
                Zone:"classroom_406_4",
                Floor:"4",
                Number:"406",
                Type:"Classroom",
                Description:"A general computer lab that functions as a classroom and graphic design studio",
                Features:"Computers, Cutting board",
                XCoordinate:"46948",
                YCoordinate:"47726",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 408",
                Zone:"classroom_408_4",
                Floor:"4",
                Number:"408",
                Type:"Classroom",
                Description:"A general drawing studio",
                Features:"Easels",
                XCoordinate:"29916",
                YCoordinate:"47467",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 410",
                Zone:"office_410_4",
                Floor:"4",
                Number:"410",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"14965",
                YCoordinate:"47718",
                ZCoordinate:"7"
            ),
            
            
            
            
            
            
            
            Room(
                Name:"URBN 410a",
                Zone:"office_410a_4",
                Floor:"4",
                Number:"410a",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"27873",
                YCoordinate:"51965",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410b",
                Zone:"office_410b_4",
                Floor:"4",
                Number:"410b",
               Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"24808",
                YCoordinate:"52010",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410c",
                Zone:"office_410c_4",
                Floor:"4",
                Number:"410c",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"21728",
                YCoordinate:"51995",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410d",
                Zone:"office_410d_4",
                Floor:"4",
                Number:"410d",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"18892",
                YCoordinate:"52010",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410e",
                Zone:"office_410e_4",
                Floor:"4",
                Number:"410e",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"15751",
                YCoordinate:"51995",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410f",
                Zone:"office_410f_4",
                Floor:"4",
                Number:"410f",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"14295",
                YCoordinate:"51393",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410g",
                Zone:"office_410g_4",
                Floor:"4",
                Number:"410g",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"14302",
                YCoordinate:"50440",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410h",
                Zone:"office_410h_4",
                Floor:"4",
                Number:"410h",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",

                XCoordinate:"16650",
                YCoordinate:"50836",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410j",
                Zone:"office_410j_4",
                Floor:"4",
                Number:"410j",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"19845",
                YCoordinate:"50836",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410k",
                Zone:"office_410k_4",
                Floor:"4",
                Number:"410k",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"23207",
                YCoordinate:"50836",
                ZCoordinate:"7"
            ),
            
            Room(
                Name:"URBN 410l",
                Zone:"office_410l_4",
                Floor:"4",
                Number:"410l",
                Type:"Office",
                Description:"The offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"25304",
                YCoordinate:"50852",
                ZCoordinate:"7"
            ),
            
            
            Room(
                Name:"URBN 420",
                Zone:"lab_420_4",
                Floor:"4",
                Number:"420",
                Type:"Lab",
                Description:"An incredibly large lab that houses the work of most of the Architecture program in the URBN center.",
                Features:"Computers, Cutting board, Building Stations",
                XCoordinate:"6053",
                YCoordinate:"26226",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 421",
                Zone:"classroom_421_4",
                Floor:"4",
                Number:"421",
                Type:"Classroom",
                Description:"An open area in the hallway that doubles as a meeting place and classroom.",
                Features:"TV, Movable Walls",
                XCoordinate:"13601",
                YCoordinate:"41855",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 423",
                Zone:"classroom_423_4",
                Floor:"4",
                Number:"423",
                Type:"Classroom",
                Description:"An open area in the hallway that doubles as a meeting place and classroom.",
                Features:"TV, Movable Walls",
                XCoordinate:"13631",
                YCoordinate:"38607",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 425",
                Zone:"classroom_425_4",
                Floor:"4",
                Number:"425",
                Type:"Classroom",
                Description:"An open area in the hallway that doubles as a meeting place and classroom.",
                Features:"TV, Movable Walls",
                XCoordinate:"13585",
                YCoordinate:"31060",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 426",
                Zone:"lab_426_4",
                Floor:"4",
                Number:"426",
                Type:"Lab",
                Description:"A general studio for work",
                Features:"Building station",
                XCoordinate:"12289",
                YCoordinate:"6541",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 427a",
                Zone:"classroom_427a_4",
                Floor:"4",
                Number:"427a",
                Type:"Classroom",
                Description:"An open area of the hall that doubles as a classroom",
                Features:"Movable Walls, TVs",                XCoordinate:"13753",
                YCoordinate:"21621",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 427b",
                Zone:"classroom_427b_4",
                Floor:"4",
                Number:"427b",
                Type:"Classroom",
                Description:"An open area of the hall that doubles as a classroom",
                Features:"Movable Walls, TVs",                XCoordinate:"23283",
                YCoordinate:"22463",
                ZCoordinate:"7"
            )
            ,
            Room(
                Name:"URBN 427c",
                Zone:"classroom_427c_4",
                Floor:"4",
                Number:"427c",
                Type:"Classroom",
                Description:"An open area of the hall that doubles as a classroom",
                Features:"Movable Walls, TVs",                XCoordinate:"23253",
                YCoordinate:"12335",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 427d",
                Zone:"classroom_427d_4",
                Floor:"4",
                Number:"427d",
              Type:"Classroom",
                Description:"An open area of the hall that doubles as a classroom",
                Features:"Movable Walls, TVs",                XCoordinate:"13723",
                YCoordinate:"11969",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 430",
                Zone:"lab_430_4",
                Floor:"4",
                Number:"430",
                Type:"Lab",
                Description:"A general lab for building projects and cultivating future designs",
                Features:"3D printer",
                XCoordinate:"27644",
                YCoordinate:"4742",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 432",
                Zone:"classroom_432_4",
                Floor:"4",
                Number:"432",
                Type:"Classroom",
                Description:"A general computer lab that functions as a classroom and graphic design studio",
                Features:"Computers, Cutting board",
                XCoordinate:"41855",
                YCoordinate:"6571",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 434",
                Zone:"classroom_434_4",
                Floor:"4",
                Number:"434",
                Type:"Classroom",
                Description:"A general computer lab that functions as a classroom and graphic design studio",
                Features:"Computers, Cutting board",
                XCoordinate:"44356",
                YCoordinate:"6510",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 435",
                Zone:"classroom_435_4",
                Floor:"4",
                Number:"435",
                Type:"Classroom",
                Description:"A general computer lab that functions as a classroom and graphic design studio",
                Features:"Computers, Cutting board",                XCoordinate:"43853",
                YCoordinate:"17489",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 436",
                Zone:"classroom_436_4",
                Floor:"4",
                Number:"436",
                Type:"Classroom",
                Description:"Dubbed the EZ Freshman Graphic Design Lab, a general computer lab that functions as a classroom",
                Features:"Computers",
                XCoordinate:"45759",
                YCoordinate:"14439",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 437",
                Zone:"lab_437_4",
                Floor:"4",
                Number:"437",
                Type:"Lab",
                Description:"A lab that doubles as a storage room for the programs on Floor 4",
                Features:"Storage, Computers",
                XCoordinate:"43868",
                YCoordinate:"19990",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 439",
                Zone:"lab_439_4",
                Floor:"4",
                Number:"439",
                Type:"Lab",
                Description:"One of the libraries of Floor 4 that holds information about programs at the URBN Center",
                Features:"Library",
                XCoordinate:"38165",
                YCoordinate:"27797",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 440",
                Zone:"classroom_440_4",
                Floor:"4",
                Number:"440",
                Type:"Classroom",
                Description:"A classroom that doubles as a conference room for faculty and students of Floor 4.",
                Features:"Projector",
                XCoordinate:"45987",
                YCoordinate:"31746",
                ZCoordinate:"7"
            ) ,
            Room(
                Name:"Floor 4 Men's Restroom",
                Zone:"bathroomMens_471_4",
                Floor:"4",
                Number:"471",
                Type:"Restroom",
                Description:"A men's restroom",
                Features:"Water Fountain, Restroom",
                XCoordinate:"49144",
                YCoordinate:"19441",
                ZCoordinate:"7"
            ),
            Room(
                Name:"Floor 4 Unisex Restroom",
                Zone:"bathroomUnisex_472_4",
                Floor:"4",
                Number:"472",
                Type:"Restroom",
                Description:"A unisex restroom with handicap-accessibility",
                Features:"Water Fountain, Restroom",

                XCoordinate:"47710",
                YCoordinate:"20325",
                ZCoordinate:"7"
            ),
            Room(
                Name:"Floor 4 Women's Restroom",
                Zone:"bathroomWomens_473_4",
                Floor:"4",
                Number:"473",
                Type:"Restroom",
                Description:"A women's restroom with handicap-accessibility",
                Features:"Water Fountain, Restroom",
                
                XCoordinate:"49281",
                YCoordinate:"26409",
                ZCoordinate:"7"
            ),
            Room(
                Name:"URBN 4A10A",
                Zone:"office_4a10a_4a",
                Floor:"4A",
                Number:"4A10A",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"21553",
                YCoordinate:"30823",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10B",
                Zone:"office_4a10b_4a",
                Floor:"4A",
                Number:"4A10B",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",

                XCoordinate:"21034",
                YCoordinate:"33881",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10C",
                Zone:"office_4a10c_4a",
                Floor:"4A",
                Number:"4A10C",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"21042",
                YCoordinate:"38112",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10D",
                Zone:"office_4a10d_4a",
                Floor:"4A",
                Number:"4A10D",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"20256",
                YCoordinate:"43388",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10E",
                Zone:"office_4a10e_4a",
                Floor:"4A",
                Number:"4A10E",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"21766",
                YCoordinate:"43365",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10F",
                Zone:"office_4a10f_4a",
                Floor:"4A",
                Number:"4A10F",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"24061",
                YCoordinate:"43395",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10G",
                Zone:"office_4a10g_4a",
                Floor:"4A",
                Number:"4A10G",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"22063",
                YCoordinate:"41451",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10H",
                Zone:"office_4a10h_4a",
                Floor:"4A",
                Number:"4A10H",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"22086",
                YCoordinate:"38402",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10J",
                Zone:"office_4a10j_4a",
                Floor:"4A",
                Number:"4A10J",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"22094",
                YCoordinate:"33911",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A10L",
                Zone:"office_4a10l_4a",
                Floor:"4A",
                Number:"4A10L",
                Type:"Office",
                Description:"One of the offices of the Media Arts faculty",
                Features:"Faculty",
                XCoordinate:"24686",
                YCoordinate:"32005",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A20A",
                Zone:"office_4a20a_4a",
                Floor:"4A",
                Number:"4A20A",
                Type:"Office",
                Description:"One of the offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"36259",
                YCoordinate:"24564",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A20B",
                Zone:"office_4a20b_4a",
                Floor:"4A",
                Number:"4A20B",
                Type:"Office",
                Description:"One of the offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"34643",
                YCoordinate:"22178",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A20C",
                Zone:"office_4a20c_4a",
                Floor:"4A",
                Number:"4A20C",
                Type:"Office",
                Description:"One of the offices of the Architecture and Interiors faculty",
                Features:"Faculty",

                XCoordinate:"35207",
                YCoordinate:"19281",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A20D",
                Zone:"office_4a20d_4a",
                Floor:"4A",
                Number:"4A20D",
                Type:"Office",
                Description:"One of the offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"33492",
                YCoordinate:"13906",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A20E",
                Zone:"office_4a20e_4a",
                Floor:"4A",
                Number:"4A20E",
                Type:"Office",
                Description:"One of the offices of the Architecture and Interiors faculty",
                Features:"Faculty",

                XCoordinate:"32180",
                YCoordinate:"13913",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A20F",
                Zone:"office_4a20f_4a",
                Floor:"4A",
                Number:"4A20F",
                Type:"Office",
                Description:"One of the offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"35405",
                YCoordinate:"12556",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A20G",
                Zone:"office_4a20g_4a",
                Floor:"4A",
                Number:"4A20G",
                Type:"Office",
                Description:"One of the offices of the Architecture and Interiors faculty",
                Features:"Faculty",
                XCoordinate:"34193",
                YCoordinate:"12541",
                ZCoordinate:"8"
            ),
            Room(
                Name:"URBN 4A20H",
                Zone:"office_4a20h_4a",
                Floor:"4A",
                Number:"4A20H",
                Type:"Office",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"31746",
                YCoordinate:"12549",
                ZCoordinate:"8"
            )
        ]
    }
}

extension SearchVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
