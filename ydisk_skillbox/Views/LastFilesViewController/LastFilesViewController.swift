//
//  LastFilesViewController.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 04.07.2022.
//

//convenience init() {
//self.init(entity: CoreDataManager.instanse.entityForName(entityName: "ResourceModel"), insertInto: CoreDataManager.instanse.context)
//}

import UIKit
import Network
import CoreData

class LastFilesViewController: UIViewController {
    
    private var lastUploadedResourceListModel: LastUploadedResourceListModel?
    
    private var apiManeger: ApiManagerProtocol = ApiManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackViewTable: UIStackView!
    
    private var spinner = UIActivityIndicatorView()
    
    private var isSpinnerOff = true
    
    private var isRefreshing = false
    
    private var isFirstLaunch = true
    
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
        
        chooseFromWhereLoadData()
        
        //Проверка мониторинга подключения к интернет
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
    
    
    //Обновляем содержимое экрана, после возвращения на него
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chooseFromWhereLoadData()
        tableView.reloadData()
    }
    
    //Первоначальные настройки внешнего вида
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
            print("Загружаем данные из интернета ПОСЛЕДНИЕ ФАЙЛЫ")
            loadLastUploadedResourceListModelFromApi()
        } else {
            print("Загружаем данные из кеша ПОСЛЕДНИЕ ФАЙЛЫ")
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
            print(spinner.frame.height)
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
    
    //Влючаем обновление данных таблицы если потянуть таблица вниз
    @objc private func refresh(sender: UIRefreshControl) {
        isRefreshing = true
        sender.endRefreshing()
        chooseFromWhereLoadData()
    }
    
    //Загружаем список последних добавленных файлов
    private func loadLastUploadedResourceListModelFromApi() {
        SwitchSpinner()
        apiManeger.getLastUploadedResourceList(limit: limitOfTableView, completion: { result in
            DispatchQueue.main.async { [self] in
                //Если это первый запуск то полностью качаем объект lastUploadedResourceListModel
                self.lastUploadedResourceListModel = result
                isFirstLaunch = false
                //Пробное кеширование
                saveDataToCoreData(lastUploadedResourceListModel: result!)
                SwitchSpinner()
                self.tableView.reloadData()
                isRefreshing = false
                apiManeger.isPaginating = false
            }
        })
    }
    
    //MARK: - Методы для работы с CoreData
    
    //Сохраняем данные в кеш
    private func saveDataToCoreData(lastUploadedResourceListModel: LastUploadedResourceListModel) {
        //print("Загружаем данные в кеш")
        //Предварительно очишаем кеш
        deleteDataInCoreData()
        
        let lastUploadedResourceListCoreData = LastUploadedResourceListCoreData(entity: CoreDataManager.instanse.entityForName(entityName: "LastUploadedResourceListCoreData"), insertInto: CoreDataManager.instanse.context)
        lastUploadedResourceListCoreData.limit = Int64(lastUploadedResourceListModel.limit)
        
        let arrayOfResourceModel = lastUploadedResourceListModel.items
        
        for resource in arrayOfResourceModel! {
            let objectForAdd = ModelToCoreDataConverter.share.resourceModelToCoreData(resourceModel: resource)
            lastUploadedResourceListCoreData.addToItems(objectForAdd)
            //print(objectForAdd)
        }
        
        CoreDataManager.instanse.saveContext()
    }
    
    private func loadDataFromCoreData() {
        print("Загружаем данные из кеша ПОСЛЕДНИЕ ФАЙЛЫ")
        lastUploadedResourceListModel = LastUploadedResourceListModel(items: [], limit: 0)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LastUploadedResourceListCoreData")
        fetchRequest.relationshipKeyPathsForPrefetching = ["items"]
        do {
            let results = try CoreDataManager.instanse.context.fetch(fetchRequest) as! [LastUploadedResourceListCoreData]
            var arrayOfResourceCoreData = results[0].items?.allObjects as! [ResourceCoreData]
            arrayOfResourceCoreData.sort(by: { $0.modified! > $1.modified! })
            lastUploadedResourceListModel?.items?.removeAll()
            
            for item in arrayOfResourceCoreData {
                let resourceModel = ModelToCoreDataConverter.share.resourceCoreDataToResourceModel(resourceCoreData: item)
                print("Данные из кеша ПОСЛЕДНИЕ ФАЙЛЫ", resourceModel)
                lastUploadedResourceListModel?.items?.append(resourceModel)
            }
        } catch {
            print("LastUploadedResourceListCoreData ERROR", error)
        }
        lastUploadedResourceListModel?.items?.sort(by: { $0.created! > $1.created! })
    }
    
    //Удаляем данные из CoreData
    private func deleteDataInCoreData() {
        CoreDataManager.instanse.deleteDataFromLastFiles()
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
    
    //MARK: -
    
    //Создаем новый экран для файлов
    private func makeNewScreenForFile(file: ResourсeModel, data: Data?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let screenForFile = storyboard.instantiateViewController(withIdentifier: "FileViewerController") as! FileViewerController
        screenForFile.file = file
        screenForFile.dataFile = data
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

extension LastFilesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let lastUploadedResourceListModel = lastUploadedResourceListModel else { return UITableViewCell() }
        
        if lastUploadedResourceListModel.items?[indexPath.row].type == "dir" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderCell
            cell.config(folder: lastUploadedResourceListModel.items?[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileCell
            cell.config(file: lastUploadedResourceListModel.items?[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let resource = lastUploadedResourceListModel?.items else { return }
        
        chooseFromWhereLoadDataForFile(resource: resource[indexPath.row])
        
//        apiManeger.getFolder(urlIn: (resource[indexPath.row].path)!, completion: { result in
//            guard let result = result else { return }
//            DispatchQueue.main.async {
//                self.makeNewScreenForFile(file: result)
//            }
//        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lastUploadedResourceListModel?.items?.count ?? 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

//MARK: - ScrollViewDelegate

extension LastFilesViewController: UIScrollViewDelegate {
    
    //Проверяем что таблица пролистана до нижнего края
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !apiManeger.isPaginating && NetworkMonitor.shared.isConnected {
            print("Последние файлы пагинация")
            let position = scrollView.contentOffset.y
            if position > (tableView.contentSize.height - 100) - scrollView.frame.size.height {
                lastLimitOfTableView = limitOfTableView
                limitOfTableView += 15
                chooseFromWhereLoadData()
                positionOfSpinner = 1
            }
        }
    }
}
