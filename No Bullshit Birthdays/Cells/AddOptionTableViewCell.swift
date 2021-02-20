//
//  AddOptionTableViewCell.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 02.06.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

class AddOptionTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var typeTextField: UITextField!
    
    var buttonWasPressed : Bool = false
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
        
    @IBAction func addButtonPressed(_ sender: Any) {
        
        if !buttonWasPressed {
            //Animation
            UIView.animate(withDuration: 0.5, animations: {
                
                self.typeTextField.isHidden = false
                self.typeTextField.alpha = 1
                self.descriptionLabel.textColor = .flatBlue()
                self.descriptionLabel.transform = CGAffineTransform(translationX: -10, y: -30)
                self.typeTextField.transform = CGAffineTransform(translationX: 0, y: -40)
                self.layoutIfNeeded()
                
                self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                
            }) { _ in
                self.buttonWasPressed = true
            }
        } else {
            //Animation
            UIView.animate(withDuration: 0.5, animations: {
                
                self.descriptionLabel.textColor = .flatBlack()
                self.descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                self.typeTextField.transform = CGAffineTransform(translationX: 0, y: 0)
                self.typeTextField.alpha = 0
                self.layoutIfNeeded()
                
                self.addButton.transform = self.addButton.transform.rotated(by: CGFloat(Double.pi))
                
            }) { _ in
                self.buttonWasPressed = false
            }
        }
        
        
        
        
    }
    
}
