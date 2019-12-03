//
//  Habit.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 20..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import Foundation
import RealmSwift

class Stat: Object {
    
    @objc dynamic var totalPerfectDay: Int = 0
    @objc dynamic var numberOfDoneHabits: Int = 0
    @objc dynamic var numberOfActiveHabits: Int = 0
    @objc dynamic var currentStreak: Int = 0
    @objc dynamic var greatestStreak: Int = 0
    dynamic var everythingWasDoneOnDates = List<Date>()
    dynamic var almostEverythingWasDoneOnDates = List<Date>()

}


