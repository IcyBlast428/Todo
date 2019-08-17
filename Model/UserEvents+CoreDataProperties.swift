//
//  UserEvents+CoreDataProperties.swift
//  Todo
//
//  Created by IcyBlast on 1/6/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//
//

import Foundation
import CoreData


extension UserEvents {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEvents> {
        return NSFetchRequest<UserEvents>(entityName: "UserEvents")
    }

    @NSManaged public var eventsName: String?
    @NSManaged public var eventsNote: String?
    @NSManaged public var eventsDate: NSDate?
    @NSManaged public var eventsPlace: String?
    @NSManaged public var labels: UserLabels?

}
