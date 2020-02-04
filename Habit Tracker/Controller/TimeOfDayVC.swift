//
//  TimeOfDayVC.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 29..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import UIKit
import RealmSwift



class TimeOfDayVC: UITableViewController{
    
    let realm = try! Realm()
    var settings: Results<Settings>?
    var sendersTag:Int = 0
    
    
    @IBOutlet weak var morningLbl: UILabel!
    @IBOutlet weak var afternoonLbl: UILabel!
    @IBOutlet weak var eveningLbl: UILabel!
    
    func refresLbls(){
        morningLbl.text = settings![0].morningStartsAt
        afternoonLbl.text = settings![0].afternoonStartsAt
        eveningLbl.text = settings![0].eveningStartsAt
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings  = self.realm.objects(Settings.self)
        refresLbls()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    func showDatePicker(_ sender: UITableViewCell) {
        sendersTag = sender.tag
        let datePicker = UIDatePicker()//Date picker
        let datePickerSize = CGSize(width: 320, height: 216) //Date picker size
        datePicker.frame = CGRect(x: 0, y: 0, width: datePickerSize.width, height: datePickerSize.height)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        datePicker.locale = Locale(identifier: "en_GB")
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm"
        print(dateFormatterGet.string(from: datePicker.date))
        if sendersTag == 0{
            datePicker.setDate(dateFormatterGet.date(from: settings![0].morningStartsAt)!, animated: true)
            
        }else if sendersTag == 1{
            datePicker.setDate(dateFormatterGet.date(from: settings![0].afternoonStartsAt)!, animated: true)
        }else if sendersTag == 2{
            datePicker.setDate(dateFormatterGet.date(from: settings![0].eveningStartsAt)!, animated: true)
        }
        
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(datePicker)
        // here you can add tool bar with done and cancel buttons if required
        
        
        let popoverViewController = UITableViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: datePickerSize.width, height: datePickerSize.height)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = datePickerSize
        popoverViewController.popoverPresentationController?.sourceView = sender// source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        popoverViewController.popoverPresentationController?.delegate = self // to handle popover delegate methods
        self.present(popoverViewController, animated: true, completion:{ () -> () in
            
        })
        
        
    }
    
    @objc func dateChanged(_ datePicker:UIDatePicker) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm"        
        try! self.realm.write {
            if sendersTag == 0{
                self.settings![0].morningStartsAt = dateFormatterGet.string(from: datePicker.date)
            }else if sendersTag == 1{
                self.settings![0].afternoonStartsAt = dateFormatterGet.string(from: datePicker.date)
            }else if sendersTag == 2{
                self.settings![0].eveningStartsAt = dateFormatterGet.string(from: datePicker.date)
            }
        }
        refresLbls()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDatePicker(tableView.cellForRow(at: indexPath)!)
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension TimeOfDayVC : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Force popover style
        return UIModalPresentationStyle.none
    }
}
