//
//  AddNewHabitTableVC.swift
//  Habit Tracker
//
//  Created by Utasi Bence on 2019. 11. 29..
//  Copyright © 2019. Utasi Bence. All rights reserved.
//

import UIKit

class AddNewHabitTableVC: UITableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "custumizeHabit" {
                
                
                let destinationVC = segue.destination as! NewHabitViewController
//                           
//                           if let indexPath = tableView.indexPathForSelectedRow {
//                               //destinationVC.selectedCategory = categories?[indexPath.row]
//                            destinationVC.modalPresentationStyle = .popover
//                            destinationVC.presentationController?.delegate = self as! UIAdaptivePresentationControllerDelegate
//                           }
                
               
         }
        
        
      
    }
    

 

}
