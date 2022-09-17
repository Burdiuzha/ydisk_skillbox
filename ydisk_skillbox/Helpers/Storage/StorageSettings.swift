//
//  StorageSettings.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 26.07.2022.
//

import Foundation
import WebKit

protocol StorageSettingsProtocol {
    func saveTokenToStorage(token: String)
    func loadTokenFromStorage() -> String
    func isItFirstLaunch() -> Bool
}

class StorageSettings: StorageSettingsProtocol {
    let storageSettings = UserDefaults()
    
    func saveTokenToStorage(token: String) {
        print("save token", token)
        storageSettings.set(token, forKey: "token")
    }
    
    func loadTokenFromStorage() -> String {
        let token = storageSettings.string(forKey: "token") ?? ""
        return token
    }
    
    func isItFirstLaunch() -> Bool {
        let isItFirstLaunch = storageSettings.bool(forKey: "isItFirstLaunch")
        
        print("isItFirstLaunch", isItFirstLaunch)
        
        if isItFirstLaunch {
            //Повторный запуск
            
        } else {
            storageSettings.set(true, forKey: "isItFirstLaunch")
            // Первый запуск
        }
        
        return isItFirstLaunch
    }
    
    func exitProfile() {
        storageSettings.removeObject(forKey: "token")
        storageSettings.set(false, forKey: "isItFirstLaunch")
        WKWebView.clean()
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
        print("token after exit", storageSettings.object(forKey: "token"))
        //Добавить методы удаляющие кеш
        CoreDataManager.instanse.deleteDataFromAllFilesScreen()
        CoreDataManager.instanse.deleteDataFromLastFiles()
    }
    
}
