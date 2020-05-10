//
//  TableViewCell.swift
//  Pill-Tracker
//
//  Created by Léa on 04/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import SwipeCellKit

class CapsuleCell: SwipeTableViewCell {

    @IBOutlet weak var nbLabel: UILabel!
    @IBOutlet weak var capsuleLabel: UILabel!
    @IBOutlet weak var cellBGColor: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
