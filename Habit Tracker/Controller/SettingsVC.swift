//
//  SettingsVC.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 12. 22..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//


import UIKit
import RealmSwift

class SettingsVC: UITableViewController {
    
    @IBOutlet weak var iconSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var cheersSwitch: UISwitch!
    @IBOutlet weak var isDark: UISwitch!
    
    
    @IBAction func oneOfTheSwitchesChanged(_ sender: UISwitch) {
        try! realm.write {
            switch sender.tag {
            case 0:
                settings![0].isBandage = !settings![0].isBandage
                break
            case 1:
                settings![0].isSoung = !settings![0].isSoung
                break
            case 2:
                settings![0].isCheers = !settings![0].isCheers
                break
            case 3:
                settings![0].isDark = !settings![0].isDark
                
                if(settings![0].isDark){
                    UIApplication.shared.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .dark
                    }}
                else{
                    UIApplication.shared.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .light
                    }}
                break
            default:
                break
            }
        }
    }
    
    
    
    let realm = try! Realm()
    var settings: Results<Settings>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        settings  = self.realm.objects(Settings.self)
        
        
        
        refreshView()
    }
    
    func refreshView(){
        
        
        iconSwitch.setOn(settings![0].isBandage, animated: true)
        soundSwitch.setOn(settings![0].isSoung, animated: true)
        cheersSwitch.setOn(settings![0].isCheers, animated: true)
        
        try! realm.write {
            if traitCollection.userInterfaceStyle == .dark {
                settings![0].isDark = true
            }else{
                settings![0].isDark = false
            }
        }
        
        
        
        isDark.setOn(settings![0].isDark, animated: true)
        
        
    }
    
    
}
