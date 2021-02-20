//
//  CompanionDetailViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 30.05.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

class CompanionDetailViewController: UIViewController {
    
    var companion: Companion?
    
    
    @IBOutlet weak var companionPhoto: UIImageView!
    @IBOutlet weak var companionName: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabels()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        if let companionForm = self.storyboard?.instantiateViewController(identifier: "companionForm") as? CompanionFormViewController {
            let navVC = UINavigationController(rootViewController: companionForm)
            self.present(navVC, animated: true, completion: nil)
            companionForm.companionObject = companion
        }
        
    }
    
    
    func setupLabels() {
        
        if let companion = companion {
            navigationItem.title = companion.name
            //Companion Photo
            if let photoData = companion.value(forKey: "photo") as? Data {
                companionPhoto.image = UIImage(data: photoData)
                companionPhoto.makeRounded()
            } else {
                companionPhoto.image = UIImage(systemName: "person")
                companionPhoto.tintColor = .black
            }
            
            //Companion Name
            self.companionName.text = companion.name
            self.birthdayLabel.text = companion.birthday?.toString()
            
        }

        
    }
    
    //MARK: - Notification Center Methods
    
    @objc func didChangeCompanion() {
        setupLabels()
    }
    
}
