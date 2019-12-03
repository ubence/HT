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


class StatsVC: UIViewController {
    
    
    var stat: Results<Stat>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        super.viewDidLoad()
        loadStat()
        print(stat)
        // Do any additional setup after loading the view.
    }
    
    
    func loadStat() {
        stat  = self.realm.objects(Stat.self)
        //refresh()
    }
    
    
    
    
    
    
    
}
