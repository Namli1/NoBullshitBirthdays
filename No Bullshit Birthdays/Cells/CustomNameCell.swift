//
//  CustomNameCell.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 16.06.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import Eureka

class CustomNameCell: Cell<String>, CellType {
    
    @IBOutlet weak var nameTextField: UITextField!
    let bottomLine = CALayer()
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
            
    }
    
    override func setup() {
        super.setup()
        
        //Text Field setup
        selectionStyle = .none
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        if let row = row as? CustomNameRow {
            nameTextField.text = row.value
        }
        
        //Bottom line for name textField
        bottomLine.frame = CGRect(x: 0.0, y: 80, width: nameTextField.bounds.width + 100, height: 1.0)
        bottomLine.backgroundColor = UIColor.black.cgColor
        nameTextField.borderStyle = .none
        nameTextField.layer.addSublayer(bottomLine)
        
        height = { return 91 }
    }
    
    override func update() {
        super.update()
        
        guard let row = row as? CustomNameRow else { return }
        
        nameTextField.placeholder = row.placeholder
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let row = row as? CustomNameRow else { return }
        
        if let text = nameTextField.text {
            row.value = text
        }
                
    }
    
}



final class CustomNameRow: Row<CustomNameCell>, RowType {
    
    var placeholder: String?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<CustomNameCell>(nibName: "CustomNameCell")
    }
}
