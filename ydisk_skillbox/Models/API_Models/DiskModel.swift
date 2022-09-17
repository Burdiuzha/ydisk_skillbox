//
//  DiskModel.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

import Foundation

// MARK: - DiskModel

// Данные о свободном и занятом пространстве на Диске РАБОТАЕТ

struct DiskModel: Codable {
    let trashSize, totalSpace, usedSpace: Int
    let systemFolders: SystemFolders?

    enum CodingKeys: String, CodingKey {
        case trashSize = "trash_size"
        case totalSpace = "total_space"
        case usedSpace = "used_space"
        case systemFolders = "system_folders"
    }
    
    init(trashSize: Int, totalSpace: Int, usedSpace: Int, systemFolders: SystemFolders?) {
        self.trashSize = trashSize
        self.totalSpace = totalSpace
        self.usedSpace = usedSpace
        self.systemFolders = systemFolders
    }
}

// MARK: - SystemFolders
struct SystemFolders: Codable {
    let applications, downloads: String
}
