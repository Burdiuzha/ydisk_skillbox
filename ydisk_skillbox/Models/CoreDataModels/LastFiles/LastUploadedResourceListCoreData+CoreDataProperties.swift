//
//  LastUploadedResourceListCoreData+CoreDataProperties.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 24.08.2022.
//
//

import Foundation
import CoreData


extension LastUploadedResourceListCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastUploadedResourceListCoreData> {
        return NSFetchRequest<LastUploadedResourceListCoreData>(entityName: "LastUploadedResourceListCoreData")
    }

    @NSManaged public var limit: Int64
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension LastUploadedResourceListCoreData {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ResourceCoreData)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ResourceCoreData)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension LastUploadedResourceListCoreData : Identifiable {

}
