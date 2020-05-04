//
//  Capsule.swift
//  Pill-Tracker
//
//  Created by Léa on 04/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

struct Capsule {
    let name: String
    var quantity: Int
    var color: UIColor
    var counterTap: Int = 0
    
    mutating func updatePill() {
        if quantity == 1 {
            quantity = 0
            color = UIColor(named: "Nul-Color")!
        } else {
            if quantity == 4 {
                quantity = quantity/2
                counterTap += 1
            } else if quantity == 2 && counterTap == 1 {
                quantity = 0
                color = UIColor(named: "Nul-Color")!
            } else {
                quantity = quantity/2
            }
        }
    }
    
    
}
