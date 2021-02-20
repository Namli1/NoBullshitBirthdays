//
//  PhoneNumberStackView.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 03.10.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

//@IBDesignable
class PhoneNumberStackView: UIStackView {
    
    let nibName = "PhoneNumberStackView"
    var contentView: UIStackView?

    @IBOutlet weak var phoneNumberCount: UILabel!
    @IBOutlet weak var phoneNumberButton: UIButton!
    
    
    @IBAction func callNumber(_ sender: Any) {
        if let number = self.phoneNumberButton.titleLabel?.text {
            print(number)
            guard let number = URL(string: "tel://" + "\(number)") else { return }
            UIApplication.shared.open(number)
        }
        
    }
    
    
    
    
//    required init(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//
//    func commonInit() {
//        guard let view = loadViewFromNib() else { return }
//        view.frame = self.bounds
//        self.addSubview(view)
//        contentView = view
//    }
//
//    func loadViewFromNib() -> UIStackView? {
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: nibName, bundle: bundle)
//
//        return nib.instantiate(withOwner: self, options: nil).first as? UIStackView
//
//    }

}
