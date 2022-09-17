//
//  AllResourcesViewController.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 06.07.2022.
//

import UIKit
import CoreData

class AllResourcesViewController: UIViewController {
    
    var resource: ResourсeModel?
    
    private var apiManeger: ApiManagerProtocol = ApiManager()
    
    private var linkGetter: LinkForDownloadGetterProtocol = LinkForDownloadGetter()
    
    private var fileDownloader: FileDownloaderProtocol = FileDownloader()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackViewTable: UIStackView!
    
    private var spinner = UIActivityIndicatorView()
    
    private var isSpinnerOff = true
    
    private var isRefreshing = false
    
    var isFirstLaunch = true
    
    //Определяет положение спинера. 0 - сверху таблицы, 1 - снизу
    private var positionOfSpinner = 0
    
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    private var labelInternetConectionWarning: UILabel = {
        let labelMaker = InternetDisconectWarning()
        let label = labelMaker.makeInternetDisconectWarningLabel()
        return label
    }()
    
    //Параметр для вызова АПИ показывайющий сколько элементов загружать
    private var limitOfTableView = 15
    
    //Используется для определения диапазона уже загруженных элементов
    private var lastLimitOfTableView = 0
    
    //MARK: - Func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewSetup()
        
        isItFirstLaunch()
        
        //Проверка мониторинга подключения к интернету
        NotificationCenter.default.addObserver(self, selector: #selector(showOfflineDeviceUI(notification:)), name: NSNotification.Name.connectivityStatus, object: nil)
        
        makeInternetDissonectWarning()
    }
    
    //Проверка подключения к интернету
    @objc func showOfflineDeviceUI(notification: Notification) {
        if NetworkMonitor.shared.isConnected {
            print("Connected")
        } else {
            print("Not connected")
        }
        makeInternetDissonectWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadAllResourcesFromApi()
        tableView.reloadData()
    }
    
    private func tableViewSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: "FolderCell")
        tableView.register(UINib(nibName: "FileCell", bundle: nil), forCellReuseIdentifier: "FileCell")
        
        tableView.refreshControl = refreshControl
    }
    
    //Метод определяет откуда загружаются данные
    private func chooseFromWhereLoadData() {
        if NetworkMonitor.shared.isConnected {
            print("Загружаем данные из интернета ВСЕ ФАЙЛЫ")
            loadAllResourcesFromApi()
        } else {
            print("Загружаем данные из кеша ВСЕ ФАЙЛЫ")
            loadDataFromCoreData()
        }
    }
    
    //MARK: - Spinners control
    
    private func SwitchSpinner() {
        if isSpinnerOff && !isRefreshing {
            stackViewTable.insertArrangedSubview(spinner, at: positionOfSpinner)
            spinner.startAnimating()
            isSpinnerOff = false
            positionOfSpinner = 0
        } else {
            self.stackViewTable.removeArrangedSubview(spinner)
            self.spinner.stopAnimating()
            isSpinnerOff = true
        }
    }
    
    //Создание плашки что нет подключения к интернету
    private func makeInternetDissonectWarning() {
        if NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                self.labelInternetConectionWarning.removeFromSuperview()
            }
        } else {
            DispatchQueue.main.async {
                self.stackViewTable.insertArrangedSubview(self.labelInternetConectionWarning, at: 0)
            }
        }
    }
    
    //MARK: -  Pull to refresh
    
    @objc private func refresh(sender: UIRefreshControl) {
        isRefreshing = true
        sender.endRefreshing()
        chooseFromWhereLoadData()
    }
    
    func isItFirstLaunch() {
        if isFirstLaunch {
            chooseFromWhereLoadData()
            isFirstLaunch = false
        } else {
            isFirstLaunch = true
        }
    }
    
    private func loadAllResourcesFromApi() {
        SwitchSpinner()
        apiManeger.getAllResources(path: resource?.path ?? "disk:/", limit: limitOfTableView, completion: { result in
            DispatchQueue.main.async { [self] in
                self.resource = result
                isFirstLaunch = false
                
                print("Загруженные данные из ИНТЕРНЕТА", result?.path)
                
                //Кеширование
                saveDataToCoreData(resource: result!)
                
                SwitchSpinner()
                self.tableView.reloadData()
                isRefreshing = false
                apiManeger.isPaginating = false
            }
        })
    }
    
    //MARK: - Методы для работы с CoreData
    
    private func saveDataToCoreData(resource: ResourсeModel) {
        print("Сохраняем в кеш ВСЕ ФАЙЛЫ - список исходных файлов ниже")
        deleteFolderInCoreDataByPath(path: resource.path ?? "disk:/")
        
        let allFilesResourceList = AllFileResourseList(entity: CoreDataManager.instanse.entityForName(entityName: "AllFileResourseList"), insertInto: CoreDataManager.instanse.context)
        allFilesResourceList.path = resource.path
        
        let arrayOfResourceModel = resource._embedded?.items
        
        for value in arrayOfResourceModel! {
            let objectForAdd = ModelToCoreDataConverter.share.resourceModelToCoreDataAllFiles(resourceModel: value)
            allFilesResourceList.addToItems(objectForAdd)
        }
        
        //print("Сохраняем папку в CoreData", allFilesResourceList.items)
        
        CoreDataManager.instanse.saveContext()
    }
    
    private func loadDataFromCoreData() {
        print("Загружаем данные из кеша ВСЕ ФАЙЛЫ")
        resource = ResourсeModel(public_key: nil, _embedded: nil, name: nil, resource_id: nil, created: nil, modified: nil, path: nil, type: nil, mime_type: nil, md5: nil, revision: nil, size: nil, preview: nil)
        
        resource?._embedded = ResourсeListModel(sort: nil, public_key: nil, items: [], path: nil, limit: nil, offset: nil, total: nil)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AllFileResourseList")
        fetchRequest.predicate = NSPredicate(format: "path = %@", resource?.path ?? "disk:/")
        
        do {
            let result = try CoreDataManager.instanse.context.fetch(fetchRequest) as! [AllFileResourseList]
            
            print("Загружаем данные из кеша ВСЕ ФАЙЛЫ КОНКРЕТНЫЕ ДАННЫЕ", result)
            
            if !result.isEmpty {
                var arrayOfResourceCoreData = result[0].items?.allObjects as! [ResourceCoreDataAllFiles]
                //arrayOfResourceCoreData.sorted(by: { $0.type! > $1.type! })
                resource?._embedded?.items?.removeAll()
                
                for item in arrayOfResourceCoreData {
                    let resourceModel = ModelToCoreDataConverter.share.resourceCoreDataAllFilesToResourceModel(resourceCoreData: item)
                    resource?._embedded?.items?.append(resourceModel)
                }
            }
        } catch {
            print("AllFiles ERROR", error)
        }
        
        resource?._embedded?.items?.sort { $0.name! < $1.name! }
        resource?._embedded?.items?.sort { $0.type! < $1.type! }
        
        SwitchSpinner()
    }
    
    private func deleteFolderInCoreDataByPath(path: String) {
        CoreDataManager.instanse.deleteFolderByPath(path: path)
    }
    
    
    //MARK: - Creating new screens
    
    private func chooseFromWhereLoadDataForNewFolder(resource: ResourсeModel) {
        print("Выбираем откуда загружать папку при нажатии на нее")
        if NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                self.apiManeger.getFolder(urlIn: resource.path!, completion: { result in
                    guard let result = result else { return }
                    DispatchQueue.main.async {
                        self.makeNewScreenForFolder(resourse: result)
                    }
                })
            }
        } else {
            DispatchQueue.main.async {
                print("Загружаем папку из кеша")
                //print(resource.path)
                let result = CoreDataManager.instanse.loadFolderByPath(path: resource.path ?? "disk:/")
                print(type(of: result?.items))
                //print("Результат поиска в CoreData", result)
                
                if result != nil {
                    let folder = ModelToCoreDataConverter.share.allFileResourceListToResourceModel(list: result!)
                    DispatchQueue.main.async {
                        self.makeNewScreenForFolder(resourse: folder)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.makeAlert(message: "This object is not in the cache".localized())
                    }
                }
                
            }
        }
    }
    
    private func chooseFromWhereLoadDataForFile(resource: ResourсeModel) {
        print("Выбираем откуда загружать файл при нажатии на него")
        if NetworkMonitor.shared.isConnected {
            apiManeger.getFolder(urlIn: resource.path!, completion: { result in
                guard let result = result else { return }
                DispatchQueue.main.async {
                    self.makeNewScreenForFile(file: result, data: nil)
                }
            })
        } else {
            DispatchQueue.main.async {
                let resultCoreData = CoreDataManager.instanse.loadFileByPath(path: resource.path!)
                guard let resultCoreData = resultCoreData else {
                    DispatchQueue.main.async {
                        self.makeAlert(message: "This object is not in the cache".localized())
                    }
                    return
                }
                print("Данные для файла в контроллере ВСЕ ФАЙЛЫ", resultCoreData.fileObject)
                let result = ModelToCoreDataConverter.share.fileCoreDataToResourceModel(file: resultCoreData)
                self.makeNewScreenForFile(file: result, data: resultCoreData.fileObject! as Data)
            }
            
        }
    }
    
    private func makeNewScreenForFolder(resourse: ResourсeModel) {
        //print(resourse)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let screenForFolder = storyboard.instantiateViewController(withIdentifier: "AllResourcesViewController") as! AllResourcesViewController
        screenForFolder.resource = resourse
        screenForFolder.isFirstLaunch = false
        screenForFolder.navigationItem.title = resourse.name
        self.navigationController?.pushViewController(screenForFolder, animated: true)
    }
    
    private func makeNewScreenForFile(file: ResourсeModel, data: Data?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let screenForFile = storyboard.instantiateViewController(withIdentifier: "FileViewerController") as! FileViewerController
        screenForFile.file = file
        screenForFile.dataFile = data
        print("Данные для загрузки файла", data)
        self.navigationController?.pushViewController(screenForFile, animated: true)
    }
    
    //MARK: - Make alert
    
    private func makeAlert(message: String) {
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(),
                                     style: .default,
                                     handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
}

// MARK: - Table VIew Delegate,  Table View Data Source

extension AllResourcesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let resource = resource else { return UITableViewCell() }
        
        if resource._embedded?.items?[indexPath.row].type == "dir" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderCell
            cell.config(folder: resource._embedded?.items?[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileCell
            cell.config(file: resource._embedded?.items?[indexPath.row])
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Нажатие на ячейку")
        guard let resource = resource else { return }
        
        if resource._embedded?.items?[indexPath.row].type == "dir" {
            chooseFromWhereLoadDataForNewFolder(resource: (resource._embedded?.items?[indexPath.row])!)
        } else {
            
            chooseFromWhereLoadDataForFile(resource: (resource._embedded?.items?[indexPath.row])!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resource?._embedded?.items?.count ?? 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

extension AllResourcesViewController: UIScrollViewDelegate {
    
    //Проверяем что таблица пролистана до нижнего края
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !apiManeger.isPaginating && NetworkMonitor.shared.isConnected {
            let position = scrollView.contentOffset.y
            if position > (tableView.contentSize.height - 100) - scrollView.frame.size.height {
                lastLimitOfTableView = limitOfTableView
                limitOfTableView += 15
                print(apiManeger.isPaginating)
                print(limitOfTableView)
                chooseFromWhereLoadData()
                positionOfSpinner = 1
            }
        }
    }
}
