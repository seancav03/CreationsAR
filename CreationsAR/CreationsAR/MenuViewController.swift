//
//  MenuViewController.swift
//  CreationsAR
//
//  Created by Sean Cavalieri on 12/11/19.
//  Copyright © 2019 SeanCoding. All rights reserved.
//

import UIKit

//how this tableView view controller passes information back to the main
protocol LoadDesignDelegate: AnyObject {
    func designSelected(design: String)
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var designsTable: UITableView!
    
    let defaults = UserDefaults.standard
    
    var theItems: [String : [String]] = [
        "My Designs" : []
    ]
    
    //for passing back design
    weak var theDelegate:LoadDesignDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //get names of all designs
        let arrTemp = defaults.stringArray(forKey: "savedNames")
        if arrTemp != nil {
            theItems["My Designs"] = arrTemp!
        }
        
        
        //set up table with data
        self.designsTable.allowsSelection = true
        self.designsTable.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.designsTable.dataSource = self
        self.designsTable.delegate = self
        
    }
    
    
    //helper functions
    func key(for section: Int) -> String {
        let keys = Array(self.theItems.keys).sorted { first, last -> Bool in
            if first == "My Designs" {
                return true
            }
            return first < last
        }
        let key = keys[section]
        return key
    }
    
    func items(in section: Int) -> [String] {
        let key = self.key(for: section)
        return self.theItems[key]!
    }
    
    func item(at indexPath: IndexPath) -> String {
        let items = self.items(in: indexPath.section)
        return items[indexPath.item]
    }
    func removeItem(at indexPath: IndexPath) {
        let theKey = key(for: indexPath.section)
        var arr = theItems[theKey]
        let a = arr?.remove(at: indexPath.row)
        theItems[theKey] = arr
        //remove from userDefaults
        defaults.removeObject(forKey: a!)
        //remove from savedNames list
        var arry = defaults.stringArray(forKey: "savedNames")
        arry?.removeAll(where: { $0 == a! } )
        defaults.set(arry!, forKey: "savedNames")
    }

}

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

extension MenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = self.item(at: indexPath)
        //ITEM IS THE SELCTED THING!!!
        print("Item: ", item)
        //return
        theDelegate?.designSelected(design: item)
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
