//
//  CoreDataManager.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 31.07.2022.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let instanse = CoreDataManager()
    
    private init() {}
    
    //Создаем контекст
    lazy var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    //Описание сущности
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Delete methods
    
    func deleteDataFromSource(source: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: source)
        do {
            let results = try CoreDataManager.instanse.context.fetch(fetchRequest)
            for result in results {
                //print("Удаляем элемент", result)
                CoreDataManager.instanse.context.delete(result as! NSManagedObject)
            }
        } catch {
            print(error)
        }
        CoreDataManager.instanse.saveContext()
    }
    
    func deleteFolderByPath(path: String) {
        print("deleteFolderByPath")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AllFileResourseList")
        fetchRequest.predicate = NSPredicate(format: "path = %@", path)
        
        do {
            let results = try CoreDataManager.instanse.context.fetch(fetchRequest)
            print("То что удаляем", results)
            for result in results {
                //print("Удаляем элемент", result)
                CoreDataManager.instanse.context.delete(result as! NSManagedObject)
            }
        } catch {
            print(error)
        }
        CoreDataManager.instanse.saveContext()
    }
    
    func deleteFileByPath(path: String) {
        
    }
    
    func deleteDataFromLastFiles() {
        deleteDataFromSource(source: "LastUploadedResourceListCoreData")
    }
    
    func deleteDataFromAllFilesScreen() {
        deleteDataFromSource(source: "AllFileResourseList")
    }
    
    func loadFolderByPath(path: String) -> AllFileResourseList? {
        print("loadFolderByPath", path)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AllFileResourseList")
        fetchRequest.predicate = NSPredicate(format: "path = %@", path)
        
        do {
            let result = try CoreDataManager.instanse.context.fetch(fetchRequest) as! [AllFileResourseList]
            if !result.isEmpty {
                if result[0] == nil {
                    //print("По запросу ничего не найдено", result)
                    return nil
                } else {
                    print("Найденный результат для запроса адреса", path, result)
                    return result[0]
                }
            } else {
                print("По запросу ничего не найдено")
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func loadFileByPath(path: String) -> FileCoreData? {
        print("loadFileByPath")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FileCoreData")
        fetchRequest.predicate = NSPredicate(format: "path = %@", path)
        
        do {
            let result = try CoreDataManager.instanse.context.fetch(fetchRequest) as! [FileCoreData]
            if !result.isEmpty {
                if result[0] == nil {
                    //print("По запросу ничего не найдено", result)
                    return nil
                } else {
                    //print("Найденный результат для запроса адреса", path, result)
                    return result[0]
                }
            } else {
                print("По запросу ничего не найдено")
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
        
    }
    
}
