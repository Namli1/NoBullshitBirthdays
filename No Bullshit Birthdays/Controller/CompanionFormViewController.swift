//
//  CompanionFormViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 13.06.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import Eureka
import SplitRow
import PostalAddressRow
import Contacts
import ContactsUI

protocol PickedImageProtocol {
    var pickedImage: UIImage? { get set }
}

class CompanionFormViewController: FormViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CustomImageCellDelegate, UIAdaptivePresentationControllerDelegate {
            
    var imageDelegate: PickedImageProtocol?
    
    var contact : CNContact?
    
    var companionObject: Companion?
    
    var numbersCount: Int = 1
    var accountCount: Int = 1
    
    var socialAccounts : [String] = ["Instagram", "Twitter", "Snapchat", "Facebook", "Youtube", "WeChat", "Sina Weibo", "QQ", "Line", "LinkedIn", "Flickr", "Other"]
    
    var imageButtonText: String = "Add portrait"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let contact = contact {
            numbersCount = contact.phoneNumbers.count > 0 ? contact.phoneNumbers.count : 1
            accountCount = contact.socialProfiles.count > 0 ? contact.socialProfiles.count : 1
        }
        
        if let companion = companionObject {
            if let numbers = companion.phoneNumbers {
                numbersCount = numbers.count > 0 ? numbers.count : 1
            }
            if let accounts = companion.socialAccounts {
                accountCount = accounts.count > 0 ? accounts.count : 1
            }
        }
        
                
        setupCompanionForm()
        
        setUpCompanionFromContact()
        
        setUpCompanionFormWithCompanionObject()
        
        print("VCdidLoad: \(form.values())")
        
        navigationController?.presentationController?.delegate = self
        
        self.isModalInPresentation = true
    }
    
    //MARK: - Image Picker Controller Delegate Methods
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        imageDelegate?.pickedImage = selectedImage
                
        dismiss(animated: true, completion: nil)
    
    }
    
    func didPickImage() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        view.endEditing(true)
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        areYouSureDismiss()
    }
    
    
    //Cancel button
    @IBAction func didCancel(_ sender: UIBarButtonItem) {
        areYouSureDismiss()
    }
    
    
    @IBAction func submitForm(_ sender: UIBarButtonItem) {
        
        print("tried to submit")
        print(form.values())
        
        
        if form.validate().isEmpty {
            
            var companion : Companion?
                        
            if let companionObject = companionObject {
                companion = companionObject
                print("\nediting companion")
            } else {
                companion = Companion(context: context)
            }

            ///Companion Name
            let nameRow: CustomNameRow = form.rowBy(tag: "Name")!
            companion?.name = nameRow.value
            
            ///Companion Birthday
            if let birthdayRow: DateRow = form.rowBy(tag: "Birthday") {
                companion?.birthday = birthdayRow.value
                companion?.normalizedBirthday = normalizeYear(date: birthdayRow.value)
            }
            
            ///Companion Picture
            if let imageRow: CustomImageRow = form.rowBy(tag: "Profile Picture"), let photo = imageRow.value?.pngData()  {
                companion?.photo = photo
            }

            ///Companion Contacting Frequency
            if let alertRow: AlertRow<String> = form.rowBy(tag: "Contacting frequency"), let frequency = alertRow.value {
                if let number = turnContactingFrequencyIntoNumber(for: frequency) {
                    companion?.contactingFrequency = Int16(number)
                }
            }
            
            ///Companion E-Mail
            if let emailRow: EmailRow = form.rowBy(tag: "E-Mail") {
                if let email = emailRow.value {
                    companion?.email = email
                } else {
                    companion?.email = nil
                }

            }
            
            ///Companion Notes
            if let noteRow: TextAreaRow = form.rowBy(tag: "Notes") {
                if let notes = noteRow.value {
                    companion?.notes = notes
                } else {
                    companion?.notes = nil
                }
                
            }
            
            ///Companion Phone Numbers
            if let numbers = form.values()["Phone Numbers"] as? [String] {
                companion?.phoneNumbers = numbers
            }
            
            ///Companion Social Accounts
            if let accounts = form.values()["Social Media Accounts"]  as? [SplitRowValue<String, String>] {
                if accounts.count >= 1 {
                    var accountsOuterArray = [[String]]()
                    
                    for index in 0...(accounts.count - 1) {
                        var accountsInnerArray = [String]()
                        
                        guard let service = accounts[index].left else { continue }
                        guard let username = accounts[index].right else { continue }
                        
                        //Inner array, index=0 is the service name, index=1 is the username
                        accountsInnerArray.append(service)
                        accountsInnerArray.append(username)
                        
                        accountsOuterArray.append(accountsInnerArray)
                    }
                    companion?.socialAccounts = accountsOuterArray
                } else {
                    companion?.socialAccounts = [[String]]()
                }

                
            }
            
            ///Companion address
            if let addressRow: PostalAddressRow = form.rowBy(tag: "Address"), let address = addressRow.value {
                //let newAddress = PostalAddress(street: address.street ?? "", state: address.state ?? "", postalCode: address.postalCode ?? "", city: address.city ?? "", country: address.country ?? "")
                
                print("Context has changes: \(context.hasChanges)")
                companion?.address = PostalAddress(street: address.street, state: address.state, postalCode: address.postalCode, city: address.city, country: address.country)
                
                
                
//                if let address = addressRow.value {
//                    print("Address: \(address.city) \(address.country) \(address.postalCode)")
//                    companion?.address = address
//                }
                
            } else {
                print("Address save not called")
            }
                        
            saveCompanions()
            NotificationCenter.default.post(name: Notification.Name("didChangeCompanion"), object: nil)
            
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Form incomplete", message: "There seems to be a mistake in the form or you forget something. Please check the form again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Check again", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
    }
    
    
    //MARK: - Eureka Form Setup
    func setupCompanionForm() {
        form +++ Section()
            
            <<< CustomImageRow(){
                $0.tag = "Profile Picture"
            }.cellSetup { cell, row in
                    cell.delegate = self
                    self.imageDelegate = cell
                cell.selectImageButton.setTitle(self.imageButtonText, for: .normal)
            }
            
            <<< CustomNameRow() {
                $0.placeholder = "Enter full name"
                $0.tag = "Name"
                $0.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.bottomLine.backgroundColor = UIColor.red.cgColor
                    cell.bottomLine.frame = CGRect(x: 0.0, y: 80, width: cell.nameTextField.bounds.width, height: 3.0)
                }
            }
                
            +++ Section("Personal Information")
            
                <<< DateRow(){
                        $0.title = "Birthday"
                        $0.value = Date()
                        $0.tag = "Birthday"
                }.cellUpdate { cell, row in
                    cell.datePicker.maximumDate = Date()
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
            }
                <<< LabelRow() {
                    $0.title = "Companion group placeholder"
                }
            
            
                //TODO: Add companion group selector here
            
            +++ Section("Contacting")
              
            <<< AlertRow<String>() {
                $0.title = "Contacting frequency"
                $0.selectorTitle = "How often do you want to contact this companion?"
                $0.tag = "Contacting frequency"
                $0.options = ContactingFrequencies.allFrequencies
            }
            
            +++ MultivaluedSection(multivaluedOptions: [.Delete, .Insert], header: "Birthday present ideas", footer: nil) {
                
                $0.tag = "Present Ideas"
                
                $0.addButtonProvider = { section in
                    return ButtonRow() {
                        $0.title = "Add"
                    }
                }
                
                $0.multivaluedRowToInsertAt = { index in
                    return TextAreaRow() {
                        $0.placeholder = "Birthday present idea..."
                        $0.validationOptions = .validatesOnChange
                        $0.tag = "Present Idea \(index+1)"
                        //$0.cell.textView
                    }
                }
                
                
            }
            
            
                +++ MultivaluedSection(multivaluedOptions: [.Delete, .Insert], header: "Phone Number(s)", footer: nil) {
                    
                    $0.tag = "Phone Numbers"
                    
                    $0.addButtonProvider = { section in
                        return ButtonRow() {
                            $0.title = "Add another"
                        }
                    }
                    $0.multivaluedRowToInsertAt = { index in
                        return PhoneRow() {
                            $0.placeholder = "Another Phone Number"
                            $0.validationOptions = .validatesOnChange
                            $0.tag = "Phone Number \(index+1)"
                        }
                    }
                    
                    for index in 1...numbersCount {
                        $0 <<< PhoneRow("Phone Number \(index)") {
                            $0.placeholder = "Phone Number"
                            $0.validationOptions = .validatesOnChange
                        }
                    }
                    
                }
                
            +++ Section()
                <<< EmailRow() {
                    $0.title = "E-Mail"
                    $0.placeholder = "Enter the email"
                    $0.add(rule: RuleEmail())
                    $0.validationOptions = .validatesOnChange
                    
                    $0.tag = "E-Mail"
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                        //cell.titleLabel?.font = UIFont.boldSystemFont(ofSize: cell.titleLabel?.font.pointSize ?? 16)
                    }
                }
                
            +++ Section("Address")
                <<< PostalAddressRow() {
                    
                    $0.streetPlaceholder = "Street"
                    $0.statePlaceholder = "State"
                    $0.cityPlaceholder = "City"
                    $0.countryPlaceholder = "Country"
                    $0.postalCodePlaceholder = "Zip code"
                    $0.validationOptions = .validatesOnChange
                    $0.tag = "Address"
                }.cellUpdate { cell, row in
                        if !row.isValid {
                            cell.textLabel?.textColor = .red
                        }
                }
                
                +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Social Media Accounts", footer: nil) {
                    
                    $0.tag = "Social Media Accounts"
                    
                    $0.addButtonProvider = { section in
                        return ButtonRow() {
                            $0.title = "Add"
                        }
                    }
                    
                    $0.multivaluedRowToInsertAt = { index in
                        return SplitRow<PushRow<String>, AccountRow>() {
                            $0.rowLeftPercentage = 0.39
                            
                            $0.rowLeft = PushRow<String>(){ row in
                                row.value = "Instagram"
                                row.cell.tintColor = UIColor.systemBlue
                                row.selectorTitle = "Account"
                                row.options = self.socialAccounts
                            }.onPresent { form, selectorController in
                                     selectorController.enableDeselection = false
                            }.cellUpdate { cell, row in
                                if row.value == "Other" {
                                    
                                    //1. Create the alert controller.
                                    let alert = UIAlertController(title: "Platform Name", message: "Please enter the platform name.", preferredStyle: .alert)

                                    //2. Add the text field.
                                    alert.addTextField { (textField) in
                                        textField.placeholder = "Platform name..."
                                    }

                                    // 3. Grab the value from the text field, and print it when the user clicks OK.
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                                        if let textField = alert?.textFields![0], textField.text != "" { // Force unwrapping because we know it exists.
                                            if let platformName = textField.text {
                                                row.value = platformName
                                                row.options?.append(platformName)
                                                row.reload()
                                            }
                                        } else {
                                            row.value = "Instagram"
                                        }
                                        
                                        
                                    }))
                                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
                                        row.value = "Instagram"
                                    }))

                                    // 4. Present the alert.
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            
                            
                            $0.rowRight = AccountRow() {
                                $0.placeholder = "Account name"
                                $0.validationOptions = .validatesOnChange
                            }
                            
                            $0.tag = "Account_\(index + 1)"
                        }
                    }
                    
                    for index in 1...accountCount {
                        $0 <<< SplitRow<PushRow<String>, AccountRow>() {
                            $0.rowLeftPercentage = 0.39
                            
                            $0.rowLeft = PushRow<String>(){ row in
                                row.value = "Instagram"
                                row.cell.tintColor = UIColor.systemBlue
                                row.selectorTitle = "Account"
                                row.options = socialAccounts
                            }
                            
                            $0.rowRight = AccountRow("Account_\(index)") {
                                $0.placeholder = "Account name"
                                $0.validationOptions = .validatesOnChange
                            }
                            
                            $0.tag = "Account_\(index)"
                        }
                    }

                }
                    
            +++ Section("Notes")
                <<< TextAreaRow() {
                    $0.placeholder = "Add notes about this companion"
                    $0.validationOptions = .validatesOnChange
                    $0.tag = "Notes"
            }
    }
    
    func setUpCompanionFormWithCompanionObject() {
        
        if let companion = companionObject {
            if let image = companion.photo {
                form.setValues(["Profile Picture": image])
                imageButtonText = "Change portrait"
            }
            
            if let birthday = companion.birthday {
                form.setValues(["Birthday": birthday])
//                let birthDate = Calendar.current.date(from: birthday)
//                form.setValues(["Birthday": birthDate])
            }
            
            if let email = companion.email {
                form.setValues(["E-Mail": email])
            }
            
            //var phoneNumbers = [String]()
            if let numbers = companion.phoneNumbers?.enumerated() {
                for (index, number) in numbers {
                    form.setValues(["Phone Number \(index+1)": number])
                }
            }
            
            if companion.contactingFrequency != 0 {
                if let frequencyString = turnNumberIntoContactingFrequency(number: Int(companion.contactingFrequency)) {
                    form.setValues(["Contacting frequency": frequencyString])
                }
            }
            
            
            if let accounts = companion.socialAccounts {
                for (index, account) in accounts.enumerated() {
                    let service = account[0]
                    let username = account[1]
                    let profile = SplitRowValue(left: service, right: username)
                    print(profile)
                    form.setValues(["Account_\(index+1)": profile])
                }
            }
            
            if let address = companion.address {
                form.setValues(["Address": address])
            }
            
            if let name = companion.name {
                form.setValues(["Name": name])
            }
            
            if let notes = companion.notes {
                form.setValues(["Notes": notes])
            }

            
        }
    }
    
    func setUpCompanionFromContact() {
        if let contact = contact {

            if let imageData = contact.imageData {
                form.setValues(["Profile Picture": UIImage(data: imageData)])
                imageButtonText = "Change portrait"
            }
            
            if let birthday = contact.birthday {
                let birthDate = Calendar.current.date(from: birthday)
                form.setValues(["Birthday": birthDate])
            }
            
            if let email = contact.emailAddresses.first?.value {
                form.setValues(["E-Mail": email])
            }
            
            //var phoneNumbers = [String]()
            for (index, number) in contact.phoneNumbers.enumerated() {
                form.setValues(["Phone Number \(index+1)": number.value.stringValue])
            }
            
            for (index, account) in contact.socialProfiles.enumerated() {
                let service = account.value.service
                let username = account.value.username
                let profile = SplitRowValue(left: service, right: username)
                print(profile)
                form.setValues(["Account_\(index+1)": profile])
            }
            
            
            
            if let address = contact.postalAddresses.first {
                let postalAdress = PostalAddress(street: address.value.street, state: address.value.state, postalCode: address.value.postalCode, city: address.value.city, country: address.value.country)
                form.setValues(["Address": postalAdress])
            }
            
            form.setValues(["Name": "\(contact.givenName) \(contact.familyName)",
                "Notes": contact.note])
        }
    }
    
    
    func areYouSureDismiss() {
        var hasValues: Bool = false
                
        for pair in form.values() {
            //These rows always have values
            if pair.key == "Birthday" || pair.key == "Account_1" || pair.key == "Phone Numbers" || pair.key == "Social Media Accounts" {
                hasValues = false
            } else {

                if pair.value != nil {
                    hasValues = true
                    break;
                }
                
            }
        }
        
        if hasValues {
            
            let alert = UIAlertController(title: "Are you sure?", message: "Are you sure that you want to discard?", preferredStyle: .actionSheet)
              
            let cancel = UIAlertAction(title: "Keep on editing", style: .cancel, handler: nil)
            let discard = UIAlertAction(title: "Discard", style: .destructive) { _ in
                self.dismiss(animated: true, completion: nil)
            }
              
            alert.addAction(cancel)
            alert.addAction(discard)
              
              present(alert, animated: true, completion: nil)
            
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
