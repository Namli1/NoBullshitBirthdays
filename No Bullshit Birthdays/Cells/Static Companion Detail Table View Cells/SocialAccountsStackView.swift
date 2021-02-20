//
//  SocialAccountsStackView.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 04.10.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

class SocialAccountsStackView: UIStackView {
    
    var platform: String? {
        didSet {
            if let platformName = platform {
                if platformName == "Sina Weibo" {
                    platformNameLabel.setImage(UIImage(named: "Sina-Weibo.png")?.withRenderingMode(.alwaysOriginal), for: .normal)
                } else if platformName == "Other" {
                    platformNameLabel.setTitle("Other", for: .normal)
                    platformNameLabel.titleLabel?.adjustsFontSizeToFitWidth = true
                } else {
                    platformNameLabel.setImage(UIImage(named: "\(platformName).png")?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
                
                platformNameLabel.imageView?.contentMode = .scaleAspectFit
            }
                        
        }
    }
    
    var userName: String? {
        didSet {
            if let name = userName {
                accountNameLabel.text = "\(name)"
            }
        }
    }
    
    
    @IBOutlet weak var platformNameLabel: UIButton!
    @IBOutlet weak var accountNameLabel: UILabel!
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func didPressLogo(_ sender: UIButton) {
        if let socialMediaName = platform, let username = userName {
            for socialMedia in SocialMedias.allCases {
                if socialMedia.rawValue == socialMediaName {
                    let application = UIApplication.shared
                    if let url = socialMedia.webURL {
                        guard let webURL = URL(string: "\(url)\(username)") else { continue }
                        application.open(webURL)
                    }
                }
            }
        }
    }
    

}

