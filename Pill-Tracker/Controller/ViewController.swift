//
//  ViewController.swift
//  Pill-Tracker
//
//  Created by Léa on 04/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dailyCapsuleManager = DailyCapsuleManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDate()

        tableView.register(UINib(nibName: "CapsuleCell", bundle: nil), forCellReuseIdentifier: "reusableCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func updateDate() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        dateLabel.text = formatter.string(from: date)
    }

}


extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyCapsuleManager.dailyCaps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "reusableCell") as! CapsuleCell
        
        cell.capsuleLabel.text = dailyCapsuleManager.dailyCaps[indexPath.row].name
        cell.nbLabel.text = String(dailyCapsuleManager.dailyCaps[indexPath.row].quantity)
        cell.cellBGColor.backgroundColor = dailyCapsuleManager.dailyCaps[indexPath.row].color
        
       return cell
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        dailyCapsuleManager.dailyCaps[indexPath.row].updatePill()
        tableView.reloadData()
        
    }

    
}
