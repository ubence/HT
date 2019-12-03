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




class HabitViewController: UIViewController{
    
    @IBOutlet weak var segmentedC: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    
    let realm = try! Realm()
    
    var habits: Results<Habit>?
    var morningHabits:Results<Habit>?
    var afternoonHabits:Results<Habit>?
    var eveningHabits:Results<Habit>?
    var allDayHabits:Results<Habit>?
    var doneHabits:Results<Habit>?
    
    var isDayChanged:Bool = false
    var resultsArray: [[[Results<Habit>?]]] = []
    let sectionNameArray = [[["Morning habits"],["Anytime"]],[["Afternoon habits"],["Anytime"]],[["Evening habits"],["Anytime"]],[["Morning habits"],["Afternoon habits"],["Evening habits"],["Anytime"]],[["Done"]]]
    
    var morningStartsAt:Int = 0
    var afternoonStartsAt:Int = 12
    var EveningStartsAt:Int = 18
    
    
    
    //MARK:- Actions
    @IBAction func showStats(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Stats", sender: self)
       
    }
    
    @IBAction func showSettings(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Settings", sender: self)
    }
    


    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @objc func calendarDayDidChange(){
        isDayChanged = true
        DispatchQueue.main.async {
            self.viewDidLoad()
            
        }
    }
    
    func getCurrentTimeOfDay() -> Int{
        let hour = Calendar.current.component(.hour, from: Date())
        if (hour >= morningStartsAt && hour < afternoonStartsAt){
            return 0
        }else if (hour >= afternoonStartsAt && hour < EveningStartsAt){
            return 1
        }else if (hour >= EveningStartsAt){
            return 2
        }else {
            return 3
        }
    }
    
    func createNewStatOnFirstLogin() {
        
        let stat = Stat()
        
        do {
            try realm.write {
                realm.add(stat)
            }
        } catch {
            print("Error saving habit \(error)")
        }
        
    }
    
   
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var stat  = self.realm.objects(Stat.self)
        if stat.count == 0{
            createNewStatOnFirstLogin()
        }
    
        
        
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(self.calendarDayDidChange),
                                                   name:.NSCalendarDayChanged,
                                                   object:nil)}
        
        
        tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        segmentedC.selectedSegmentIndex = getCurrentTimeOfDay()
        segmentedC.frame = CGRect(x: segmentedC.frame.origin.x, y: segmentedC.frame.origin.y, width: segmentedC.frame.size.width, height: 50);
        if(isDayChanged == true){
            isDayChanged = false
            
            for habit in self.habits!{
                
                try! realm.write {
                    
//                    if (habit.itWasDoneOnDates.last! != Date.yesterday) && (habit.isDoneToday == false){
//            
//                        habit.itWasDoneInStreak = 0
//                    }
                    habit.isDoneToday = false
                }
                
            }
        }
        loadHabits()
        
        
        //self.clearsSelectionOnViewWillAppear = true
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addNewHabit" {
            
            let destinationVC = segue.destination as! NewHabitViewController
            
            
            destinationVC.delegate = self
            
        }
        
        if segue.identifier == "showHabitDetails" {
            
            let destinationVC = segue.destination as! HabitDetailVC
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedHabit = resultsArray[segmentedC.selectedSegmentIndex][indexPath.section][0]![indexPath.row]
            }
            if let indexPath = sender as? IndexPath{
                destinationVC.selectedHabit = resultsArray[segmentedC.selectedSegmentIndex][indexPath.section][0]![indexPath.row]
            }
            
        }
        
   
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        createFloatingButton()
        tableView.reloadData()
    }
    
    
    
    func loadHabits() {
        
        habits  = realm.objects(Habit.self)
        morningHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "morning").sorted(byKeyPath: "dateCreated", ascending: true)
        
        afternoonHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "afternoon").sorted(byKeyPath: "dateCreated", ascending: true)
        
        
        eveningHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "evening").sorted(byKeyPath: "dateCreated", ascending: true)
        
        
        allDayHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "any time").sorted(byKeyPath: "dateCreated", ascending: true)
        
        
        doneHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "done").sorted(byKeyPath: "dateCreated", ascending: true)
        
        resultsArray = [[[morningHabits],[allDayHabits]],[[afternoonHabits],[allDayHabits]],[[eveningHabits],[allDayHabits]],[[morningHabits],[afternoonHabits],[eveningHabits],[allDayHabits]],[[doneHabits]]]
        
        tableView.reloadData()
        
    }
    
    
    
    
    
    
    
    
    
    
    private var floatingButton: UIButton?
    private static let buttonHeight: CGFloat = 55.0
    private static let buttonWidth: CGFloat = 55.0
    private let roundValue = HabitViewController.buttonHeight/2
    private let trailingValue: CGFloat = 25.0
    private let leadingValue: CGFloat = 25.0
    private let shadowRadius: CGFloat = 2.0
    private let shadowOpacity: Float = 0.5
    private let shadowOffset = CGSize(width: 0.0, height: 5.0)
    private let scaleKeyPath = "scale"
    private let animationKeyPath = "transform.scale"
    private let animationDuration: CFTimeInterval = 0.6
    private let animateFromValue: CGFloat = 1.00
    private let animateToValue: CGFloat = 1.02

//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        createFloatingButton()
//    }

    public override func viewWillDisappear(_ animated: Bool) {
        guard floatingButton?.superview != nil else {  return }
        DispatchQueue.main.async {
            self.floatingButton?.removeFromSuperview()
            self.floatingButton = nil
        }
        super.viewWillDisappear(animated)
    }

    private func createFloatingButton() {
        floatingButton = UIButton(type: .custom)
        floatingButton?.translatesAutoresizingMaskIntoConstraints = false
        floatingButton?.backgroundColor = .white
        
        
        floatingButton?.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        floatingButton?.addTarget(self, action: #selector(doThisWhenButtonIsTapped(_:)), for: .touchUpInside)
        constrainFloatingButtonToWindow()
        makeFloatingButtonRound()
        addShadowToFloatingButton()
        addScaleAnimationToFloatingButton()
    }

    // TODO: Add some logic for when the button is tapped.
    @IBAction private func doThisWhenButtonIsTapped(_ sender: Any) {
         performSegue(withIdentifier: "addNewHabit", sender: self)
    }

    private func constrainFloatingButtonToWindow() {
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.keyWindow,
                let floatingButton = self.floatingButton else { return }
            keyWindow.addSubview(floatingButton)
            keyWindow.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor,
                                                constant: self.trailingValue).isActive = true
            keyWindow.bottomAnchor.constraint(equalTo: floatingButton.bottomAnchor,
                                              constant: self.leadingValue).isActive = true
            floatingButton.widthAnchor.constraint(equalToConstant:
                HabitViewController.buttonWidth).isActive = true
            floatingButton.heightAnchor.constraint(equalToConstant:
                HabitViewController.buttonHeight).isActive = true
        }
    }

    private func makeFloatingButtonRound() {
        floatingButton?.layer.cornerRadius = roundValue
    }

    private func addShadowToFloatingButton() {
        floatingButton?.layer.shadowColor = UIColor.black.cgColor
        floatingButton?.layer.shadowOffset = shadowOffset
        floatingButton?.layer.masksToBounds = false
        floatingButton?.layer.shadowRadius = shadowRadius
        floatingButton?.layer.shadowOpacity = shadowOpacity
    }

    private func addScaleAnimationToFloatingButton() {
        // Add a pulsing animation to draw attention to button:
        DispatchQueue.main.async {
            let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: self.animationKeyPath)
            scaleAnimation.duration = self.animationDuration
            scaleAnimation.repeatCount = .greatestFiniteMagnitude
            scaleAnimation.autoreverses = true
            scaleAnimation.fromValue = self.animateFromValue
            scaleAnimation.toValue = self.animateToValue
            self.floatingButton?.layer.add(scaleAnimation, forKey: self.scaleKeyPath)
        }
    }
    
    
}



// MARK: - Date Extension

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





// MARK: - New Habit Extension
extension HabitViewController: NewHabitDelegate{
    func userPressedSaveButton() {
        self.tableView.reloadData()
    }
    
}




// MARK: - Table view extension
extension HabitViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        
        if let habit = resultsArray[segmentedC.selectedSegmentIndex][indexPath.section][0]?[indexPath.row] {
            
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
                progressView.progressTintColor = UIColor.flatGray()
                progressView.transform = progressView.transform.scaledBy(x: 1, y: 5)
                progressView.progress = progress
                cell.contentView.addSubview(progressView)
                
            }
        }else {
            cell.textLabel?.text = "No Items Added"
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

       return sectionNameArray[segmentedC.selectedSegmentIndex][section][0]
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsArray[segmentedC.selectedSegmentIndex].count
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
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let item = resultsArray[segmentedC.selectedSegmentIndex][indexPath.section][0]?[indexPath.row] {
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
                }}
        
        
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resultsArray[segmentedC.selectedSegmentIndex][section][0]!.count
        
    }
    
    
    
    func updateModel(at indexPath: IndexPath) {
        if let habit = resultsArray[segmentedC.selectedSegmentIndex][indexPath.section][0]?[indexPath.row] {
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
}


// MARK: - UISegmentedControl Extension

