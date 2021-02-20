//
//  AppDelegate.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 12.04.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var companions = [Companion]()
    
    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        loadCompanions()
        for companion in companions {
            companion.normalizedBirthday = normalizeYear(date: companion.normalizedBirthday)
        }
        
        if UserDefaults.standard.color(forKey: "mainColor") == nil {
            UserDefaults.standard.set(FlatTeal(), forKey: "mainColor")
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if !granted {
                print("user did not allow")
            }
        }
        
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.scheduleBirthdayNotifications()
                self.scheduleContactingIntervals()
            } else {
                print("Can't send notifications")
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "No_Bullshit_Birthdays")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func loadCompanions() {
        let context = persistentContainer.viewContext
        let request : NSFetchRequest<Companion> = Companion.fetchRequest()
        do {
            companions = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
    }
    
    //Birthday notification function
    func scheduleBirthdayNotifications() {
        for companion in companions {
            if let birthDate = companion.birthday, let name = companion.name {
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "\(name)'s birthday", arguments: nil)
                guard let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year else { return }
                content.body = NSString.localizedUserNotificationString(forKey: "Today \(name) will turn \(age + 1). Be sure to send your congratulations.", arguments: nil)
                
                var dateComponents = DateComponents()
                dateComponents.calendar = Calendar.current
                   
                let triggerYearly = Calendar.current.dateComponents([.day, .month ], from: birthDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerYearly, repeats: true)
                
                let identifier = "\(name), \(birthDate)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                notificationCenter.add(request) { (error) in
                    if let error = error {
                        print("Error occureed with birthday notifications, \(error)")
                    }
                }
                
            }
        }
    }
    
    
    func scheduleContactingIntervals() {
        for companion in companions {

            if let name = companion.name, companion.contactingFrequency != 0 {
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "Time to contact \(name)", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "It's time to contact \(name) again. Come on, it's not that hard", arguments: nil)
                
                let timeInterval = 60*60*24*Int64(companion.contactingFrequency)
                let triggerInterval = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: true)
                
                let identifier = "\(name), contactingFrequency"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: triggerInterval)
                
                notificationCenter.add(request) { (error) in
                    if let error = error {
                        print("Error occured with frequency notifications, \(error)")
                    }
                }
            }
            
            
        }
    }

}

