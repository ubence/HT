//
//  HabitsTableViewController.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 20..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class HabitsTableViewController: UITableViewController, NewHabitDelegate, SwipeTableViewCellDelegate{
    
    var isDayChanged:Bool = false
    let realm = try! Realm()
    var habits: Results<Habit>?
    
    func userPressedSaveButton() {
        
        self.tableView.reloadData()
        
    }
    
    @objc func calendarDayDidChange(){
        isDayChanged = true
        DispatchQueue.main.async {
            self.viewDidLoad()}
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(self.calendarDayDidChange),
                                                   name:.NSCalendarDayChanged,
                                                   object:nil)}
        
        
        self.tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        
        if(isDayChanged == true){
            isDayChanged = false
            
            for habit in self.habits!{
                
                try! realm.write {

                    if (habit.itWasDoneOnDates.last! != Date.yesterday) && (habit.isDoneToday == false){
                        print("habit.itWasDoneOnDates.last!")
                        print(habit.itWasDoneOnDates.last!)
                        print("Date.yesterday")
                        print(Date.yesterday)
                        print("habit.isDoneToday != true")
                        print(habit.isDoneToday)
                        habit.itWasDoneInStreak = 0
                    }
                    habit.isDoneToday = false
                }
                
            }
        }
        loadHabits()
        tableView.reloadData()
        
        
        //self.clearsSelectionOnViewWillAppear = true
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = habits?[indexPath.row] {
            do {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy MM dd"
                let startDate = formatter.date(from: formatter.string(from: date))!
                
            
                
                try realm.write {
                    item.isDoneToday = !item.isDoneToday
                    if item.isDoneToday == true {
                        
                        
                        item.itWasDoneInStreak+=1

                        item.itWasDone+=1
                        item.itWasDoneOnDates.append(startDate)
                    }else{
                        item.itWasDone-=1
                        item.itWasDoneOnDates.removeLast()
                        //TODO: item.itWasDoneInStreak = 0
                    }
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addNewHabit" {
            
            let destinationVC = segue.destination as! NewHabitViewController
            
            
            destinationVC.delegate = self
            
        }
        
        if segue.identifier == "showHabitDetails" {
            
            let destinationVC = segue.destination as! HabitDetailVC
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedHabit = habits![indexPath.row]
            }
            if let indexPath = sender as? IndexPath{
                destinationVC.selectedHabit = habits![indexPath.row]
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        tableView.reloadData()
    }
    
    func save(habit: Habit) {
        do {
            try realm.write {
                realm.add(habit)
            }
        } catch {
            print("Error saving habit \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadHabits() {
        
        habits  = realm.objects(Habit.self)
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits?.count ?? 1
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right{
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.updateModel(at: indexPath)
                
            }
            
            // customize the action appearance
            deleteAction.image = UIImage(systemName: "trash")
            
            return [deleteAction]
        }else if orientation == .left{
            let showDetails = SwipeAction(style: .destructive, title: "Show") { action, indexPath in
                self.performSegue(withIdentifier: "showHabitDetails", sender: indexPath)
                
            }
            
            // customize the action appearance
            showDetails.image = UIImage(systemName: "pencil")
            
            return [showDetails]
        }else { return nil }
        
        
    }
    
    func updateModel(at indexPath: IndexPath) {
        if let habit = habits?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(habit)
                }
            } catch {
                print("Error deleting Item, \(error)")
            }
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        
        
        
        
        cell.delegate = self
        
        if let habit = habits?[indexPath.row] {
            
            let progressView = UIProgressView(progressViewStyle: .default)
            let progress = Float(habit.itWasDone) / Float(habit.difficulity)
            
            cell.detailTextLabel?.text = String(progress)
            cell.textLabel?.text = habit.name
            cell.accessoryType = habit.isDoneToday ? .checkmark : .none
            cell.backgroundColor = UIColor(hexString: habit.color).lighten(byPercentage: 0.005)
            
            if cell.contentView.subviews.count == 3{
                
                for i in cell.contentView.subviews{
                    if let obj = i as? UIProgressView{
                        obj.progress = progress
                    }
                }
                
            }else{
                
                progressView.rightAnchor.accessibilityActivate()
                progressView.frame = CGRect(x: 150, y: 45, width: 200, height: 30)
                progressView.progressTintColor = UIColor.black
                progressView.transform = progressView.transform.scaledBy(x: 1, y: 18)
                progressView.progress = progress
                cell.contentView.addSubview(progressView)
                
            }
        }else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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




extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}
