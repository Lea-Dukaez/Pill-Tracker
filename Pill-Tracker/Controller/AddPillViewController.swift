//
//  AddPillViewController.swift
//  Pill-Tracker
//
//  Created by Léa on 17/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import CoreData

class AddPillViewController: UIViewController, detailViewDelegate {


    var categorySelected = ""
    var pillName = ""
    
    var categories = [
        Category(name: K.categoryType, option: "Powder"),
        Category(name: K.categoryRecurrence, option: "Mon"),
        Category(name: K.categoryTime, option: "Morning")
    ]
//    var categoryDetail: [[Detail]] = [recurrence, time, type]
    
    var recurrence: [Detail] = [
        Detail(name: "Everyday", checked: false),
        Detail(name: "Monday", checked: true),
        Detail(name: "Tuesday", checked: false),
        Detail(name: "Wenesday", checked: false),
        Detail(name: "Thursday", checked: false),
        Detail(name: "Friday", checked: false),
        Detail(name: "Saturday", checked: false),
        Detail(name: "Sunday", checked: false)
    ]

    var time: [Detail] = [
        Detail(name: "Morning", checked: true),
        Detail(name: "Noon", checked: false),
        Detail(name: "Evening", checked: false)
    ]
    
    var type: [Detail]  = [
        Detail(name: "Pill", checked: false),
        Detail(name: "Powder", checked: true)
    ]
    

    let alertError = UIAlertController(title: "Incomplete", message: "PLease fill all the fields to add new pill", preferredStyle: UIAlertController.Style.alert)
    

    

    @IBOutlet weak var namePicker: UIPickerView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AddPillView : ViewDid Load")
        
        namePicker.dataSource = self
        namePicker.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor(named: "backGroundColor")?.cgColor
        tableView.separatorColor = UIColor(named: "Color2")

        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
    }
    
    func saveCategoryChanges(valueChanged: [Detail]) {
        print("AddPillViewC saveCategoryChanges called, and categorie Option changed")
        switch categorySelected {
        case K.categoryTime:
            let noneSelected = valueChanged.allSatisfy { $0.checked == false }
            if noneSelected {
                time = valueChanged
                time[0].checked = true
            } else {
                time = valueChanged
            }
            categories[2].option = updatecategorieOption(category: time)
        case K.categoryRecurrence:
            let noneSelected = valueChanged.allSatisfy { $0.checked == false }
            if noneSelected {
                recurrence = valueChanged
                recurrence[1].checked = true
            } else {
                recurrence = valueChanged
            }
            categories[1].option = updatecategorieOption(category: recurrence)
        default:
            type = valueChanged
            categories[0].option = updatecategorieOption(category: type)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         print("AddPillView :  ViewWill Appear")
        
        tableView.reloadData()
    }
    
    func updatecategorieOption(category: [Detail]) -> String {
        var optionString = ""
        
        if categorySelected == K.categoryRecurrence {
            for (index, element) in category.enumerated() {
                if index == 0 && element.checked == true {
                    optionString += element.name
                } else {
                    if element.checked == true {
                        optionString += "\(element.name.prefix(3)) "
                    }
                }
            }
            return optionString
        }
        
        for element in category {
            if element.checked == true {
                optionString += "\(element.name) "
            }
        }
        return optionString
    }
    
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        if quantityLabel.text == "0" {
            showAlert()
        } else {
            print("new pill name : \(pillName)")
            print("new pill quantity : \(quantityLabel.text!)")
            print("new pill type : \(categories[0].option)")
            print("new pill recurrence : \(categories[1].option)")
            print("new pill time : \(categories[2].option)")
    
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        quantityLabel.text = String(format: "%.0f", sender.value)
    }
    
//         Error alert when Add Pill TextField are incomplete
    func showAlert() {
        self.present(alertError, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
            self.alertError.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }

    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }
    
     override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        var frame = self.tableView.frame
        frame.size = self.tableView.contentSize
        self.tableView.frame = frame
    }

}

// MARK: - UIPickerViewDataSource

extension AddPillViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return K.names.count
    }
    
}

// MARK: - UIPickerViewDelegate
extension AddPillViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return K.names[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pillName = K.names[row]
    } 
}

// MARK: - UITableViewDataSource

extension AddPillViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "categoryCell")
        cell.selectionStyle = .none
        cell.textLabel!.text = categories[indexPath.row].name
        cell.detailTextLabel!.text = categories[indexPath.row].option
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}

// MARK: - UITableViewDelegate

extension AddPillViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categorySelected = categories[indexPath.row].name
        performSegue(withIdentifier: K.segueToDetails, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueToDetails {
            let detailView = segue.destination as! DetailViewController
            detailView.selection = categorySelected
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            switch categorySelected {
            case K.categoryTime:
                detailView.time = time
            case K.categoryRecurrence:
                detailView.recurrence = recurrence
            default:
                detailView.type = type
            }
            detailView.myDetailDelegate = self
            print("AddPillView :  prepare for segue")
        }
    }
}
