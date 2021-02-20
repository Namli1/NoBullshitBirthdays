//
//  ReuseFunctions.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 03.05.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func toString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter.string(from: self)
    }

}


extension UserDefaults {
    
    func color(forKey key: String) -> UIColor? {

        guard let colorData = data(forKey: key) else { return nil }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }

    }

    func set(_ value: UIColor?, forKey key: String) {

        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }

    }
    
}

//MARK: - NormalizeBirthday functions

func normalizeYear(date: Date?) -> Date? {
    guard let birthday = date else { fatalError("No birthday passed in to normalize")}
    let calendar = Calendar.current
    var dateComponents = calendar.dateComponents([.month, .day], from: birthday)
    let dateNoYear = calendar.date(from: dateComponents)
    
    if dateNoYear! < calendar.date(from: calendar.dateComponents([.month, .day], from: Date()))! {
        
        dateComponents.year = calendar.dateComponents([.year], from: calendar.date(byAdding: .year, value: +1, to: Date())!).year
        
    } else {
        dateComponents.year = calendar.component(.year, from: Date())
    }
    let normalizedBirthday = calendar.date(from: dateComponents)
    return normalizedBirthday
}

func daysFromToday(to birthday: Date) -> String {
    let calendar = Calendar.current
    
    let dateDifference = Calendar.current.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: birthday))
    
    return "\(dateDifference.day!)"
}


//MARK: - UIimage View
extension UIImageView {

    func makeRounded() {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}



//MARK: - Core Data load/save method

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

func saveCompanions() {
    //if context.hasChanges {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    //}
}

//MARK: - Contacting Frequency

enum ContactingFrequencies: String, CaseIterable {
    case oneYear = "1 year"
    case nineMonths = "9 months"
    case sixMonths = "6 months"
    case threeMonths = "3 months"
    case oneMonth = "1 month"
    case twoWeeks = "2 weeks"
    case oneWeek = "1 week"
    case None = "None"
    
    static let allFrequencies: [String] = [oneYear.rawValue, nineMonths.rawValue, sixMonths.rawValue, threeMonths.rawValue, oneMonth.rawValue, twoWeeks.rawValue, oneWeek.rawValue, None.rawValue]
    
    var number: Int {
        switch self {
        case .oneYear:
            return 365
        case .nineMonths:
            return 274
        case .sixMonths:
            return 183
        case .threeMonths:
            return 91
        case .oneMonth:
            return 30
        case .twoWeeks:
            return 14
        case .oneWeek:
            return 7
        case .None:
            return 0
        }
    }

}

func turnContactingFrequencyIntoNumber(for frequency: String) -> Int? {
    
    switch frequency {
    case "1 year":
        return 365
    case "9 months":
        return 274
    case "6 months":
        return 183
    case "3 months":
        return 91
    case "1 month":
        return 30
    case "2 weeks":
        return 14
    case "1 week":
        return 7
    case "None":
        return 0
    default:
        return nil
    }
    
}

func turnNumberIntoContactingFrequency(number: Int) -> String? {
    switch number {
    case 365:
        return "1 year"
    case 274:
        return "9 months"
    case 183:
        return "6 months"
    case 91:
        return "3 months"
    case 30:
        return "1 month"
    case 14:
        return "2 weeks"
    case 7:
        return "1 week"
    case 0:
        return "None"
    default:
        return nil
    }
}

func addDaysFromToday(days: Int) -> Date? {
    var dayComponents = DateComponents()
    dayComponents.day = days
    let calendar = Calendar.current
    let nextDate = calendar.date(byAdding: dayComponents, to: Date())
    
    return nextDate
}

//MARK: - Social Media Names and URLs
enum SocialMedias: String, CaseIterable {
    case Facebook = "Facebook"
    case Instagram = "Instagram"
    case Twitter = "Twitter"
    case Snapchat = "Snapchat"
    case Youtube = "Youtube"
    case Line = "Line"
    case WeChat = "WeChat"
    case QQ = "QQ"
    case SinaWeibo = "Sina Weibo"
    case Flickr = "Flickr"
    case LinkedIn = "LinkedIn"
    
    static let allSocialMedias = [Facebook.rawValue, Instagram.rawValue, Twitter.rawValue, Snapchat.rawValue, Youtube.rawValue, Line.rawValue, WeChat.rawValue, QQ.rawValue, SinaWeibo.rawValue, Flickr.rawValue, LinkedIn.rawValue]
    
    var webURL : String? {
        switch self {
        case .Facebook:
            return "https://www.facebook.com/"
        case .Instagram:
            return "https://instagram.com/"
        case .Twitter:
            return "https://twitter.com/"
        case .LinkedIn:
            return "https://www.linkedin.com/in/"
        case .Snapchat:
            return "https://www.snapchat.com/add/"
        case .Youtube:
            return "https://www.youtube.com/results?search_query="
        case .Line:
            return "https://line.me/R/ti/p/@"
        case .QQ:
            return "https://icq.com/people/"
        case .SinaWeibo:
            return nil
        case .Flickr:
            return "https://www.flickr.com/people/"
        case .WeChat:
            return nil
        }

    }
}
