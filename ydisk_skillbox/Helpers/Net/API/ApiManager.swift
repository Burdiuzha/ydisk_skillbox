//
//  ApiTest.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

import Foundation

protocol ApiManagerProtocol {
    var isPaginating: Bool { get set }
    func getDiskInfo(completion: @escaping (_ result: DiskModel) -> Void)
    func getFilesResourceList(completion: @escaping (_ result: FilesResourceListModel) -> Void)
    func getLastUploadedResourceList(limit: Int, completion: @escaping (_ result: LastUploadedResourceListModel?) -> Void)
    func getAllResources(path: String, limit: Int, completion: @escaping (_ result: ResourсeModel?) -> Void)
    func getFolder(urlIn: String, completion: @escaping (_ result: ResourсeModel?) -> Void)
    func loadPublishedFilesList(completion: @escaping (_ result: PublicResourcesListModel?) -> Void)
    func rename(path: String, newName: String, completiton: @escaping (_ responseStatusCode: Int) -> Void)
    func deleteFile(path: String, completiton: @escaping (_ responseStatusCode: Int) -> Void)
    func unpublish(path: String, completiton: @escaping (_ link: LinkModel) -> Void)
}

class ApiManager: ApiManagerProtocol {
    
    //Свойство показывает используется ли сейчас АПИ для пагинации
    var isPaginating = false
    
    private let storage: StorageSettingsProtocol = StorageSettings()
    
    private lazy var token = storage.loadTokenFromStorage()
    
    func getDiskInfo(completion: @escaping (_ result: DiskModel) -> Void) {
        let urlStrirng = "https://cloud-api.yandex.net/v1/disk/"
        let url = URL(string: urlStrirng)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let diskModel = try?
                JSONDecoder().decode(DiskModel.self, from: data) {
                completion(diskModel)
                //print(diskModel)
            } else {
                print(response)
            }
        }
        task.resume()
    }
    
    func getFilesResourceList(completion: @escaping (_ result: FilesResourceListModel) -> Void) {
        
        let urlStrirng = "https://cloud-api.yandex.net/v1/disk/resources/files"
        let url = URL(string: urlStrirng)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let filesResourceListModel = try?
                JSONDecoder().decode(FilesResourceListModel.self, from: data) {
                //print(filesResourceListModel)
            } else {
                print(response)
            }
        }
        task.resume()
    }
    
    func getLastUploadedResourceList(limit: Int, completion: @escaping (_ result: LastUploadedResourceListModel?) -> Void) {
        
            self.isPaginating = true
            let urlStrirngMainPart = "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded?limit="
            let limitString = String(limit)
            let urlString = urlStrirngMainPart + limitString
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            
            request.httpMethod = "GET"
            request.setValue(token, forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let lastUploadedResourceListModel = try?
                    JSONDecoder().decode(LastUploadedResourceListModel.self, from: data) {
                    let resp: HTTPURLResponse = response! as! HTTPURLResponse
                    if resp.statusCode == 200 {
                        completion(lastUploadedResourceListModel)
                    } else {
                        print(resp.statusCode)
                    }
                    //print(resp.statusCode)
                } else {
                    print(error.debugDescription)
                }
            }
            task.resume()
    }
    
    func getAllResources(path: String, limit: Int, completion: @escaping (_ result: ResourсeModel?) -> Void) {
        //let urlStrirng = "https://cloud-api.yandex.net/v1/disk/resources?path=disk%3A%2F&limit=100"
        self.isPaginating = true
        let urlStrirngMainPart = "https://cloud-api.yandex.net/v1/disk/resources?path="
        let urlStringPath = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let limitString = String(limit)
        let urlString = urlStrirngMainPart + urlStringPath + "&limit=" + limitString
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let resourсeListModel = try?
                JSONDecoder().decode(ResourсeModel.self, from: data) {
                completion(resourсeListModel)
                //print(resourсeListModel)
            } else {
                print(response)
            }
        }
        task.resume()
    }
    
    func getFolder(urlIn: String, completion: @escaping (_ result: ResourсeModel?) -> Void) {
        let urlStrirng = "https://cloud-api.yandex.net/v1/disk/resources?path=" + urlIn.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: urlStrirng)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let resourсeListModel = try?
                JSONDecoder().decode(ResourсeModel.self, from: data) {
                completion(resourсeListModel)
                //print(resourсeListModel)
            } else {
                print("response", response)
            }
        }
        task.resume()
    }
    
    func loadPublishedFilesList(completion: @escaping (_ result: PublicResourcesListModel?) -> Void) {
        //https://cloud-api.yandex.net/v1/disk/resources/public
        
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/public"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let publishedFilesList = try?
                JSONDecoder().decode(PublicResourcesListModel.self, from: data) {
                completion(publishedFilesList)
            } else {
                print("response", response)
            }
        }
        task.resume()
    }
    
    
    // Переименовать файл
    func rename(path: String, newName: String, completiton: @escaping (_ responseStatusCode: Int) -> Void) {
        let urlStringMainPart = "https://cloud-api.yandex.net/v1/disk/resources/move?from="
        let urlStringPath = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlStringNewName = newName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let pathString = cutNameFromPath(path: path).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = urlStringMainPart + urlStringPath! + "&path=" + pathString! + urlStringNewName!
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        
        //print(urlStringMainPart + path + "&path=" + newName)
        
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let resp: HTTPURLResponse = response! as! HTTPURLResponse
                completiton(resp.statusCode)
            } else {
                print(error.debugDescription)
            }
        }
        task.resume()
        
        func cutNameFromPath(path: String) -> String {
            var pathWithoutNameReversed = String(path.reversed())
            //print(pathWithoutNameReversed)
            
            for value in pathWithoutNameReversed {
                if value != "/" {
                    //print(value)
                    pathWithoutNameReversed.remove(at: pathWithoutNameReversed.startIndex)
                } else {
                    break
                }
            }
            
            let pathWithoutName = String(pathWithoutNameReversed.reversed())
            
            return pathWithoutName
        }
    }
    
    //Удалить файл
    func deleteFile(path: String, completiton: @escaping (_ responseStatusCode: Int) -> Void) {
        let urlStringMainPart = "https://cloud-api.yandex.net/v1/disk/resources?path="
        let urlStringPath = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = urlStringMainPart + urlStringPath!
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "DELETE"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let resp: HTTPURLResponse = response! as! HTTPURLResponse
                completiton(resp.statusCode)
            } else {
                print(error.debugDescription)
            }
        }
        task.resume()
    }
    
    func unpublish(path: String, completiton: @escaping (_ link: LinkModel) -> Void) {
        let urlStringMainPart = "https://cloud-api.yandex.net/v1/disk/resources/unpublish?path="
        let urlStringPath = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = urlStringMainPart + (urlStringPath ?? "")
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "PUT"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let link = try?
                JSONDecoder().decode(LinkModel.self, from: data) {
                completiton(link)
            } else {
                print("response", response)
            }
        }
        task.resume()
    }
    
}
