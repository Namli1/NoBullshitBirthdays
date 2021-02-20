//
//  Companion+CoreDataProperties.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 13.08.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//
//

import Foundation
import CoreData
import PostalAddressRow


extension Companion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Companion> {
        return NSFetchRequest<Companion>(entityName: "Companion")
    }

    @NSManaged public var address: PostalAddress?
    @NSManaged public var birthday: Date?
    @NSManaged public var contactingFrequency: Int16
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var normalizedBirthday: Date?
    @NSManaged public var notes: String?
    @NSManaged public var phoneNumbers: [String]?
    @NSManaged public var photo: Data?
    @NSManaged public var socialAccounts: [[String]]?
    @NSManaged public var newRelationship: NSSet?

}

// MARK: Generated accessors for newRelationship
extension Companion {

    @objc(addNewRelationshipObject:)
    @NSManaged public func addToNewRelationship(_ value: Group)

    @objc(removeNewRelationshipObject:)
    @NSManaged public func removeFromNewRelationship(_ value: Group)

    @objc(addNewRelationship:)
    @NSManaged public func addToNewRelationship(_ values: NSSet)

    @objc(removeNewRelationship:)
    @NSManaged public func removeFromNewRelationship(_ values: NSSet)

}
