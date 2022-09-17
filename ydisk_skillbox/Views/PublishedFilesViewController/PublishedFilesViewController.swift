//
//  PublishedFilesViewController.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 30.08.2022.
//

import UIKit

class PublishedFilesViewController: UIViewController {
    
    @IBOutlet var viewPlaceholder: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    private var spinner = UIActivityIndicatorView()
    
    @IBOutlet weak var updateButton: UIButton!
    
    private var tableView = UITableView()
    
    private var publishedFilesList: PublicResourcesListModel?
    
    private var apiManeger: ApiManagerProtocol = ApiManager()
    
    private var isItFirstLaunch = true
    
    private var isSpinnerOff = true
    
    private var isRefreshing = false
    
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

        // Do any additional setup after loading the view.
        
        //Проверка мониторинга подключения к интернет
        NotificationCenter.default.addObserver(self, selector: #selector(showOfflineDeviceUI(notification:)), name: NSNotification.Name.connectivityStatus, object: nil)
        
        chooseFromWhereLoadData()
        
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
    
    private func chooseFromWhereLoadData() {
        if NetworkMonitor.shared.isConnected {
            print("Загружаем данные из интернета ПУБЛИЧНЫЕ ФАЙЛЫ")
            loadPublishedFilesList()
        } else {
            print("Загружаем данные из кеша ПУБЛИЧНЫЕ ФАЙЛЫ")
            //loadDataFromCoreData()
        }
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        isRefreshing = true
        sender.endRefreshing()
        chooseFromWhereLoadData()
    }
    
    private func loadPublishedFilesList() {
        SwitchSpinner()
        apiManeger.loadPublishedFilesList(completion: { result in
            DispatchQueue.main.async {
                self.publishedFilesList = result
                //print(result?.items)
                self.isPublishedFilesListEmpty()
                self.SwitchSpinner()
                self.tableView.reloadData()
            }
        })
    }
    
    private func isPublishedFilesListEmpty() {
        if publishedFilesList == nil {
            print("isPublishedFilesListEmpty() - список пустой")
        } else {
            isItFirstLaunchForScreen()
        }
    }
    
    private func isItFirstLaunchForScreen() {
        if isItFirstLaunch {
            addTableViewInView()
            isItFirstLaunch = false
        } else {
            //ничего
        }
    }
    
    private func addTableViewInView() {
        print("addTableViewInView()")
        removeViewPlaceholderFromStackview()
        stackView.addArrangedSubview(tableView)
        //setupTableViewConstraints()
        tableViewSetup()
    }
    
    private func tableViewSetup() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: "FolderCell")
        tableView.register(UINib(nibName: "FileCell", bundle: nil), forCellReuseIdentifier: "FileCell")
        
        tableView.refreshControl = refreshControl
    }
    
    private func removeViewPlaceholderFromStackview() {
        stackView.viewWithTag(2)?.removeFromSuperview()
    }
    
    @IBAction func pressUpdateButton(_ sender: Any) {
        print("Обновить")
        chooseFromWhereLoadData()
    }
    
    //MARK: -
    
    private func SwitchSpinner() {
        if isSpinnerOff && !isRefreshing {
            stackView.insertArrangedSubview(spinner, at: positionOfSpinner)
            spinner.startAnimating()
            isSpinnerOff = false
            positionOfSpinner = 0
            print(spinner.frame.height)
        } else {
            self.stackView.removeArrangedSubview(spinner)
            self.spinner.stopAnimating()
            isSpinnerOff = true
        }
    }
    
    //Создание плашки что нет подключения к интернету
    private func makeInternetDissonectWarning() {
        if NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                //self.labelInternetConectionWarning.removeFromSuperview()
            }
        } else {
            DispatchQueue.main.async {
                //self.stackViewTable.insertArrangedSubview(self.labelInternetConectionWarning, at: 0)
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
    
    private func makeNewScreenForFile(file: ResourсeModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let screenForFile = storyboard.instantiateViewController(withIdentifier: "FileViewerController") as! FileViewerController
        screenForFile.file = file
        self.navigationController?.pushViewController(screenForFile, animated: true)
    }
    
    //MARK: -
    
    private func creatMenuRemoveFromPublished(indexPathRow: Int) {
        let name = publishedFilesList?.items?[indexPathRow].name
        let path = publishedFilesList?.items?[indexPathRow].path
        let actionSheet = UIAlertController(title: name,
                                            message: nil,
                                            preferredStyle: .actionSheet)

        let delete = UIAlertAction(title: "Remove from public",
                                 style: .destructive,
                                 handler: {_ in
            print("Удалить из публичных")
            self.createMenuForAprooveRemoveFromPublished(path: path ?? "")
        })
        let cencel = UIAlertAction(title: "Cancel", style: .cancel)

        actionSheet.addAction(delete)
        actionSheet.addAction(cencel)
        present(actionSheet, animated: true)
    }
    
    private func createMenuForAprooveRemoveFromPublished(path: String) {
        let alertController = UIAlertController(title: "Remove file from published",
                                                message: "Are you sure you want to remove the file from the published ones?",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        let yesDeleteAction = UIAlertAction(title: "Yes, delete", style: .destructive, handler: { _ in
            self.removeFromPublished(path: path)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(yesDeleteAction)
        present(alertController, animated: true)
    }
    
    private func removeFromPublished(path: String) {
        apiManeger.unpublish(path: path, completiton: { result in
            if result != nil {
                DispatchQueue.main.async {
                    print("Успешно удалено из публичных")
                    self.loadPublishedFilesList()
                }
            }
        })
    }
    
}

extension PublishedFilesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        publishedFilesList?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let publishedFilesList = publishedFilesList else { return UITableViewCell() }
        
        if publishedFilesList.items?[indexPath.row].type == "dir" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderCell
            cell.accessoryType = .detailDisclosureButton
            cell.config(folder: publishedFilesList.items?[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileCell
            cell.accessoryType = .detailDisclosureButton
            cell.config(file: publishedFilesList.items?[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let publishedFilesList = publishedFilesList else { return }
        print("didSelectRowAt")
        
        if publishedFilesList.items?[indexPath.row].type == "dir" {
            apiManeger.getFolder(urlIn: (publishedFilesList.items?[indexPath.row].path)!, completion: { result in
                guard let result = result else { return }
                DispatchQueue.main.async {
                    self.makeNewScreenForFolder(resourse: result)
                }
            })
        } else {
            apiManeger.getFolder(urlIn: (publishedFilesList.items?[indexPath.row].path)!, completion: { result in
                guard let result = result else { return }
                DispatchQueue.main.async {
                    self.makeNewScreenForFile(file: result)
                }
                //print(result)
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        creatMenuRemoveFromPublished(indexPathRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    

}
