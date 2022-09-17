//
//  ResourceListModel.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

import Foundation

// MARK: - ResourсeListModel

//Список ресурсов, содержащихся в папке. Содержит объекты Resource и свойства списка.

struct ResourсeListModel : Codable {
    let sort : String?
    let public_key : String?
    var items: [ResourсeModel]?
    let path : String?
    let limit : Int?
    let offset : Int?
    let total : Int?

    enum CodingKeys: String, CodingKey {

        case sort = "sort"
        case public_key = "public_key"
        case items = "items"
        case path = "path"
        case limit = "limit"
        case offset = "offset"
        case total = "total"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sort = try values.decodeIfPresent(String.self, forKey: .sort)
        public_key = try values.decodeIfPresent(String.self, forKey: .public_key)
        items = try values.decodeIfPresent([ResourсeModel].self, forKey: .items)
        path = try values.decodeIfPresent(String.self, forKey: .path)
        limit = try values.decodeIfPresent(Int.self, forKey: .limit)
        offset = try values.decodeIfPresent(Int.self, forKey: .offset)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }
    
    init(sort: String?, public_key: String?, items: [ResourсeModel]?, path: String?, limit: Int?, offset: Int?, total: Int?) {
        self.sort = sort
        self.public_key = public_key
        self.items = items
        self.path = path
        self.limit = limit
        self.offset = offset
        self.total = total
    }

}

