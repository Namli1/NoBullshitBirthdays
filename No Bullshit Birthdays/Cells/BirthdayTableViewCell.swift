//
//  BirthdayTableViewCell.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 12.04.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

class BirthdayTableViewCell: UITableViewCell {

    //MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthDate: UILabel!
    @IBOutlet weak var countdown: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}
