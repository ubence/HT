//
//  MenuViewController.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 19..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import UIKit
import RealmSwift

class MenuViewController: UITableViewController {
    
    
   
    var menuItems: [String] = ["Szokások", "Beállítások"]
    
    override func viewDidLoad() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
 
        super.viewDidLoad()
        self.tableView.rowHeight = 80.0
        
        if #available(iOS 13.0, *) {
            let app = UINavigationBarAppearance()
            self.navigationController?.navigationBar.scrollEdgeAppearance = app
        }
        //tableView.separatorStyle = .none
        
    }
    
    
    
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        var returnValue = 0
//
////        switch(segmentedC.selectedSegmentIndex)
////        {
////        case 0:
////            returnValue = rest.count
////            break
////        case 1:
////            returnValue = fullMenu.count
////            break
////        default:
////            break
////
////        }
//
//        return returnValue
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: menuItems[indexPath.row], sender: self)
    }
    
}






