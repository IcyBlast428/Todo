//
//  UserLabels+CoreDataProperties.swift
//  Todo
//
//  Created by IcyBlast on 1/6/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//
//

import Foundation
import CoreData


extension UserLabels {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserLabels> {
        return NSFetchRequest<UserLabels>(entityName: "UserLabels")
    }

    @NSManaged public var labelName: String?
    @NSManaged public var events: NSSet?
    @NSManaged public var users: UserInformation?

}

// MARK: Generated accessors for events
extension UserLabels {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: UserEvents)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: UserEvents)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}
