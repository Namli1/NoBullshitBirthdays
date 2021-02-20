//
//  CustomImageCell.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 14.06.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import Eureka

protocol CustomImageCellDelegate {
    func didPickImage()
}

public final class CustomImageCell: Cell<UIImage>, CellType, PickedImageProtocol {
    
    @IBOutlet weak var selectImageButton: UIButton!
    
    var delegate : CustomImageCellDelegate?
    var pickedImageDelegate: PickedImageProtocol?
    
    var pickedImage: UIImage? {
        didSet {
            if let image = pickedImage {
                selectImageButton.setImage(image, for: .normal)
                selectImageButton.setTitle("", for: .normal)
                selectImageButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                selectImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                selectImageButton.imageView?.makeRounded()
                
                
                //Save value
                guard let row = row as? CustomImageRow else { return }
                row.value = image
                
            }
        }
    }
    
    var buttonText = "Add image button"
    
    override public func setup() {
        super.setup()
        
        selectImageButton.setTitle(buttonText, for: .normal)
        
        selectionStyle = .none
        pickedImageDelegate = self
        
        if let row = row as? CustomImageRow, let rowValue = row.value {
            selectImageButton.setImage(rowValue, for: .normal)
            selectImageButton.setTitle("", for: .normal)
            selectImageButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            selectImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            selectImageButton.imageView?.makeRounded()
        }
        
        height = { return 350 }
    }
    
    @IBAction func addImagePressed(_ sender: UIButton) {
        
        delegate?.didPickImage()
        
    }
    
}

public final class CustomImageRow: Row<CustomImageCell>, RowType {

    
    public required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<CustomImageCell>(nibName: "CustomImageCell")
        
    }
}
