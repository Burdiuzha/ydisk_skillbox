//
//  ViewController.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 01.07.2022.
//

import UIKit

class ViewController: UIViewController {
    
    // https://oauth.yandex.ru/authorize?response_type=token&client_id=cb42d8483a124c9db75e182702f50280
    
    // $ curl -i -H "Authorization: token AQAAAAAWXAelAAgG6oJEweX8r08TvQ6vA1Z6n2A" \ https://cloud-api.yandex.net/v1/disk/
    
    let token = "AQAAAAAWXAelAAgG6oJEweX8r08TvQ6vA1Z6n2A"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDiskInfo()

        getFilesResourceList()
    }
    
    func getDiskInfo() {
        let urlStrirng = "https://cloud-api.yandex.net/v1/disk/"
        let url = URL(string: urlStrirng)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let diskModel = try?
                JSONDecoder().decode(DiskModel.self, from: data) {
                print(diskModel)
            } else {
                print(response)
            }
        }
        task.resume()
    }
    
    func getFilesResourceList() {
        
        // curl -X GET --header 'Accept: application/json' --header 'Authorization: OAuth AQAAAAAWXAelAADLW13DLcUick8gkcEdsk8l0SA' 'https://cloud-api.yandex.net/v1/disk'
        
        // curl -X GET --header 'Accept: application/json' --header 'Authorization: OAuth AQAAAAAWXAelAADLW13DLcUick8gkcEdsk8l0SA' 'https://cloud-api.yandex.net/v1/disk/resources/files'
        
        let urlStrirng = "https://cloud-api.yandex.net/v1/disk/resources/files"
        let url = URL(string: urlStrirng)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let filesResourceListModel = try?
                JSONDecoder().decode(FilesResourceListModel.self, from: data) {
                print(filesResourceListModel)
            } else {
                print(response)
            }
        }
        task.resume()
    }
    
    
}

