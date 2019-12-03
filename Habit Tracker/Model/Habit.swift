//
//  Habit.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 20..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import Foundation
import RealmSwift

class Habit: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = "A9A9A9"
    @objc dynamic var plannedTimeToDo: String = "" //morning,evening, ect
    @objc dynamic var difficulity: Int = 21
    @objc dynamic var itWasDone: Int = 0
    @objc dynamic var isDoneToday: Bool = false
    @objc dynamic var isDoneFinally: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    dynamic var itWasDoneOnDates = List<Date>()
    @objc dynamic var itWasDoneInStreak: Int = 0

}


