//
//  PlayerCell.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/2/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class PlayerCell: UITableViewCell {

    @IBOutlet var selectButton: UIButton?
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var teamLabel: UILabel!
    @IBOutlet var playerImage: UIImageView!
    
    override func awakeFromNib() {
        if let select = selectButton {
            select.layer.borderWidth = 3
            select.layer.borderColor = UIColor(red: 51.0/255, green: 51.0/255, blue: 51.0/255, alpha: 1).CGColor
        }
    }
    
}
