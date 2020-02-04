//
//  HabitDetailVC.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 22..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import UIKit
import JTAppleCalendar
import RealmSwift


class HabitDetailVC: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var habitNameLbl: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var bottomLeftLabel: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    
    @IBOutlet weak var bottomCenterLabel: UILabel!
    
    @IBOutlet weak var bottomRigthLabel: UILabel!
    let realm = try! Realm()
    
    
    var selectedHabit: Habit = Habit()
    override func viewDidLoad(){
        
        
        
        
        super.viewDidLoad()
        calendarView.allowsMultipleSelection = true
        updateBottomPartOfView()
        
        //let date = Date()
        var selectDays:[Date] = []
        if selectedHabit.itWasDoneOnDates.count != 0{
            for i in selectedHabit.itWasDoneOnDates{
                selectDays.append(i)
                
            }
            self.calendarView.scrollToDate(selectDays[0]) {
                self.calendarView.selectDates(selectDays)
                
            }
        }else{
            print("nincs meg datum benne")
        }
        
    }
    
    func updateBottomPartOfView(){
        let date = Date()
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        monthLbl.text = formatter.string(from: date)
        habitNameLbl.text = selectedHabit.name
        bottomLeftLabel.text = "\(selectedHabit.itWasDone)/\(selectedHabit.difficulity)"
        let percent = Float(selectedHabit.itWasDone) / Float(selectedHabit.difficulity)
        bottomRigthLabel.text = "\(Int(ceil(percent*100)))%"
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd."
        let formattedDate = formatter.string(from:  selectedHabit.dateCreated)
        bottomCenterLabel.text = "Started on \(formattedDate)"
        progressView.progress = percent
    }
    
    
    func updateHabit(type:String,date:Date){
        let date3 = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let today = formatter.date(from: formatter.string(from: date3))!
        let date2 = formatter.date(from: formatter.string(from: date))!
        
        do {
            
            try realm.write {
                if type == "add"{
                    if(today == date2){
                        selectedHabit.isDoneToday = true
                    }
                    selectedHabit.itWasDone+=1
                    selectedHabit.itWasDoneOnDates.append(date2)
                }else if type == "remove"{
                    if(today == date2){
                        selectedHabit.isDoneToday = false
                    }
                    selectedHabit.itWasDone-=1
                    selectedHabit.itWasDoneOnDates.remove(at: selectedHabit.itWasDoneOnDates.index(of: date2)!)
                }
            }
        } catch {
            print("Error saving done status, \(error)")
        }
        updateBottomPartOfView()
    }
    
    
}




extension HabitDetailVC: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: formatter.string(from: date))!
        let endDate = Date()
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek:DaysOfWeek.monday, hasStrictBoundaries: false)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
    }
    
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.layer.cornerRadius =  13
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.clear
        }
    }
    
    
    
    
}

extension HabitDetailVC: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        updateHabit(type: "add",date: date)
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        updateHabit(type: "remove",date: date)
        configureCell(view: cell, cellState: cellState)
    }
    
}
