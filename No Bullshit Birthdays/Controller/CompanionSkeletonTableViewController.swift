//
//  CompanionSkeletonTableViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 30.05.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import CoreData



class CompanionSkeletonTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var companions = [Companion]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
    //MARK: - fetchedResults Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController<Companion> = {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<Companion>(entityName: "Companion")

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "normalizedBirthday", ascending: true), NSSortDescriptor(key: "birthday", ascending: true), NSSortDescriptor(key: "name", ascending: true)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let companions = fetchedResultsController.fetchedObjects else { return 0 }
        return companions.count
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            
            
            self.loadCompanions()
            
            //TODO: Deletes at wrong indexPath, due to NSFetchedResultsController
            print("Delete count: \(indexPath.row)")
            self.context.delete(self.companions[indexPath.row])
            self.companions.remove(at: indexPath.row)
            
            self.saveCompanions()

            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    //MARK: - Core data functions
    
    func loadCompanions() {
        let request : NSFetchRequest<Companion> = Companion.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "normalizedBirthday", ascending: true), NSSortDescriptor(key: "birthday", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        do {
            companions = try context.fetch(request)
            //companions = fetchedResultsController.fetchedObjects!
        } catch {
            print("Error fetching data from context, \(error)")
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
            tableView.reloadData()
        }
    }

}


extension CompanionSkeletonTableViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
               tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                print("Delete Rows count: \(indexPath.row)")
            }
        default:
            print("Error updating tableView using NSFetchedResultsController")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
