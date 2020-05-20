//
//  DetailViewController.swift
//  Pill-Tracker
//
//  Created by Léa on 17/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import CoreData

protocol detailViewDelegate {
    func saveCategoryChanges(valueChanged: [Detail])
}

class DetailViewController: UIViewController, UINavigationControllerDelegate {
        
    var myDetailDelegate: detailViewDelegate?
    var selection = ""

    // init before segue
    var recurrence: [Detail] = []
    var time: [Detail] = []
    var type: [Detail]  = []
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailView : viewDid Load")
        navigationItem.title = selection
                
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "detailCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor(named: "backGroundColor")?.cgColor
        tableView.separatorColor = UIColor(named: "Color2")
        
        switch selection {
        case K.categoryTime:
            tableView.allowsMultipleSelection = true
        case K.categoryRecurrence:
            tableView.allowsMultipleSelection = true
        default:
            tableView.allowsMultipleSelection = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("DetailView : viewDid Appaer")
    
        switch selection {
        case K.categoryTime:
            updateTableFromSelection(category: time)
        case K.categoryRecurrence:
            updateTableFromSelection(category: recurrence)
        default:
            updateTableFromSelection(category: type)
        }
    }
    
    // update TableView from data of AddPillViewController
    func updateTableFromSelection(category: [Detail]){
        var indexPath = IndexPath(row: 0, section: 0)
        for (index, element) in category.enumerated() {
            if element.checked == true {
                indexPath.row = index
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
    }
    
    // adapt the size of table View from the content inside (number of row)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        var frame = self.tableView.frame
        frame.size = self.tableView.contentSize
        self.tableView.frame = frame
    }
    
}


// MARK: - UITableViewDataSource

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
        
        // customize the cell design
        cell.selectionStyle = .none
        cell.tintColor = UIColor(named: "Color2")

        // customize label
        switch selection {
        case K.categoryTime:
            cell.textLabel?.text = time[indexPath.row].name
        case K.categoryRecurrence:
            if recurrence[0].checked == true {
                if indexPath.row != 0 {
                    cell.accessoryType = .checkmark
                    cell.backgroundColor = UIColor(red: 1.00, green: 0.94, blue: 0.94, alpha: 1.00)
                    cell.textLabel?.textColor = .lightGray
                }
            }
            cell.textLabel?.text = recurrence[indexPath.row].name
        default:
            cell.textLabel?.text = type[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
}

// MARK: - UITableViewDelegate


extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

        switch selection {
        case K.categoryTime:
            time[indexPath.row].checked = true
            self.myDetailDelegate?.saveCategoryChanges(valueChanged: time)
        case K.categoryRecurrence:
            
            recurrence[indexPath.row].checked = recurrence[indexPath.row].checked == false ? true : false
    
            // get all week day for particularity if "all days" are selected
            var allWeekDay: [Detail] = []
              for index in 1..<recurrence.count {
                  allWeekDay.append(recurrence[index])
            }
            
            // particularity if "Everyday" is selected
            if indexPath.row == 0 {
                var indexPath = IndexPath(row: 0, section: 0)
                for index in 1..<recurrence.count{
                    indexPath.row = index
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor(red: 1.00, green: 0.94, blue: 0.94, alpha: 1.00)
                    tableView.cellForRow(at: indexPath)?.textLabel?.textColor = .lightGray
                    recurrence[index].checked = false
                }
            } else if allWeekDay.allSatisfy({ $0.checked == true}) { // particularity if "all days" are selected
                var indexPath = IndexPath(row: 0, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                recurrence[0].checked = true
                for index in 1..<recurrence.count{
                    indexPath.row = index
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor(red: 1.00, green: 0.94, blue: 0.94, alpha: 1.00)
                    tableView.cellForRow(at: indexPath)?.textLabel?.textColor = .lightGray
                    recurrence[index].checked = false
                }
            }
            
            self.myDetailDelegate?.saveCategoryChanges(valueChanged: recurrence)
        default:
            type[indexPath.row].checked = true
            self.myDetailDelegate?.saveCategoryChanges(valueChanged: type)
        }
            
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if selection == K.categoryRecurrence && recurrence[0].checked == true {
            if indexPath.row != 0 {
                return nil
            }
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                if indexPathForSelectedRow == indexPath {
                    tableView.deselectRow(at: indexPath, animated: false)
                    time[indexPath.row].checked = false
                    tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    return nil
                }
            }
        }

        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if selection == K.categoryRecurrence && recurrence[0].checked == true {
            if indexPath.row != 0 {
                return nil
            }
        }
        return indexPath
    }

    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        switch selection {
        case K.categoryTime:
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            time[indexPath.row].checked = false
            self.myDetailDelegate?.saveCategoryChanges(valueChanged: time)
        case K.categoryRecurrence:
            if indexPath.row == 0 {
                var indexPath = IndexPath(row: 0, section: 0)
                for index in 1..<recurrence.count{
                    indexPath.row = index
                    tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    tableView.cellForRow(at: indexPath)?.backgroundColor = .none
                    tableView.cellForRow(at: indexPath)?.textLabel?.textColor = .black
                }
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            recurrence[indexPath.row].checked = false
            self.myDetailDelegate?.saveCategoryChanges(valueChanged: recurrence)
        default:
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            type[indexPath.row].checked = false
        }
        
    }
}

