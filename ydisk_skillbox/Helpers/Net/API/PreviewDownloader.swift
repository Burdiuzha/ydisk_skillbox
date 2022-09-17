//
//  PreviewDownloader.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 11.07.2022.
//

import Foundation
import UIKit

protocol PreviewDownloaderProtocol {
    func getPreviewImage(urlString: String?, completition: @escaping (_ image: UIImage? ) -> Void )
}

class PreviewDownloader: PreviewDownloaderProtocol {
    
    private let storage: StorageSettingsProtocol = StorageSettings()
    
    private lazy var token = storage.loadTokenFromStorage()
    
    func getPreviewImage(urlString: String?, completition: @escaping (_ image: UIImage? ) -> Void ) {
        
        guard let urlString = urlString else { return }
        
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)

        request.httpMethod = "GET"
        request.setValue("OAuth " + token, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
               if let data = data {
                   let image = UIImage(data: data)
                   completition(image)
               } else {
                   print("error")
               }
           }
        task.resume()
    }
    
}
