//
//  NotificationSVCTableViewController.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 29..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import UIKit
import RealmSwift

class NotificationsVC: UITableViewController {
    let realm = try! Realm()
    var settings: Results<Settings>?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        settings  = self.realm.objects(Settings.self)
        for i in 0...tableView.numberOfRows(inSection: 0){
            switch i {
            case 0:
                tableView.cellForRow(at: NSIndexPath(row: i, section: 0) as IndexPath)?.accessoryType = settings![0].isAllDayNotificationTurnedOn ? .checkmark : .none
                break
            case 1:
                tableView.cellForRow(at: NSIndexPath(row: i, section: 0) as IndexPath)?.accessoryType = settings![0].isAMorningNotificationTurnedOn ? .checkmark : .none
                break
            case 2:
                tableView.cellForRow(at: NSIndexPath(row: i, section: 0) as IndexPath)?.accessoryType = settings![0].isAfternoonNotificationTurnedOn  ? .checkmark : .none
                break
            case 3:
                tableView.cellForRow(at: NSIndexPath(row: i, section: 0) as IndexPath)?.accessoryType = settings![0].isEveningNotificationTurnedOn ? .checkmark : .none
                break
            case 4:
                tableView.cellForRow(at: NSIndexPath(row: i, section: 0) as IndexPath)?.accessoryType = settings![0].isResultNotificationTurnedOn ? .checkmark : .none
                break
            default:
                tableView.cellForRow(at: NSIndexPath(row: i, section: 0) as IndexPath)?.accessoryType = .none
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        try! realm.write {
            switch indexPath.row {
            case 0:
                settings![0].isAllDayNotificationTurnedOn = !settings![0].isAllDayNotificationTurnedOn
                tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath)?.accessoryType = settings![0].isAllDayNotificationTurnedOn ? .checkmark : .none
                break
            case 1:
                settings![0].isAMorningNotificationTurnedOn = !settings![0].isAMorningNotificationTurnedOn
                tableView.cellForRow(at: NSIndexPath(row: 1, section: 0) as IndexPath)?.accessoryType = settings![0].isAMorningNotificationTurnedOn ? .checkmark : .none
                break
            case 2:
                settings![0].isAfternoonNotificationTurnedOn = !settings![0].isAfternoonNotificationTurnedOn
                tableView.cellForRow(at: NSIndexPath(row: 2, section: 0) as IndexPath)?.accessoryType = settings![0].isAfternoonNotificationTurnedOn ? .checkmark : .none
                break
            case 3:
                settings![0].isEveningNotificationTurnedOn = !settings![0].isEveningNotificationTurnedOn
                tableView.cellForRow(at: NSIndexPath(row: 3, section: 0) as IndexPath)?.accessoryType = settings![0].isEveningNotificationTurnedOn ? .checkmark : .none
                break
            case 4:
                settings![0].isResultNotificationTurnedOn = !settings![0].isResultNotificationTurnedOn
                tableView.cellForRow(at: NSIndexPath(row: 4, section: 0) as IndexPath)?.accessoryType = settings![0].isResultNotificationTurnedOn ? .checkmark : .none
                break
            default:
                break
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    
    
    
}

