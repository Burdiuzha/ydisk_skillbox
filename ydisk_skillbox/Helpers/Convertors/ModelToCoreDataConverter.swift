//
//  ModelToCoreDataConverter.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 01.08.2022.
//

import Foundation

class ModelToCoreDataConverter {
    
    static let share = ModelToCoreDataConverter()
    
    func resourceModelToCoreData(resourceModel: ResourсeModel) -> ResourceCoreData {
        let resourceCoreData = ResourceCoreData(entity: CoreDataManager.instanse.entityForName(entityName: "ResourceCoreData"), insertInto: CoreDataManager.instanse.context)
        resourceCoreData.public_key = resourceModel.public_key
        //embedded
        resourceCoreData.embedded = ModelToCoreDataConverter.share.resourceListModelToResourseListCoreData(resourceList: resourceModel._embedded ?? nil)
        resourceCoreData.name = resourceModel.name
        resourceCoreData.resource_id = resourceModel.resource_id
        resourceCoreData.created = resourceModel.created
        resourceCoreData.modified = resourceModel.modified
        resourceCoreData.path = resourceModel.path
        resourceCoreData.type = resourceModel.type
        resourceCoreData.mime_type = resourceModel.mime_type
        resourceCoreData.md5 = resourceModel.md5
        resourceCoreData.revision = Int64(resourceModel.revision ?? 00)
        resourceCoreData.size = Int64(resourceModel.size ?? 0)
        resourceCoreData.preview = resourceModel.preview
        
        return resourceCoreData
    }
    
    func resourceModelToCoreDataAllFiles(resourceModel: ResourсeModel) -> ResourceCoreDataAllFiles {
        let resourceCoreData = ResourceCoreDataAllFiles(entity: CoreDataManager.instanse.entityForName(entityName: "ResourceCoreDataAllFiles"), insertInto: CoreDataManager.instanse.context)
        resourceCoreData.public_key = resourceModel.public_key
        //embedded
        resourceCoreData.name = resourceModel.name
        resourceCoreData.resource_id = resourceModel.resource_id
        resourceCoreData.created = resourceModel.created
        resourceCoreData.modified = resourceModel.modified
        resourceCoreData.path = resourceModel.path
        resourceCoreData.type = resourceModel.type
        resourceCoreData.mime_type = resourceModel.mime_type
        resourceCoreData.md5 = resourceModel.md5
        resourceCoreData.revision = Int64(resourceModel.revision ?? 00)
        resourceCoreData.size = Int64(resourceModel.size ?? 0)
        resourceCoreData.preview = resourceModel.preview
        
        return resourceCoreData
    }
    
    func resourceListModelToResourseListCoreData(resourceList: ResourсeListModel?) -> ResourceListCoreData {
        let resourceListCoreData = ResourceListCoreData(entity: CoreDataManager.instanse.entityForName(entityName: "ResourceListCoreData"), insertInto: CoreDataManager.instanse.context)
        resourceListCoreData.sort = resourceList?.sort ?? nil
        resourceListCoreData.public_key = resourceList?.public_key ?? nil
        
        //items
        
        resourceListCoreData.path = resourceList?.path ?? nil
        //resourceListCoreData.limit = Int64((resourceList?.limit!))
        //resourceListCoreData.offset = Int64(resourceList?.offset!) ?? nil
        //resourceListCoreData.total = Int64(resourceList?.total!) ?? nil
        
        return resourceListCoreData
    }
    
    func resourceCoreDataToResourceModel(resourceCoreData: ResourceCoreData) -> ResourсeModel {
        let resourceModel = ResourсeModel(
            public_key: resourceCoreData.public_key,
            _embedded: nil,
            name: resourceCoreData.name,
            resource_id: resourceCoreData.resource_id,
            created: resourceCoreData.created,
            modified: resourceCoreData.modified,
            path: resourceCoreData.path,
            type: resourceCoreData.type,
            mime_type: resourceCoreData.mime_type,
            md5: resourceCoreData.md5,
            revision: Int(resourceCoreData.revision),
            size: Int(resourceCoreData.size),
            preview: resourceCoreData.preview
        )
        
        return resourceModel
    }
    
    func resourceCoreDataAllFilesToResourceModel(resourceCoreData: ResourceCoreDataAllFiles) -> ResourсeModel {
        let resourceModel = ResourсeModel(
            public_key: resourceCoreData.public_key,
            _embedded: nil,
            name: resourceCoreData.name,
            resource_id: resourceCoreData.resource_id,
            created: resourceCoreData.created,
            modified: resourceCoreData.modified,
            path: resourceCoreData.path,
            type: resourceCoreData.type,
            mime_type: resourceCoreData.mime_type,
            md5: resourceCoreData.md5,
            revision: Int(resourceCoreData.revision),
            size: Int(resourceCoreData.size),
            preview: resourceCoreData.preview
        )
        
        //print(resourceModel)
        return resourceModel
    }
    
    func resourceListCoreDataToResourceListModel(resourceListCoreData: ResourceListCoreData) -> ResourсeListModel {
        
        let resourceListModel = ResourсeListModel(
            sort: resourceListCoreData.sort,
            public_key: resourceListCoreData.sort,
            items: nil,
            path: resourceListCoreData.path,
            limit: Int(resourceListCoreData.limit),
            offset: Int(resourceListCoreData.offset),
            total: Int(resourceListCoreData.total)
        )
        
        return resourceListModel
    }
    
    func allFileResourceListToResourceModel(list: AllFileResourseList) -> ResourсeModel {
        var arrayOfResource = [ResourсeModel]()
        
        for value in list.items! {
            print(list.items)
            let resource = ModelToCoreDataConverter.share.resourceCoreDataAllFilesToResourceModel(resourceCoreData: value as! ResourceCoreDataAllFiles)
            arrayOfResource.append(resource)
        }
        
        let embedded = ResourсeListModel(sort: nil, public_key: nil, items: arrayOfResource, path: nil, limit: nil, offset: nil, total: nil)
        
        let resource = ResourсeModel(public_key: nil, _embedded: embedded, name: nil, resource_id: nil, created: nil, modified: nil, path: list.path, type: "dir", mime_type: nil, md5: nil, revision: nil, size: nil, preview: nil)
        
        return resource
    }
    
    func diskCoreDataToDiskModel(diskInfo: DiskCoreData) -> DiskModel {
        let diskModel = DiskModel(trashSize: Int(diskInfo.trashSize),
                                  totalSpace: Int(diskInfo.totalSpace),
                                  usedSpace: Int(diskInfo.usedSpace),
                                  systemFolders: nil)
        
        return diskModel
    }
    
    func diskModelToDiskCoreData(diskInfo: DiskModel) -> DiskCoreData {
        let diskCoreData = DiskCoreData(entity: CoreDataManager.instanse.entityForName(entityName: "ProfileCoreData"), insertInto: CoreDataManager.instanse.context)
        diskCoreData.usedSpace = Int64(diskInfo.usedSpace)
        diskCoreData.totalSpace = Int64(diskInfo.totalSpace)
        diskCoreData.trashSize = Int64(diskInfo.totalSpace)
        
        return diskCoreData
    }
    
    func resourceModelToFileCoreData(resource: ResourсeModel, data: Data) -> FileCoreData {
        let fileCoreData = FileCoreData(entity: CoreDataManager.instanse.entityForName(entityName: "FileCoreData"), insertInto: CoreDataManager.instanse.context)
        
        fileCoreData.md5 = resource.md5
        fileCoreData.path = resource.path
        fileCoreData.type = resource.type
        fileCoreData.name = resource.name
        fileCoreData.size = Int64(resource.size!)
        fileCoreData.created = resource.created
        fileCoreData.mimi_type = resource.mime_type
        fileCoreData.preview = resource.preview
        fileCoreData.publick_key = resource.public_key
        fileCoreData.resource_id = resource.resource_id
        fileCoreData.revision = Int64(resource.revision!)
        fileCoreData.fileObject = data
        
        return fileCoreData
    }
    
    func fileCoreDataToResourceModel(file: FileCoreData) -> ResourсeModel {
        let resourceModel = ResourсeModel(
            public_key: file.publick_key,
            _embedded: nil,
            name: file.name,
            resource_id: file.resource_id,
            created: file.created,
            modified: file.modified,
            path: file.path,
            type: file.type,
            mime_type: file.mimi_type,
            md5: file.md5,
            revision: Int(file.revision),
            size: Int(file.size),
            preview: file.preview
        )
        
        return resourceModel
    }

}
