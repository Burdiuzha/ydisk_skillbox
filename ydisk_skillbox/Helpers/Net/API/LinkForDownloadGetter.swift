//
//  LinkForDownloadGetter.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 20.07.2022.
//

import Foundation

protocol LinkForDownloadGetterProtocol {
    func getLinkForDownload(path: String, completion: @escaping(_ link: LinkModel?) -> Void
)}

class LinkForDownloadGetter: LinkForDownloadGetterProtocol {
    
    //let token = "AQAAAAAWXAelAAgG6oJEweX8r08TvQ6vA1Z6n2A"
    
    // Токен для BurdiuzhaTest
    //let token = "AQAAAABimw_7AAgG6o9Hg6bIcUvhsEbRmjI6TS4"
    
    private let storage: StorageSettingsProtocol = StorageSettings()
    
    private lazy var token = storage.loadTokenFromStorage()
    
    func getLinkForDownload(path: String, completion: @escaping(_ link: LinkModel?) -> Void) {
        let urlMain = "https://cloud-api.yandex.net/v1/disk/resources/download?path="
        let urlPath = path
        let urlPathEncoding = urlPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let urlString = urlMain + urlPathEncoding!
        //print(urlString)
        
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let link = try?
                JSONDecoder().decode(LinkModel.self, from: data) {
                completion(link)
                //print(link)
            } else {
                print(response)
            }
        }
        task.resume()
    }
    
}
