//
//  ViewController.swift
//  Pill-Tracker
//
//  Created by Léa on 04/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class ViewController: UIViewController {
    
    var dailyCaps = [Capsule]()
    var todayDate = [TodayDate]()
    var nameTextField = UITextField()
    var nbTextField = UITextField()
    let alertError = UIAlertController(title: "Incomplet", message: "Merci de remplir tous les champs pour ajouter une capsule", preferredStyle: UIAlertController.Style.alert)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
//        Capsule(name: "Multivitamine", quantity: 1, color: "Multi-Color"),
//        Capsule(name: "Fat burner", quantity: 4, color: "fatB-Color"),
//        Capsule(name: "L-Carnitine", quantity: 2, color: "L-C-Color"),
//        Capsule(name: "Vitamine C", quantity: 1, color: "VitC-Color"),
//        Capsule(name: "Omega 3", quantity: 4, color: "Omega3-Color"),
//        Capsule(name: "Vitamine D", quantity: 1, color: "VitD-Color"),
//        Capsule(name: "Creatine", quantity: 1, color: "Creatine-Color"),
//        Capsule(name: "Magnesium", quantity: 2, color: "Mg-Color"),
//        Capsule(name: "Glycine", quantity: 1, color: "Glycine-Color"),

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        updateDate()

        tableView.register(UINib(nibName: "CapsuleCell", bundle: nil), forCellReuseIdentifier: "reusableCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        nameTextField.delegate = self
        nbTextField.delegate = self
        
    }
    
    
    // MARK: - Date Manipulation
    
    func compareDate(date1:Date, date2:Date) -> Bool {
        let order = NSCalendar.current.compare(date1, to: date2, toGranularity: .day)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    
    func updateDate() {
        
        let openDate = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"

//        let tomorrow = openDate.tomorrow
//        let tomorrowString = formatter.string(from: tomorrow!)
//        print("\(tomorrowString)")
//        openDate = tomorrow!
//        print(openDate)

//
        let request: NSFetchRequest<TodayDate> = TodayDate.fetchRequest()
    
        do {
            todayDate = try context.fetch(request) // the output for this method is an array of Items that is stored in our persistant container
            
            if todayDate.count == 0 {
                let date = TodayDate(context: self.context)
                date.today = openDate
                todayDate.append(date)
                saveData()
            }
            else {
                if !compareDate(date1: todayDate[0].today!, date2: openDate) {
                    todayDate[0].today = openDate
                    
                    let requestCaps: NSFetchRequest<Capsule> = Capsule.fetchRequest()
                    do {
                        dailyCaps = try context.fetch(requestCaps) // the output for this method is an array of Items that is stored in our persistant container
                        for caps in dailyCaps {
                            caps.counterTap = 0
                            caps.leftToTake = caps.quantity
                            caps.colorShown = caps.color
                        }
                    } catch {
                        print("Error fetching data from context: \(error)")
                    }
                    saveData()
                }
            }
          } catch {
              print("Error fetching data from context: \(error)")
          }
        
        DispatchQueue.main.async {
            self.dateLabel.text = formatter.string(from: self.todayDate[0].today!)
            self.loadCapsules()
        }
    }

    
    // MARK: - Add Pill
    
    @IBAction func addPill(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add a new pill", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default, handler: { action in
            
            let textFieldArray = [self.nameTextField, self.nbTextField]
            let allHaveText = textFieldArray.allSatisfy { $0.text?.isEmpty == false }

            if allHaveText{
                let newPill = Capsule(context: self.context)
                newPill.name = self.nameTextField.text!
                newPill.quantity = Double(self.nbTextField.text!)!
                newPill.leftToTake = newPill.quantity
                
                if self.dailyCaps.count <= K.colors.count {
                    newPill.color = K.colors[self.dailyCaps.count]
                } else {
                    newPill.color = "Color1"
                }

                newPill.colorShown = newPill.color
                self.dailyCaps.append(newPill)
                
                self.saveData()
                
            } else {
                self.showAlert()
            }

        })
        
        alert.addTextField { textField in
            textField.delegate = self
            let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)
            textField.addConstraint(heightConstraint)
            textField.placeholder = "Name"
            self.nameTextField = textField
        }
        
        alert.addTextField { textField in
            textField.delegate = self
            let heightConstraint = NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)
            textField.addConstraint(heightConstraint)
            textField.placeholder = "Quantity"
            self.nbTextField = textField
        }
        
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Error alert when Add Pill TextField are incomplete
    func showAlert() {
        self.present(alertError, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
            self.alertError.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Model Manipulation Methods
    
    func updatePillTaken(for caps: Capsule) {
        if caps.leftToTake == 0 {
            caps.counterTap = 0
            caps.leftToTake = caps.quantity
            caps.colorShown = caps.color
        } else if caps.leftToTake == 1 {
            caps.leftToTake = 0
            caps.colorShown = "Nul-Color"
        } else {
            if caps.leftToTake == 4 {
                caps.leftToTake = 2
                caps.counterTap += 1
            } else if caps.leftToTake == 2 && caps.counterTap == 1 {
                caps.leftToTake = 0
                caps.colorShown = "Nul-Color"
            } else {
                caps.leftToTake = caps.leftToTake/2
            }
        }
        saveData()
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("error saving data : \(error)")
        }
        loadCapsules()
    }
    
    
    func loadCapsules() {
        let request: NSFetchRequest<Capsule> = Capsule.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Capsule.leftToTake), ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            dailyCaps = try context.fetch(request) // the output for this method is an array of Items that is stored in our persistant container
        } catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    func deleteCapsule(capsName: String) {
        let request: NSFetchRequest<Capsule> = Capsule.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", capsName)
        request.predicate = predicate

        do {
            let objects = try context.fetch(request)
            for object in objects {
                context.delete(object)
            }
            try context.save()
        } catch {
            print("Error deleting capsule from context: \(error)")
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyCaps.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCell(withIdentifier: "reusableCell") as! CapsuleCell
        
        cell.capsuleLabel.text = dailyCaps[indexPath.row].name
        cell.nbLabel.text = String(format: "%.0f", dailyCaps[indexPath.row].leftToTake)
        cell.cellBGColor.backgroundColor = UIColor(named: dailyCaps[indexPath.row].colorShown!)
        
        cell.delegate = self
        
       return cell
    }

}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let caps = dailyCaps[indexPath.row]
        updatePillTaken(for: caps)
    }

    
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == nbTextField {
            //Limit the character count to 1.
            if ((textField.text!) + string).count > 1 {
                return false
            }
            //Only allow numbers. No Copy-Paste text values.
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
            if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
                return false
            }
        }
        
        if textField == nameTextField {
            //Limit the character count to 20.
            if ((textField.text!) + string).count > 20 {
                return false
            }
        }
        
        return true
    }
}


// MARK: - SwipeTableViewCellDelegate

extension ViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteCapsule(capsName: self.dailyCaps[indexPath.row].name!)
            self.dailyCaps.remove(at: indexPath.row)
            self.tableView.reloadData()
        }

        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    
}

extension Date {

    var tomorrow: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
}

