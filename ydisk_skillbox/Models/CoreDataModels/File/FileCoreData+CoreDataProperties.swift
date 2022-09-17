//
//  FileCoreData+CoreDataProperties.swift
//  
//
//  Created by Евгений Бурдюжа on 09.09.2022.
//
//

import Foundation
import CoreData


extension FileCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileCoreData> {
        return NSFetchRequest<FileCoreData>(entityName: "FileCoreData")
    }

    @NSManaged public var created: String?
    @NSManaged public var fileObject: Data?
    @NSManaged public var md5: String?
    @NSManaged public var mimi_type: String?
    @NSManaged public var modified: String?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var preview: String?
    @NSManaged public var publick_key: String?
    @NSManaged public var resource_id: String?
    @NSManaged public var revision: Int64
    @NSManaged public var size: Int64
    @NSManaged public var type: String?

}
