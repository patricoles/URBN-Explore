//
//  TourList.swift
//  URBN-Explore


import UIKit

class TourList: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    let swipeRec = UISwipeGestureRecognizer()
    
    @IBOutlet weak var swipeImage: UIImageView!
    
    var rooms = [Room]()
    var tourCurrentRoomValue:Int = 0
    var selectedRowInt:Int = 0
    var currentRoom: String = ""
    
    var visitStatus = "Not Visited"
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tourBottomLabel: UILabel!
    override func viewDidLoad() {
        createRoomStructure()
        
        nextButton.layer.cornerRadius = 7
        prevButton.layer.cornerRadius = 7
        
        //set the target of the gesture recognizers for each view
        swipeRec.addTarget(self, action:"swipedView")
        
        swipeRec.direction = UISwipeGestureRecognizerDirection.Down
        
        
        //we add the gesture recognizers to the views
        swipeImage.addGestureRecognizer(swipeRec)
        
        //e set the userInteractionEnabled property of each view to true
        swipeImage.userInteractionEnabled = true
        
        tourBottomLabel.text = String(tourCurrentRoomValue) + "/10"
        print("Interger Passed from Map VC \(tourCurrentRoomValue)")
        
        
        
    }
    
    func swipedView(){
        
        print("User swiped down to dismiss the view")
        self.performSegueWithIdentifier("tourTableViewToMap", sender: self)
        
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return rooms.count
        
        
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tourCell", forIndexPath: indexPath) as? TourCell
        let room: Room
        
        var indexRow = Int(indexPath.row)
        indexRow += 1
        
        
        room = rooms[indexPath.row]
        
        cell?.roomName!.text = room.Number + " - " + room.Name
        
        if tourCurrentRoomValue == indexRow {
            let image : UIImage = UIImage(named: "icon_circle_active")!
            cell?.circleImage.image = image
        } else if tourCurrentRoomValue < indexRow {
            let image : UIImage = UIImage(named: "icon_circle_not_visited")!
            cell?.circleImage.image = image
            
            
        } else if tourCurrentRoomValue > indexRow {
            let image : UIImage = UIImage(named: "icon_circle_visited")!
            cell?.circleImage.image = image
        }
        
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segure Function with identfier
        // Get Selected Row Index Value
        let rows = indexPath.row
        selectedRowInt = rows
        
        tourBottomLabel.text = String(selectedRowInt) + "/10"
        print("Row selected Interger: \(selectedRowInt)")
        
        TableView.reloadData()
        self.performSegueWithIdentifier("tourTableToMapSelectRow", sender: indexPath);
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "tourTableToMapSelectRow") {
            
        }
    }
    
    
    @IBAction func previousButton(sender: AnyObject) {
        if tourCurrentRoomValue  > 1 {
            tourCurrentRoomValue -= 1
            
            tourBottomLabel.text = String(tourCurrentRoomValue) + "/10"
            print("Row selected Interger: \(tourCurrentRoomValue)")
            
            TableView.reloadData()
        } else if tourCurrentRoomValue  == 1 {
            tourCurrentRoomValue = 10
            TableView.reloadData()

        }
        
    }
    
    @IBAction func nextRoom(sender: AnyObject) {
        if tourCurrentRoomValue < 10 {
            tourCurrentRoomValue += 1
            
            tourBottomLabel.text = String(tourCurrentRoomValue) + "/10"
            print("Row selected Interger: \(tourCurrentRoomValue)")
            
            TableView.reloadData()
        } else if tourCurrentRoomValue  == 10 {
            tourCurrentRoomValue = 1
            TableView.reloadData()

            
        }
        
    }
    
    
    
    func createRoomStructure() {
        rooms = [
            Room(
                Name:"Building Entrance",
                Zone:"Building Entrance",
                Floor:"1",
                Number:"100",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Advisors Office",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103J",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Audio Lab",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"108",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"Archives",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"110",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),
            Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            ),     Room(
                Name:"URBN 103",
                Zone:"lab_103_1",
                Floor:"1",
                Number:"103",
                Type:"Lab",
                Description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                Features:"Feature 1, Feature 2, Feature 3",
                XCoordinate:"33796",
                YCoordinate:"27444",
                ZCoordinate:"1"
            )
        ]
    }
    
    
}
