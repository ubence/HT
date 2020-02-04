//
//  Settings.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 29..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//
import Foundation
import RealmSwift

class Settings: Object {
    @objc dynamic var morningStartsAt: String = "00:00"
    @objc dynamic var afternoonStartsAt: String = "12:00"
    @objc dynamic var eveningStartsAt: String = "18:00"
    @objc dynamic var isSoung: Bool = false
    @objc dynamic var isBandage: Bool = false
    @objc dynamic var isCheers: Bool = false
    @objc dynamic var isDark: Bool = false
    @objc dynamic var isAllDayNotificationTurnedOn: Bool = false
    @objc dynamic var isAMorningNotificationTurnedOn: Bool = false
    @objc dynamic var isAfternoonNotificationTurnedOn: Bool = false
    @objc dynamic var isEveningNotificationTurnedOn: Bool = false
    @objc dynamic var isResultNotificationTurnedOn: Bool = false
    
    
    
}


