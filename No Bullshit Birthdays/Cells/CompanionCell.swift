//
//  CompanionCell.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 23.05.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

class CompanionCell: UITableViewCell {
    
    @IBOutlet weak var companionPicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
