//
//  PublicResourcesListModel.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

import Foundation

// MARK: - PublicResourcesListModel

// Список опубликованных файлов на Диске.

//struct PublicResourcesListModel: Codable {
//    let items: [ResourсeModel]
//    let type: String
//    let limit, offset: Int
//}

struct PublicResourcesListModel : Codable {
    let items : [ResourсeModel]?
    let type : String?
    let limit : Int?
    let offset : Int?

    enum CodingKeys: String, CodingKey {

        case items = "items"
        case type = "type"
        case limit = "limit"
        case offset = "offset"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decodeIfPresent([ResourсeModel].self, forKey: .items)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        limit = try values.decodeIfPresent(Int.self, forKey: .limit)
        offset = try values.decodeIfPresent(Int.self, forKey: .offset)
    }

}
