//
//  LastUploadedResourceListModel.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

import Foundation

// MARK: - LastUploadedResourceListModel

// Список последних добавленных на Диск файлов, отсортированных по дате загрузки (от поздних к ранним).

struct LastUploadedResourceListModel: Codable {
    var items: [ResourсeModel]?
    let limit: Int
}
