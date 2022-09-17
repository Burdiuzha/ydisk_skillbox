//
//  FileDownloader.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 13.07.2022.
//

import Foundation
import UIKit

protocol FileDownloaderProtocol {
    func downloadFile(link: String, completion: @escaping(_ file: Data) -> Void)
}

class FileDownloader: FileDownloaderProtocol {
    
    func downloadFile(link: String, completion: @escaping (Data) -> Void) {
        let urlString = link
        let url = URL(string: urlString)
        let data = try? Data(contentsOf: url!)
        //print("image", image)
        completion(data ?? Data())
    }
    
}
