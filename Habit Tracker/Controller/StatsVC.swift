//
//  StatsVC.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 12. 22..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//
//if #available(iOS 13.0, *) {
//    let app = UINavigationBarAppearance()
//    self.navigationController?.navigationBar.scrollEdgeAppearance = app
//}

import UIKit
import RealmSwift
import JTAppleCalendar


class StatsVC: UIViewController {
    @IBOutlet weak var donneLbl: UILabel!
    @IBOutlet weak var activeLbl: UILabel!
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var greatestLbl: UILabel!
    @IBOutlet weak var perfectLbl: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    var stat: Results<Stat>?
    let realm = try! Realm()
    
    @IBAction func deleteStat(_ sender: UIButton) {
        do {
            try realm.write {
                realm.delete(stat![0])
                let stat = Stat()
                realm.add(stat)
            }
        } catch {
            print("Error saving habit \(error)")
        }
        stat  = self.realm.objects(Stat.self)
        refreshView()
    }
    
    
    
    func refreshView(){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        monthLbl.text = formatter.string(from: date)
        donneLbl.text = "\(stat![0].numberOfDoneHabits)"
        activeLbl.text = "\(stat![0].numberOfActiveHabits)"
        current.text = "\(stat![0].currentStreak)"
        greatestLbl.text = "\(stat![0].greatestStreak)"
        perfectLbl.text = "\(stat![0].totalPerfectDay)"
        var selectDays:[Date] = []
        if stat![0].everythingWasDoneOnDates.count != 0{
            for i in stat![0].everythingWasDoneOnDates{
                selectDays.append(i)
            }
            if selectDays.count>0{
                self.calendarView.selectDates(selectDays)
            }
            
            
            
        }else{
            print("nincs meg datum benne")
        }
        calendarView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //calendarView.allowsMultipleSelection = true
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        stat  = self.realm.objects(Stat.self)
        refreshView()
    }
    
    
    
    
    
    
    
    
    
    
}

extension StatsVC: JTAppleCalendarViewDataSource {
    
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
    
    func deleteStatistic() {
        do {
            try realm.write {
                realm.delete(stat![0])
                let stat = Stat()
                realm.add(stat)
            }
        } catch {
            print("Error saving habit \(error)")
        }
    }
    
    
    
    
}

extension StatsVC: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        for i in stat![0].everythingWasDoneOnDates{
            if i == date{
                return true
            }
        }
        return false
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
}

