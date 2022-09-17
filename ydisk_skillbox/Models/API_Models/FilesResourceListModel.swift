//
//  FilesResourceListModel.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

import Foundation


// MARK: - FilesResourceListModel

// Плоский список всех файлов на Диске в алфавитном порядке. РАБОТАЕТ

struct FilesResourceListModel : Codable {
    let items : [ResourсeModel]?
    let limit : Int?
    let offset : Int?

    enum CodingKeys: String, CodingKey {

        case items = "items"
        case limit = "limit"
        case offset = "offset"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decodeIfPresent([ResourсeModel].self, forKey: .items)
        limit = try values.decodeIfPresent(Int.self, forKey: .limit)
        offset = try values.decodeIfPresent(Int.self, forKey: .offset)
    }

}





