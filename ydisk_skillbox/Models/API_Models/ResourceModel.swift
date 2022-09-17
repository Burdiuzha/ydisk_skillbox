//
//  ResourceModel.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

import Foundation

// MARK: - ResourсeModel

// Описание ресурса, мета-информация о файле или папке. Включается в ответ на запрос метаинформации.

struct ResourсeModel : Codable {
    let public_key: String?
    var _embedded : ResourсeListModel?
    let name : String?
    let resource_id : String?
    let created : String?
    let modified : String?
    let path : String?
    let type : String?
    let mime_type: String?
    let md5: String?
    let revision : Int?
    let size: Int?
    let preview: String?

    enum CodingKeys: String, CodingKey {

        case public_key = "public_key"
        case _embedded = "_embedded"
        case name = "name"
        case resource_id = "resource_id"
        case created = "created"
        case modified = "modified"
        case path = "path"
        case type = "type"
        case mime_type = "mime_type"
        case md5 = "md5"
        case revision = "revision"
        case size = "size"
        case preview = "preview"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        public_key = try values.decodeIfPresent(String.self, forKey: .public_key)
        _embedded = try values.decodeIfPresent(ResourсeListModel.self, forKey: ._embedded)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        resource_id = try values.decodeIfPresent(String.self, forKey: .resource_id)
        created = try values.decodeIfPresent(String.self, forKey: .created)
        modified = try values.decodeIfPresent(String.self, forKey: .modified)
        path = try values.decodeIfPresent(String.self, forKey: .path)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        mime_type = try values.decodeIfPresent(String.self, forKey: .mime_type)
        md5 = try values.decodeIfPresent(String.self, forKey: .md5)
        revision = try values.decodeIfPresent(Int.self, forKey: .revision)
        size = try values.decodeIfPresent(Int.self, forKey: .size)
        preview = try values.decodeIfPresent(String.self, forKey: .preview)
    }
    
    init(public_key: String?, _embedded: ResourсeListModel?, name: String?, resource_id: String?, created: String?, modified: String?, path: String?, type: String?, mime_type: String?, md5:String?, revision: Int?, size: Int?, preview: String?) {
        self.public_key = public_key
        self._embedded = _embedded
        self.name = name
        self.resource_id = resource_id
        self.created = created
        self.modified = modified
        self.path = path
        self.type = type
        self.mime_type = mime_type
        self.md5 = md5
        self.revision = revision
        self.size = size
        self.preview = preview
    }

}
