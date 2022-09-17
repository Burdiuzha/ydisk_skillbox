//
//  AllFileResourseList+CoreDataProperties.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 25.08.2022.
//
//

import Foundation
import CoreData


extension AllFileResourseList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AllFileResourseList> {
        return NSFetchRequest<AllFileResourseList>(entityName: "AllFileResourseList")
    }

    @NSManaged public var limit: Int64
    @NSManaged public var path: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension AllFileResourseList {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ResourceCoreDataAllFiles)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ResourceCoreDataAllFiles)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension AllFileResourseList : Identifiable {

}
