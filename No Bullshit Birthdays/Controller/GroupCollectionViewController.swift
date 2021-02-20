//
//  GroupCollectionViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 25.06.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "groupCell"

class GroupCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var groups = [Group]()
    
    //needed for fetchedresultscontroller
    var insertIndexPaths = [IndexPath]()
    var deleteIndexPaths = [IndexPath]()
    var updateIndexPaths = [IndexPath]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView!.register(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding : CGFloat = 50
        let collectionViewSize = collectionView.frame.size.width - padding
                
        return CGSize(width: 50, height: 380)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = fetchedResultsController.fetchedObjects?.count else { return 1 }
        return count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? GroupCollectionViewCell else { fatalError("Collection view cell reuse identifier not found") }
    
        let group = fetchedResultsController.object(at: indexPath)
        
        if let image = group.groupImage {
            //cell.groupImage.image = UIImage(data: image)
        }
        cell.groupImage.image = UIImage(systemName: "trash")?.withTintColor(.black)
        
        if let name = group.name {
           cell.groupName.text = name
        }

        if let activeTime = group.activeTime {
            cell.groupActiveTime.text = activeTime
        }
        if let notes = group.notes {
            cell.groupNotes.text = notes
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    
    
    
    
    
    
    
    //MARK: - fetchedResults Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController<Group> = {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<Group>(entityName: "Group")

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "notes", ascending: true), NSSortDescriptor(key: "activeTime", ascending: true)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    //MARK: - Core data functions
    
    func loadGroups() {
        let request : NSFetchRequest<Group> = Group.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "notes", ascending: true), NSSortDescriptor(key: "activeTime", ascending: true)]
        do {
            groups = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
    }
    
    func saveGroups() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            collectionView.reloadData()
        }
    }

}

extension GroupCollectionViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type{

        case .insert:
            print("Insert an item newIndexPath : \(newIndexPath!)")
            self.insertIndexPaths.append(newIndexPath!)

        case .delete:
            print("Delete an Item")
            deleteIndexPaths.append(indexPath!)

        case .update:
            print("Update an item")
            updateIndexPaths.append(indexPath!)

        case .move:
            print("move")

        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({
            
            for indexPath in self.insertIndexPaths {
                print("Inserting FetchedObjects at: \(indexPath)")
                self.collectionView.insertItems(at: [indexPath])
            }

            for indexPath in self.deleteIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }

            for indexPath in self.updateIndexPaths{
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            
        }) { _ in
            print("finished")
        }
    }
    
}
