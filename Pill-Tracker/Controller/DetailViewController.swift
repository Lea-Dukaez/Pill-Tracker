//
//  DetailViewController.swift
//  Pill-Tracker
//
//  Created by Léa on 17/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var selection = ""

    var recurrence: [Detail] = [
        Detail(name: "Everyday", checked: false),
        Detail(name: "Monday", checked: false),
        Detail(name: "Tuesday", checked: false),
        Detail(name: "Wenesday", checked: false),
        Detail(name: "Thursday", checked: false),
        Detail(name: "Friday", checked: false),
        Detail(name: "Saturday", checked: false),
        Detail(name: "Sunday", checked: false)
    ]

    var time: [Detail] = [
        Detail(name: "Breakfast", checked: false),
        Detail(name: "Lunch", checked: false),
        Detail(name: "Diner", checked: false)
    ]
    
    var type: [Detail]  = [
        Detail(name: "Pill", checked: false),
        Detail(name: "Powder", checked: false)
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "detailCell")

        tableView.dataSource = self
        tableView.delegate = self

    }
    
    
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selection {
        case K.categoryTime:
            return time.count
        case K.categoryRecurrence:
            return recurrence.count
        default:
            return type.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell")! as UITableViewCell
        
        switch selection {
        case K.categoryTime:
            cell.textLabel?.text = time[indexPath.row].name
        case K.categoryRecurrence:
            cell.textLabel?.text = recurrence[indexPath.row].name
        default:
            cell.textLabel?.text = type[indexPath.row].name
        }
        
        return cell
    }
    
    
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType == .checkmark ? .none : .checkmark
        
        switch selection {
        case K.categoryTime:
            time[indexPath.row].checked = time[indexPath.row].checked == false ? true : false
            print(time[indexPath.row])
        case K.categoryRecurrence:
            recurrence[indexPath.row].checked = recurrence[indexPath.row].checked == false ? true : false
            print(recurrence[indexPath.row])
        default:
            type[indexPath.row].checked = type[indexPath.row].checked == false ? true : false
            print(type[indexPath.row])
        }
        
    }
}

