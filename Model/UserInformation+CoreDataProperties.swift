//
//  UserInformation+CoreDataProperties.swift
//  Todo
//
//  Created by IcyBlast on 1/6/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//
//

import Foundation
import CoreData


extension UserInformation
{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInformation> {
        return NSFetchRequest<UserInformation>(entityName: "UserInformation")
    }

    @NSManaged public var userName: String?
    @NSManaged public var userPassword: String?
    @NSManaged public var userPhoto: NSData?
    @NSManaged public var labels: NSSet?

}

// MARK: Generated accessors for labels
extension UserInformation {

    @objc(addLabelsObject:)
    @NSManaged public func addToLabels(_ value: UserLabels)

    @objc(removeLabelsObject:)
    @NSManaged public func removeFromLabels(_ value: UserLabels)

    @objc(addLabels:)
    @NSManaged public func addToLabels(_ values: NSSet)

    @objc(removeLabels:)
    @NSManaged public func removeFromLabels(_ values: NSSet)

}
