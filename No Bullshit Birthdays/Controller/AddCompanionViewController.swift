//
//  AddCompanionViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 31.05.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

class AddCompanionViewController: AddCompanionSkeletonViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let addOptions = ["Telephone", "E-Mail", "Address"]
    
    
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addOptionsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField : UITextField?
    var lastOffset : CGPoint?
    var keyboardHeight : CGFloat?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addOptionsTableView.delegate = self
        addOptionsTableView.dataSource = self
        
        setupUI()
    
    }
    

    //MARK: - Table View Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addOptionCell", for: indexPath) as? AddOptionTableViewCell else { fatalError("Couldn't find cell class")}
        
        let addOption = addOptions[indexPath.row]
        
        cell.descriptionLabel.text = addOption
        cell.typeTextField.isHidden = true
        cell.typeTextField.placeholder = "Enter the \(addOption)"
        
        switch indexPath.row {
        case 0:
            cell.typeTextField.keyboardType = .numberPad
            cell.typeTextField.placeholder = "Enter the \(addOption) Number"
        case 1:
            cell.typeTextField.keyboardType = .emailAddress
        default:
            break;
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override var userPickedImage: UIImage? {
        didSet {
            print("User picked image")
            
            addImageButton.setImage(userPickedImage, for: .normal)
            addImageButton.setTitle("", for: .normal)
            addImageButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            addImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            addImageButton.imageView?.makeRounded()
        }
    }
    
    
    @IBAction func addImagePressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        view.endEditing(true)
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func setupUI() {
        //Bottom line for name textField
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: 50, width: nameTextField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.black.cgColor
        nameTextField.borderStyle = .none
        nameTextField.layer.addSublayer(bottomLine)
        
        addImageButton.imageView?.contentMode = .scaleAspectFit
        //Table view setup
        addOptionsTableView.separatorStyle = .none
    }
    
    
    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}


//extension AddCompanionViewController: UITextFieldDelegate {
//
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        activeField = textField
//
//        lastOffset = self.scrollView.contentOffset
//
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        activeField?.resignFirstResponder()
//
//        activeField = nil
//
//        return true
//    }
//}
//
////MARK: - Keyboard Handling
//extension AddCompanionViewController {
//    func keyboardWillShow(notification: NSNotification) {
//        if keyboardHeight != nil {
//            return
//        }
//
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            keyboardHeight = keyboardSize.height
//
//            //increase contentView's height by keyboard height
//            UIView.animate(withDuration: 0.3) {
//
//            }
//        }
//    }
//}
