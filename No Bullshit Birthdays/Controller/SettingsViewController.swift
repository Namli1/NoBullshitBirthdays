//
//  SettingsPopoverViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 13.05.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import ChameleonFramework

class ColorCell: UICollectionViewCell {
    
    @IBOutlet weak var checkedImage: UIImageView!
    
}

class SettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var interactionController: UIPercentDrivenInteractiveTransition? = nil
    
    let userDefaults = UserDefaults.standard
        
    let colors = [FlatWhite(), FlatBlack(), FlatRed(), FlatSkyBlue(), FlatGreen(), FlatYellow(), FlatMagenta(), FlatPink(), FlatTeal()]

    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        
        transitioningDelegate = self
        
        let swipeDown = UIPanGestureRecognizer(target: self, action: #selector(self.dismissVC(_:)))
        self.view.addGestureRecognizer(swipeDown)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let birthdayVC = segue.source as! BirthdayTableViewController
        
        //TODO: Change colour !!!
    }
    
    //MARK: - CollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCell  else { fatalError("No ColorCell class found!")}
        
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.cornerRadius = 21
        
        if cell.backgroundColor == userDefaults.color(forKey: "mainColor"){
            cell.checkedImage.image = UIImage(systemName: "checkmark")
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { fatalError("No ColorCell class found!")}
        cell.checkedImage.image = .none
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { fatalError("No ColorCell class found!")}
        
        cell.checkedImage.image = UIImage(systemName: "checkmark")
        userDefaults.set(cell.backgroundColor, forKey: "mainColor")
        NotificationCenter.default.post(name: Notification.Name("didChangeColor"), object: nil, userInfo: ["color": cell.backgroundColor!])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height / 4, height: collectionView.frame.height / 3.5)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func dismissVC(_ gesture: UIPanGestureRecognizer) {
                
        let translation = gesture.translation(in: view)
        let progress = translation.y / 1.5 / 500
        
        let velocity = gesture.velocity(in: view)

        if velocity.y < 0 {
            
            switch gesture.state {
            case .began:
                interactionController = UIPercentDrivenInteractiveTransition()
                self.dismiss(animated: true, completion: nil)
            case .changed:
                interactionController?.update(progress)
            case .ended:
                if progress + gesture.velocity(in: view).y / 500 > 0.3 {
                    interactionController?.cancel()
                } else {
                    interactionController?.finish()
                }
                interactionController = nil
            default:
                break;
            }
            
        }

        
        
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        //self.hero.modalAnimationType = .autoReverse(presenting: .slide(direction: .down))
        self.dismiss(animated: true, completion: nil)
    }
    
    

}


extension SettingsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SettingsSlideDownManager(animationDuration: 1.5, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SettingsSlideDownManager(animationDuration: 1.5, animationType: .dismiss)
    }
    
}
