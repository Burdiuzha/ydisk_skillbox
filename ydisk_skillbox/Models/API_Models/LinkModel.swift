//
//  LinkModel.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

import Foundation

// MARK: - LinkModel

// Объект содержит URL для запроса метаданных ресурса.

struct LinkModel: Codable {
    let href: String
    let method: String
    let templated: Bool
}
