//
//  AddBirthdayViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 12.04.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import CoreData

class AddBirthdayViewController: AddCompanionSkeletonViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var addPopUpView: UIView!
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.hideKeyboardWhenTappedAround()
        
        nameTextField.delegate = self
        
        addPopUpView.layer.cornerRadius = 10
        addPopUpView.layer.masksToBounds = true
        
        birthDatePicker.maximumDate = Date()
        birthDatePicker.addTarget(self, action: #selector(birthDateChanged(_:)), for: .valueChanged)
        
    }
    
    //MARK: - Actions
    
    @IBAction func addBirthday(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImagePressed(_ sender: UIButton) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        view.endEditing(true)
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        userPickedImage = selectedImage
        
        addImage.setImage(UIImage(named: "tickMark"), for: .normal)
        addImage.imageEdgeInsets = UIEdgeInsets(top: 0, left: 7.5, bottom: 0, right: 7.5)
        addImage.setTitle("", for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func birthDateChanged(_ sender: UIDatePicker) {
        dateLabel.text = "\(sender.date.toString())"
    }
    
    @IBAction func cancelAddBirthday(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBirthdayPressed(_ sender: UIButton) {
        if nameTextField.hasText {
            let companion = Companion(context: context)
            companion.name = nameTextField.text!
            companion.birthday = birthDatePicker.date
            if let photo = userPickedImage?.pngData() {
                companion.photo = photo
            }
            companion.normalizedBirthday = normalizeYear(date: birthDatePicker.date)
            saveCompanions()
            NotificationCenter.default.post(name: Notification.Name("updateCompanions"), object: nil)
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Form incomplete", message: "You did not enter a name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Fill in", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
    }
    
    func saveCompanions() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
