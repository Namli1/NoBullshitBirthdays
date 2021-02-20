//
//  CompanionsTableViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 23.05.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import CoreData
import ContactsUI
import Contacts


class CompanionsTableViewController: CompanionSkeletonTableViewController, CNContactPickerDelegate {
        
    var selectedContact : CNContact = CNContact()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "companionCell", for: indexPath) as? CompanionCell else { fatalError("No companion cell found")
        }
        
        let companion = fetchedResultsController.object(at: indexPath)
        
        cell.nameLabel.text = companion.name
        
        if let photoData = companion.value(forKey: "photo") as? Data {
            cell.companionPicture.image = UIImage(data: photoData)
            cell.companionPicture.makeRounded()
        } else {
            cell.companionPicture.image = UIImage(systemName: "person")
            cell.companionPicture.tintColor = .black
        }
        


        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add companion", message: "Choose how you want to add the companion", preferredStyle: .actionSheet)
        let addFromContactAction = UIAlertAction(title: "Add from Contacts", style: .default) { (alert) in
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            contactPicker.displayedPropertyKeys = [CNContactGivenNameKey,CNContactFamilyNameKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactNoteKey, CNContactPhoneNumbersKey, CNContactSocialProfilesKey]
            self.present(contactPicker, animated: true, completion: nil)
        }
        let addNew = UIAlertAction(title: "Add new companion", style: .default) { (alert) in
            
            if let companionFormVC = self.storyboard?.instantiateViewController(identifier: "companionForm") {
                let navVC = UINavigationController(rootViewController: companionFormVC)
                self.present(navVC, animated: true, completion: nil)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addFromContactAction)
        alert.addAction(addNew)
        alert.addAction(cancelAction)
                
        present(alert, animated: true, completion: nil)
    }
    
    //Pass Companion data to CompanionDetailVC
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is CompanionDetailTableViewController {
            let detailVC = segue.destination as? CompanionDetailTableViewController
                        
            guard let selectedCompanionCell = sender as? CompanionCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedCompanionCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedCompanion = fetchedResultsController.object(at: indexPath)
            detailVC?.companion = selectedCompanion
            
        }
        
        //TODO: Delete this!!!
//        if segue.identifier == "createNewCompanion" {
//            let navVC = segue.destination as? UINavigationController
//            let companionForm = navVC?.topViewController as? CompanionFormViewController
//
//            companionForm?.contact = self.selectedContact
//
//            print(companionForm)
//        }
    }
    
    
    //MARK: - CNContentPicker Delegate methods
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        self.selectedContact = contact
                
        self.dismiss(animated: true) {
            
            if let companionForm = self.storyboard?.instantiateViewController(identifier: "companionForm") as? CompanionFormViewController {
                let navVC = UINavigationController(rootViewController: companionForm)
                self.present(navVC, animated: true, completion: nil)
                companionForm.contact = self.selectedContact
            }
            
        }
        
    }


}
