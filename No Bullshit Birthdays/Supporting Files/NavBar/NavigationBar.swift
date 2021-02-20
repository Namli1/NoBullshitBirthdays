//
//  NavigationBar.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 08.09.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

class NavigationBar: UIView {
    
    private static let NIB_NAME = "NavigationBar"
    
    @IBOutlet private var navBarView: NavigationBar!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var barTitle: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    
    
    
    
    override func awakeFromNib() {
        initWithNib()
    }
    
    private func initWithNib() {
        Bundle.main.loadNibNamed(NavigationBar.NIB_NAME, owner: self, options: nil)
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navBarView)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
          [
             navBarView.topAnchor.constraint(equalTo: topAnchor),
             navBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
             navBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
             navBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
          ]
        )
    }

}
