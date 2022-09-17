//
//  DiskCoreData+CoreDataProperties.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 28.08.2022.
//
//

import Foundation
import CoreData


extension DiskCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiskCoreData> {
        return NSFetchRequest<DiskCoreData>(entityName: "DiskCoreData")
    }

    @NSManaged public var totalSpace: Int64
    @NSManaged public var trashSize: Int64
    @NSManaged public var usedSpace: Int64

}

extension DiskCoreData : Identifiable {

}
