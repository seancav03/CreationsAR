//
//  MenuViewController.swift
//  CreationsAR
//
//  Created by Sean Cavalieri on 12/11/19.
//  Copyright © 2019 SeanCoding. All rights reserved.
//

import UIKit

/**
 Protocol allows this view controller to pass information back to the main view controller
 */
protocol LoadDesignDelegate: AnyObject {
    func designSelected(design: String, folder: String)
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var designsTable: UITableView!
    
    let fm = FileManager.default
    
    var theItems: [String : [String]] = [
        "My Designs" : [],
        "Shared Designs" : []
    ]
    
    //for passing back design
    weak var theDelegate:LoadDesignDelegate?
    
    //Function gets all information from file system and displays it in categories in the table view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //get names of all designs in 'My Designs' folder
        var arrayOfFileNames: [String] = []
        do {
            let items = try FileManager.default.contentsOfDirectory(at: FileManager.documentDirectoryURL.appendingPathComponent("My Designs"), includingPropertiesForKeys: nil)
//            print("Listing Files: ")
            for item in items {
//                print("Found: ", item)
                let shorterArr = item.path.split(separator: "/")
                var shorter = shorterArr.last!
//                print("Shorter: ", shorter)
                shorter.removeLast(4)
                arrayOfFileNames.append(String(shorter))
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
//            print("2- Failed to read File name in Directory: ")
//            print("Error info: \(error)")
        }
        theItems["My Designs"] = arrayOfFileNames
        
        //get names of all designs in 'Shared Designs'
        var arrayOfFileNames2: [String] = []
        do {
            let items = try FileManager.default.contentsOfDirectory(at: FileManager.documentDirectoryURL.appendingPathComponent("Shared Designs"), includingPropertiesForKeys: nil)
//            print("Listing Files: ")
            for item in items {
//                print("Found: ", item)
                let shorterArr = item.path.split(separator: "/")
                var shorter = shorterArr.last!
//                print("Shorter: ", shorter)
                shorter.removeLast(4)
                arrayOfFileNames2.append(String(shorter))
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
//            print("2- Failed to read File name in Directory: ")
//            print("Error info: \(error)")
        }
        theItems["Shared Designs"] = arrayOfFileNames2
        
        //set up table with data
        self.designsTable.allowsSelection = true
        self.designsTable.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.designsTable.dataSource = self
        self.designsTable.delegate = self
        
        //set up long press listener (for sharing)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.designsTable.addGestureRecognizer(longPress)
        
        //Add Header with Information
        let header = UITableViewCell()
        header.textLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        header.textLabel?.text = "Creations: Tap, Swipe, or Hold"
        //      setting height of header
        let height: CGFloat = 70.0
        var headerFrame = header.frame
        if height != headerFrame.size.height {
            headerFrame.size.height = height
            header.frame = headerFrame
        }
        self.designsTable.tableHeaderView = header
        
    }

    /**
     Open apple share sheet to share the selected design file on long press
     - Parameter gesture: The long press gesture of the user
     */
    @objc
    func longPress(_ gesture: UILongPressGestureRecognizer) {
        //detect press here - Only care about beginning
        if(gesture.state == UIGestureRecognizer.State.began){
            //get row selected
            let location = gesture.location(in: self.designsTable)
            guard let indexPath = self.designsTable.indexPathForRow(at: location) else { return }
            //get name of item pressed
            let item = self.item(at: indexPath)
            //Get file you want to share
            var filesToShare = [Any]()
            let file = FileManager.documentDirectoryURL.appendingPathComponent(key(for: indexPath.section)).appendingPathComponent(item + ".txt")
            filesToShare.append(file)
            //set up share sheet controller
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            //Finally, show the view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    /**
     Helper function get dictionary key in theItems array for section
     - Parameter for: The section for which to search for the dictionary key of
     */
    func key(for section: Int) -> String {
        let keys = Array(self.theItems.keys).sorted { first, last -> Bool in
//            if first == "My Designs" {
//                return true
//            }
            return first < last
        }
        let key = keys[section]
        return key
    }
    
    /**
     Helper function gets array of all Strings from theItems array from a section (i.e., gets all filenames/design names of a section/folder)
     - Parameter in: the section in which to get the names from
     */
    func items(in section: Int) -> [String] {
        let key = self.key(for: section)
        return self.theItems[key]!
    }
    
    /**
     Gets the name of the design selected at a certain index path in the table view
     - Parameter at: The IndexPath of the selected name
     */
    func item(at indexPath: IndexPath) -> String {
        let items = self.items(in: indexPath.section)
        return items[indexPath.item]
    }
    
    /**
     Remove file of item at IndexPath in table view (On swiped and deleted table view cell)
     - Parameter at: The Index Path of the item for which the file will be deleted
     */
    func removeItem(at indexPath: IndexPath) {
        let theKey = key(for: indexPath.section)
        var arr = theItems[theKey]
        let a = arr?.remove(at: indexPath.row)
        theItems[theKey] = arr
        //Deleting file here
        do {
            try fm.removeItem(at: FileManager.documentDirectoryURL.appendingPathComponent(key(for: indexPath.section)).appendingPathComponent(a! + ".txt"))
//            print("Removed File")
        } catch {
//            print("Could not Remove File")
        }
    }

}

//for reading files - Asks iOS operating system where the app can find its files
extension FileManager {
    
    static var documentDirectoryURL: URL {
        let documentDirectoryURL = (try! FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)!
        return documentDirectoryURL
    }
    
}

/**
 Extension loads all needed data and sections into the tableView to be displayed to the user
 */
extension MenuViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.theItems.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items(in: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = item
        cell.tag = indexPath.count
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.key(for: section)
    }
    
}

/**
 Delegate handles function and interactions for the TableView.
 */
extension MenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = self.item(at: indexPath)
        //return item and folder of design selected
        let folder = key(for: indexPath.section)
        //Commented two lines out below for testing
        theDelegate?.designSelected(design: item, folder: folder)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delete from array
            removeItem(at: indexPath)
            //delete form table
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
}
