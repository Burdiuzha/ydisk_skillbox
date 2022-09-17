//
//  ResourceListCoreData+CoreDataProperties.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 24.08.2022.
//
//

import Foundation
import CoreData


extension ResourceListCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ResourceListCoreData> {
        return NSFetchRequest<ResourceListCoreData>(entityName: "ResourceListCoreData")
    }

    @NSManaged public var limit: Int64
    @NSManaged public var offset: Int64
    @NSManaged public var path: String?
    @NSManaged public var public_key: String?
    @NSManaged public var sort: String?
    @NSManaged public var total: Int64
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension ResourceListCoreData {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ResourceCoreData)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ResourceCoreData)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension ResourceListCoreData : Identifiable {

}
