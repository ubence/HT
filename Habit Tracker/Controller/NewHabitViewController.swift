//
//  NewHabitViewController.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 21..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import UIKit
import RealmSwift

protocol NewHabitDelegate {
    func userPressedSaveButton()
}

class NewHabitViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate : NewHabitDelegate?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    let whens = ["Any time","Morning","Afternoon","Evening"]
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextfield.becomeFirstResponder()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(0, inComponent:0, animated:true)
    }
    
    //MARK: saveButton
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        //collecting needed datas
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        //let result = formatter.string(from: date)
       

        
        
        
        //constructing the habit object
        let newHabit = Habit()
        
        newHabit.name = nameTextfield.text!
        newHabit.color = nameTextfield.tintColor.hexValue()
        newHabit.plannedTimeToDo = whens[pickerView.selectedRow(inComponent: 0)].lowercased()
        newHabit.isDoneToday = false
        newHabit.dateCreated = date
        //newHabit.itWasDoneOnDates.append(<#T##object: Date##Date#>)
        
        self.save(habit: newHabit)
        delegate?.userPressedSaveButton()
        self.dismiss(animated: true, completion: nil)
        
  
        
    }
  
    
    
    func save(habit: Habit) {

        do {
            try realm.write {
                realm.add(habit)
            }
        } catch {
            print("Error saving habit \(error)")
        }
        
    }
    
    
    
    //MARK: whenPicker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return whens.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return whens[row]
    }
    
    
    //MARK: Color
    @IBAction func colorChanged(_ sender: UIButton) {
        //saveButton.tintColor = sender.backgroundColor
        //nameTextfield.textColor = sender.backgroundColor
        nameTextfield.tintColor = sender.backgroundColor
    }
    
    
}




public extension UIColor {
    var hexValue: String {
        var color = self
        
        if color.cgColor.numberOfComponents < 4 {
            let c = color.cgColor.components!
            color = UIColor(red: c[0], green: c[0], blue: c[0], alpha: c[1])
        }
        if color.cgColor.colorSpace!.model != .rgb {
            return "#FFFFFF"
        }
        let c = color.cgColor.components!
        return String(format: "#%02X%02X%02X", Int(c[0]*255.0), Int(c[1]*255.0), Int(c[2]*255.0))
    }
}



