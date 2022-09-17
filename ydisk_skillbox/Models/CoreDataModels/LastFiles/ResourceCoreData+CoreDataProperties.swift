//
//  ResourceCoreData+CoreDataProperties.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 24.08.2022.
//
//

import Foundation
import CoreData


extension ResourceCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ResourceCoreData> {
        return NSFetchRequest<ResourceCoreData>(entityName: "ResourceCoreData")
    }

    @NSManaged public var created: String?
    @NSManaged public var md5: String?
    @NSManaged public var mime_type: String?
    @NSManaged public var modified: String?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var preview: String?
    @NSManaged public var public_key: String?
    @NSManaged public var resource_id: String?
    @NSManaged public var revision: Int64
    @NSManaged public var size: Int64
    @NSManaged public var type: String?
    @NSManaged public var embedded: ResourceListCoreData?

}

extension ResourceCoreData : Identifiable {

}
