//
//  HabitsTableViewController.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 20..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import ChameleonFramework
import UserNotifications
import Cheers




class HabitViewController: UIViewController{
    
    @IBOutlet weak var segmentedC: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    
    let realm = try! Realm()
    
    var player: AVAudioPlayer?
    
    var habits: Results<Habit>?
    var settings: Results<Settings>?
    var stat: Results<Stat>?
    
    var numberOfHabits = 0
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
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        loadData()
        scheduleLocal(settings:settings!)
        setUpView()
        dayChanged()
        loadHabits()
        
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(self.calendarDayDidChange),
                                                   name:.NSCalendarDayChanged,
                                                   object:nil)}
        
    }
    
    
    
    
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
            if(self.settings!.first!.isBandage){
                
                UIApplication.shared.applicationIconBadgeNumber = self.numberOfHabits
            }
            
            
            
        }
    }
    
    
    func getHourAndMinuteValue(time:String) -> Int{
        let tmp = time.components(separatedBy: ":")
        return Int(tmp[0])!*60+Int(tmp[1])! 
    }
    
    
    func getCurrentTimeOfDay() -> Int{
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        let x = (hour * 60)+minute
        settings  = self.realm.objects(Settings.self)
        if (x >= getHourAndMinuteValue(time: settings![0].morningStartsAt) && x < getHourAndMinuteValue(time: settings![0].afternoonStartsAt)){
            return 0
        }else if (x >= getHourAndMinuteValue(time: settings![0].afternoonStartsAt) && x < getHourAndMinuteValue(time: settings![0].eveningStartsAt)){
            return 1
        }else{
            return 2
        }
    }
    
    
    
    
    //MARK:- VIEW
    func setUpView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        segmentedC.selectedSegmentIndex = getCurrentTimeOfDay()
        segmentedC.frame = CGRect(x: segmentedC.frame.origin.x, y: segmentedC.frame.origin.y, width: segmentedC.frame.size.width, height: 50);
    }
    
    
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "trumpet", withExtension: "aiff") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    //MARK:- SEGMENTED
    
    
    //MARK:- NEW HABIT
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
    private let animationDuration: CFTimeInterval = 0.2
    private let animateFromValue: CGFloat = 1.00
    private let animateToValue: CGFloat = 1.08
    
    
    //MARK:- NOTIFICATION
    func scheduleLocal(settings:Results<Settings>) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        
        //ALL DAY
        if(settings[0].isAllDayNotificationTurnedOn){
            let allDayNotificationContent = UNMutableNotificationContent()
            allDayNotificationContent.title = "Plans for today"
            allDayNotificationContent.body = "ALLDAY"
            // allDayNotificationContent.sound = UNNotificationSound.default
            var allDayDateComponents = DateComponents()
            allDayDateComponents.hour = 6
            allDayDateComponents.minute = 10
            let alldayTrigger = UNCalendarNotificationTrigger(dateMatching: allDayDateComponents, repeats: true)
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: allDayNotificationContent, trigger: alldayTrigger))
        }
        
        
        if(settings[0].isAMorningNotificationTurnedOn){
            let morningNotificationContent = UNMutableNotificationContent()
            morningNotificationContent.title = "Morning notification"
            morningNotificationContent.body = "MORNIG!"
            //    morningNotificationContent.sound = UNNotificationSound.default
            var morningDateComponents = DateComponents()
            morningDateComponents.hour = 8
            morningDateComponents.minute = 10
            let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningDateComponents, repeats: true)
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: morningNotificationContent, trigger: morningTrigger))
        }
        if(settings[0].isAfternoonNotificationTurnedOn){
            let afternoonNotificationContent = UNMutableNotificationContent()
            afternoonNotificationContent.title = "Afternoon notification"
            afternoonNotificationContent.body = "AFTERNOON"
            //   afternoonNotificationContent.sound = UNNotificationSound.default
            var afternoonDateComponents = DateComponents()
            afternoonDateComponents.hour = 12
            afternoonDateComponents.minute = 10
            let afternoonTrigger = UNCalendarNotificationTrigger(dateMatching: afternoonDateComponents, repeats: true)
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: afternoonNotificationContent, trigger: afternoonTrigger))
            
        }
        if(settings[0].isEveningNotificationTurnedOn){
            
            let eveningNotificationContent = UNMutableNotificationContent()
            eveningNotificationContent.title = "Evening plan🌙"
            eveningNotificationContent.body = "You have 3 habits for this evening and 4 more you can do"
            //    eveningNotificationContent.sound = UNNotificationSound.default
            var eveningDateComponents = DateComponents()
            eveningDateComponents.hour = 18
            eveningDateComponents.minute = 10
            let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningDateComponents, repeats: true)
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: eveningNotificationContent, trigger: eveningTrigger))
        }
        if(settings[0].isResultNotificationTurnedOn){
            
            let resultNotificationContent = UNMutableNotificationContent()
            resultNotificationContent.title = "Result notification"
            resultNotificationContent.body = "RESULT"
            //  resultNotificationContent.sound = UNNotificationSound.default
            var resultsDateComponents = DateComponents()
            resultsDateComponents.hour = 22
            resultsDateComponents.minute = 10
            let resultsTrigger = UNCalendarNotificationTrigger(dateMatching: resultsDateComponents, repeats: true)
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: resultNotificationContent, trigger: resultsTrigger))
        }
    }
    
    
    //MARK:- DATA
    
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
    
    
    func createNewSettingsOnFirstLogin() {
        
        let settings = Settings()
        
        do {
            try realm.write {
                realm.add(settings)
            }
        } catch {
            print("Error saving habit \(error)")
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
    
    
    func loadData(){
        stat = self.realm.objects(Stat.self)
        settings  = self.realm.objects(Settings.self)
        
        if stat?.count == 0{
            createNewStatOnFirstLogin()
        }
        if settings?.count == 0{
            createNewSettingsOnFirstLogin()
        }
        
        stat  = self.realm.objects(Stat.self)
        settings  = self.realm.objects(Settings.self)
        loadHabits()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func dayChanged(){
        if(isDayChanged == true){
            isDayChanged = false
            var isEverythingDone = true
            var isSomethingDone = false
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy MM dd"
            let today = formatter.date(from: formatter.string(from: date))!
            
            for habit in self.habits!{
                if habit.isDoneToday == false{
                    isEverythingDone = false
                }
                if habit.isDoneToday == true{
                    isSomethingDone = true
                    try! realm.write {
                        habit.isDoneToday=false
                    }
                }
            }
            try! realm.write {
                if isSomethingDone == true{
                    if(stat?.first?.almostEverythingWasDoneOnDates.count == 0){
                        stat?.first?.almostEverythingWasDoneOnDates.append(today)
                    }
                    if let i = stat?.first?.almostEverythingWasDoneOnDates.last{
                        if i != today{
                            stat?.first?.almostEverythingWasDoneOnDates.append(today)
                        }
                    }
                    
                    
                    if isEverythingDone == true {
                        if(stat?.first?.everythingWasDoneOnDates.count == 0){
                            stat?.first?.everythingWasDoneOnDates.append(today)
                        }
                        
                        if let i = stat?.first?.everythingWasDoneOnDates.last{
                            if i != today{
                                stat?.first?.everythingWasDoneOnDates.append(today)
                            }
                        }
                        
                        stat?.first?.currentStreak+=1
                        if stat!.first!.currentStreak > stat!.first!.greatestStreak  {
                            stat!.first!.greatestStreak = stat!.first!.currentStreak
                        }
                        stat?.first!.totalPerfectDay+=1
                    }else{
                        stat?.first!.currentStreak = 0
                    }
                }
                stat?.first!.numberOfDoneHabits = doneHabits!.count
                stat?.first!.numberOfActiveHabits = habits!.count - doneHabits!.count
                
                
                
            }
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addNewHabit" {
            
            let destinationVC = segue.destination as! NewHabitViewController
            
            
            destinationVC.delegate = self
            
        }
        
        if segue.identifier == "showHabitDetails" {
            
            let destinationVC = segue.destination as! HabitDetailVC
            if let indexPath = sender {
                destinationVC.selectedHabit = resultsArray[segmentedC.selectedSegmentIndex][(indexPath as AnyObject).section][0]![(indexPath as AnyObject).row]
                
                return
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
        numberOfHabits = habits!.count
        morningHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "morning").sorted(byKeyPath: "dateCreated", ascending: true)
        
        afternoonHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "afternoon").sorted(byKeyPath: "dateCreated", ascending: true)
        
        
        eveningHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "evening").sorted(byKeyPath: "dateCreated", ascending: true)
        
        
        allDayHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "any time").sorted(byKeyPath: "dateCreated", ascending: true)
        
        
        doneHabits = habits?.filter("plannedTimeToDo CONTAINS[cd] %@", "done").sorted(byKeyPath: "dateCreated", ascending: true)
        
        resultsArray = [[[morningHabits],[allDayHabits]],[[afternoonHabits],[allDayHabits]],[[eveningHabits],[allDayHabits]],[[morningHabits],[afternoonHabits],[eveningHabits],[allDayHabits]],[[doneHabits]]]
        
        tableView.reloadData()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
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
extension HabitViewController: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{
    
    
    
    func tableView(_ tableView: UITableView,leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let detailsAction = UIContextualAction(style: .normal, title:  "Details", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.performSegue(withIdentifier: "showHabitDetails", sender: indexPath)
            tableView.reloadData()
            success(true)
        })
        detailsAction.image = UIImage(systemName: "pencil")
        detailsAction.backgroundColor = .gray
        
        return UISwipeActionsConfiguration(actions: [detailsAction])
        
    }
    
    func tableView(_ tableView: UITableView,trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.updateModel(at: indexPath)
            success(true)
        })
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //cell.delegate = self
        
        if let habit = resultsArray[segmentedC.selectedSegmentIndex][indexPath.section][0]?[indexPath.row] {
            
            let progressView = UIProgressView(progressViewStyle: .default)
            let progress = Float(habit.itWasDone) / Float(habit.difficulity)
            
            cell.detailTextLabel?.text = String(progress)
            cell.textLabel?.text = habit.name
            cell.accessoryType = habit.isDoneToday ? .checkmark : .none
            cell.backgroundColor = UIColor(hexString: habit.color).lighten(byPercentage: 0.005)
            
            if cell.contentView.subviews.count == 2 || cell.contentView.subviews.count == 3{
                
                for i in cell.contentView.subviews{
                    if let obj = i as? UIProgressView{
                        obj.progress = progress
                    }
                }
                
                
            }
            else{
                
                progressView.rightAnchor.accessibilityActivate()
                progressView.frame = CGRect(x: 15, y: 70, width: 348, height: 15)
                progressView.progressTintColor = UIColor.black
                progressView.transform = progressView.transform.scaledBy(x: 1, y: 3)
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
    
    func cheers(doneHabit:Habit){
        
        if(settings![0].isSoung){
            playSound()
        }
        
        
        let cheerView = CheerView()
        view.addSubview(cheerView)
        cheerView.config.particle = .confetti(allowedShapes: Particle.ConfettiShape.all)
        if(settings![0].isCheers){
            cheerView.start()
        }
        
        // Stop
        
        let alert = UIAlertController(title: "Congratulations!", message: "You have just finished this habit", preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { (action) in
            
            
            do {
                try self.realm.write {
                    doneHabit.itWasDone = 0
                    doneHabit.isDoneFinally = false
                    doneHabit.itWasDoneInStreak = 0
                    
                    
                    
                    
                }
            } catch {
                print("Error saving new items, \(error)")
            }
            
            if(self.settings![0].isCheers){
                cheerView.stop()
            }
            self.tableView.reloadData()
            
        }
        
        let doneAction = UIAlertAction(title: "Done!", style: .default) { (action) in
            
            do {
                try self.realm.write {
                    doneHabit.isDoneFinally = true
                    doneHabit.plannedTimeToDo = "done"
                    self.stat![0].numberOfDoneHabits = self.stat![0].numberOfDoneHabits + 1
                    
                }
            } catch {
                print("Error saving new items, \(error)")
            }
            
            if(self.settings![0].isCheers){
                cheerView.stop()
            }
            self.tableView.reloadData()
            
        }
        
        
        alert.addAction(resetAction)
        alert.addAction(doneAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = self.resultsArray[self.segmentedC.selectedSegmentIndex][indexPath.section][0]?[indexPath.row] {
            do {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy MM dd"
                let startDate = formatter.date(from: formatter.string(from: date))!
                
                try self.realm.write {
                    if item.isDoneToday == false {
                        
                        item.isDoneToday = !item.isDoneToday
                        item.itWasDoneInStreak+=1
                        item.itWasDone+=1
                        if(item.itWasDone >= item.difficulity){
                            self.cheers(doneHabit: item)
                        }
                        if(self.settings!.first!.isBandage){
                            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
                        }
                        item.itWasDoneOnDates.append(startDate)
                        
                    }else{
                        
                        item.isDoneToday = !item.isDoneToday
                        item.itWasDone-=1
                        if(self.settings!.first!.isBandage){
                            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
                        }
                        item.itWasDoneOnDates.removeLast()
                        
                    }
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resultsArray[segmentedC.selectedSegmentIndex][section][0]!.count
        
    }
    
    
    
    
    
    
}


