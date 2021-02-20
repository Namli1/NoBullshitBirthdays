//
//  BirthdayTableViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 12.04.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
import ConfettiView

class BirthdayTableViewController: CompanionSkeletonTableViewController {
            
    let userDefaults = UserDefaults.standard
    
    var interactionController: UIPercentDrivenInteractiveTransition? = nil
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.rowHeight = 90.0
        tableView.separatorStyle = .none
        
        loadCompanions()
        
        print("Count here: \(companions.count)")
                
        for companion in self.companions {
            let calendar = Calendar.current
            if let birthDate = companion.normalizedBirthday {
                let companionBirthDate = calendar.dateComponents([.month, .day], from: birthDate)
                let today = calendar.dateComponents([.month, .day], from: Date())
                if companionBirthDate == today {
                    let confettiView = ConfettiView()
                    self.view.addSubview(confettiView)
                    confettiView.emit(with: [.text("🎁"), .text("🎈"), .text("🎉"), .shape(.triangle, self.userDefaults.color(forKey: "mainColor") ?? FlatRed()),])
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBirthdays), name: .NSCalendarDayChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCompanions), name: Notification.Name("updateCompanions"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeColor(_:)), name: Notification.Name("didChangeColor"), object: nil)
        
        if let color = userDefaults.color(forKey: "mainColor") {
            if color == FlatWhite() {
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:color.darken(byPercentage: 0.33)!]
            } else {
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:color]
            }
        }
        
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let companions = fetchedResultsController.fetchedObjects else { return 0 }
        return companions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCell") as? BirthdayTableViewCell  else {
            fatalError("Dequed cell is not an instance of BirthdayTableViewCell")
        }
        
        let companion = fetchedResultsController.object(at: indexPath)
        
        cell.nameLabel.text = companion.name
        if let birthday = companion.birthday {
            cell.birthDate.text = birthday.toString()
        }
        guard let normalizedBirthday = companion.normalizedBirthday else { fatalError("No normalized birthday created for this companion object")}
        switch daysFromToday(to: normalizedBirthday) {
        case "0":
            cell.countdown.text = "Today"
        case "1":
            cell.countdown.text = "Tomorrow!"
        default:
            cell.countdown.text = "\(daysFromToday(to: normalizedBirthday)) Days"
        }
        
        guard let selectedColor = userDefaults.color(forKey: "mainColor") else {
            fatalError("No color set")
        }
        
        cell.backgroundColor = selectedColor.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(companions.count + 10))
        cell.nameLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: selectedColor, isFlat: true)
        cell.countdown.textColor = UIColor(contrastingBlackOrWhiteColorOn: selectedColor, isFlat: true)
        cell.birthDate.textColor = UIColor(contrastingBlackOrWhiteColorOn: selectedColor, isFlat: true)
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func updateBirthdays() {
        let calendar = Calendar.current
        DispatchQueue.main.async {
            self.loadCompanions()
            for companion in self.companions {
                if let birthDate = companion.normalizedBirthday {
                    let companionBirthDate = calendar.dateComponents([.month, .day], from: birthDate)
                    let today = calendar.dateComponents([.month, .day], from: Date())
                    if companionBirthDate == today {
                        let confettiView = ConfettiView()
                        self.view.addSubview(confettiView)
                        confettiView.emit(with: [.text("🎁"), .text("🎈"), .text("🎉"), .shape(.triangle, self.userDefaults.color(forKey: "mainColor") ?? FlatRed()),])
                        
                    }
                }
                companion.normalizedBirthday = normalizeYear(date: companion.normalizedBirthday)
            }
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: - Segues, presentations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            let settingsVC = segue.destination as! SettingsViewController
        }
    }
    
    //MARK: - Notification Center methods
    @objc func updateCompanions() {
        loadCompanions()
        print("Update companions called")
        tableView.reloadData()
    }
    
    @objc func didChangeColor(_ notification: Notification) {
        
        if let color = notification.userInfo?["color"] as? UIColor {
            if color == FlatWhite() {
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:color.darken(byPercentage: 0.33)!]
            } else {
               navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:color]
            }
            
            tableView.reloadData()
        }
    }
}
