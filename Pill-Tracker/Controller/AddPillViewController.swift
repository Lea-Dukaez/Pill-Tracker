//
//  AddPillViewController.swift
//  Pill-Tracker
//
//  Created by Léa on 17/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class AddPillViewController: UIViewController {
    
    var categorySelected = ""
    let categories = [
        Category(name: K.categoryType, option: "Pill"),
        Category(name: K.categoryRecurrence, option: "Every Day"),
        Category(name: K.categoryTime, option: "Morning")
    ]
    let alertError = UIAlertController(title: "Incomplete", message: "PLease fill all the fields to add new pill", preferredStyle: UIAlertController.Style.alert)
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")

        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        if nameTextField.text?.isEmpty == false {
            if let pillName = nameTextField.text {
                print("new pill name : \(pillName)")
                print("new pill quantity : \(quantityLabel.text!)")
                print("new pill type : \(categories[0].option)")
                print("new pill recurrence : \(categories[1].option)")
                print("new pill time : \(categories[2].option)")
            }
        } else {
            showAlert()
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


}

// MARK: - UITableViewDataSource

extension AddPillViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "categoryCell")
                
        cell.textLabel!.text = categories[indexPath.row].name
        cell.detailTextLabel!.text = categories[indexPath.row].option
        
        return cell
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
        }
    }
}
