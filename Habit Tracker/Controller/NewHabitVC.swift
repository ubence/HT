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

class NewHabitViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate : NewHabitDelegate?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var customCell: UITableViewCell!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBAction func sliderChanged(sender: AnyObject) {
        color = uiColorFromHex(rgbValue: colorArray[Int(slider.value)])
        nameTextfield.tintColor = color
        saveButton.isEnabled = true
        //saveButton.tintColor = color
    }
    
    // RRGGBB hex colors in the same order as the image
    let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
    var color = UIColor()
    
    
    
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    let whens = ["Any time","Morning","Afternoon","Evening"]
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextfield.becomeFirstResponder()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(0, inComponent:0, animated:true)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let newHabit = Habit()
        
        
        newHabit.name = (tableView.cellForRow(at: indexPath)?.textLabel!.text)!
        
        newHabit.color = (tableView.cellForRow(at: indexPath)?.backgroundColor?.hexValue()!)!
        
        
        
        newHabit.plannedTimeToDo = (tableView.cellForRow(at: indexPath)?.detailTextLabel!.text!)!
        newHabit.isDoneToday = false
        newHabit.dateCreated = date
        //newHabit.itWasDoneOnDates.append(<#T##object: Date##Date#>)
        
        self.save(habit: newHabit)
        delegate?.userPressedSaveButton()
        navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: saveButton
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let newHabit = Habit()
        
        newHabit.name = nameTextfield.text!
        newHabit.color = nameTextfield.tintColor.hexValue()
        newHabit.plannedTimeToDo = whens[pickerView.selectedRow(inComponent: 0)].lowercased()
        newHabit.isDoneToday = false
        newHabit.dateCreated = date
        //newHabit.itWasDoneOnDates.append(<#T##object: Date##Date#>)
        
        self.save(habit: newHabit)
        delegate?.userPressedSaveButton()
        navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        
        
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



