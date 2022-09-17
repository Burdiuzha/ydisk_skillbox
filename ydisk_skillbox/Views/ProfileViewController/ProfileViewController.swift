//
//  ProfileViewController.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 05.07.2022.
//

import UIKit
import CoreData
import Charts

class ProfileViewController: UIViewController, ChartViewDelegate {
    
    private var diskModel: DiskModel?
    
    private var apiTest: ApiManagerProtocol = ApiManager()
    
    private var storageSetinngs = StorageSettings()
    
    @IBOutlet weak var usedSpaceLabel: UILabel!
    
    @IBOutlet weak var totalSpaceLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var sharedFilesButton: UIButton!
    
    @IBOutlet weak var profileMenu: UIBarButtonItem!
    
    @IBOutlet weak var stackViewWithDiagram: UIStackView!
    
    private var pieChart = PieChartView()
    
    private var labelInternetConectionWarning: UILabel = {
        let labelMaker = InternetDisconectWarning()
        let label = labelMaker.makeInternetDisconectWarningLabel()
        return label
    }()
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Проверка мониторинга подключения к интернету
        NotificationCenter.default.addObserver(self, selector: #selector(showOfflineDeviceUI(notification:)), name: NSNotification.Name.connectivityStatus, object: nil)
        
        pieChart.delegate = self
        
        chooseFromWhereLoadData()
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
            print("Загружаем данные из интернета ПРОФИЛЬ")
            loadDiskInfoFromApi()
        } else {
            print("Загружаем данные из кеша ПРОФИЛЬ")
            loadDataFromCoreData()
        }
    }
    
    private func loadDiskInfoFromApi() {
        apiTest.getDiskInfo(completion: { result in
            DispatchQueue.main.async {
                self.diskModel = result
                self.setupView(diskModel: self.diskModel)
                self.saveDataToCoreData()
                self.addCircleGraphAtView()
            }
        })
    }
    
    //MARK: - Core Data methods
    
    private func saveDataToCoreData() {
        print("Сохраняем в кеш Профиль")
        deleteDataInCoreData(source: "DiskCoreData")
        
        let diskCoreData = DiskCoreData(entity: CoreDataManager.instanse.entityForName(entityName: "DiskCoreData"), insertInto: CoreDataManager.instanse.context)
        diskCoreData.totalSpace = Int64(diskModel?.totalSpace ?? 0)
        diskCoreData.trashSize = Int64(diskModel?.trashSize ?? 0)
        diskCoreData.usedSpace = Int64(diskModel?.usedSpace ?? 0)
        
        CoreDataManager.instanse.saveContext()
    }
    
    private func loadDataFromCoreData() {
        print("Загружаем данные из кеша Профиль")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DiskCoreData")
        
        do {
            let result = try CoreDataManager.instanse.context.fetch(fetchRequest) as! [DiskCoreData]
            if !result.isEmpty {
                diskModel = ModelToCoreDataConverter.share.diskCoreDataToDiskModel(diskInfo: result[0])
                setupView(diskModel: diskModel)
                self.addCircleGraphAtView()
            }
        } catch {
            print(error)
        }
    }
    
    private func deleteDataInCoreData(source: String) {
        CoreDataManager.instanse.deleteDataFromSource(source: source)
    }
    
    //MARK: - Views
    
    private func setupView(diskModel: DiskModel?) {
        if diskModel != nil {
            
            
            let freeSpase = diskModel!.totalSpace - diskModel!.usedSpace
            let freeSpaceDouble: Double = Double(freeSpase)/(1024*1024*1024)
            let usedSpaceDoble: Double = Double(diskModel!.usedSpace)/(1024*1024*1024)
            
            totalSpaceLabel.text = String(format: "%.2F", freeSpaceDouble) + " GB - free".localized()
            usedSpaceLabel.text = String(format: "%.2F", usedSpaceDoble) + " GB - busy".localized()
            
            
            print(freeSpaceDouble, usedSpaceDoble)
            
        } else {
            print("Данные не получены")
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
                self.stackView.insertArrangedSubview(self.labelInternetConectionWarning, at: 0)
            }
        }
    }
    
    //MARK: - Buttons actions
    
    @IBAction func pressSharedFilesButton(_ sender: Any) {
        print("pressSharedFilesButton")
        makePublishedFilesScreen()
    }
    
    @IBAction func pressProfileMenuButton(_ sender: Any) {
        print("pressProfileMenuButton")
        createProfileMenu()
    }
    
    //MARK: - Proflie Menu
    
    private func createProfileMenu() {
        let actionSheet = UIAlertController(title: "Exit".localized(),
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let exit = UIAlertAction(title: "Exit profile".localized(),
                                 style: .destructive,
                                 handler: {_ in
            print("Выйти из профиля")
            self.createExitAlert()
        })
        let cencel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        
        actionSheet.addAction(exit)
        actionSheet.addAction(cencel)
        present(actionSheet, animated: true)
    }
    
    private func createExitAlert() {
        let alertController = UIAlertController(title: "Exit profile".localized(),
                                                message: "Are you sure you want to log out of your profile?".localized(),
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes".localized(), style: .destructive, handler: {_ in
            self.exitProfile()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(),
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func exitProfile() {
        storageSetinngs.exitProfile()
        makeOnbordingScreenAfterExit()
        //Добавить методы удаляющие кеш
    }
    
    private func makeOnbordingScreenAfterExit() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let onboardingScreen = storyboard.instantiateViewController(withIdentifier: "Onboarding")
        
        let lastScreen =  self.navigationController?.viewControllers.count
        print("Количество экранов всего", lastScreen)
        //self.navigationController?.viewControllers.remove(at: lastScreen! - 2)
        //self.present(onboardingScreen, animated: true, completion: nil)
        self.navigationController?.pushViewController(onboardingScreen, animated: true)
        
    }
    
    //MARK: -
    
    private func makePublishedFilesScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let publishedFilesScreen = storyboard.instantiateViewController(withIdentifier: "PublishedFilesViewController") as! PublishedFilesViewController
        self.navigationController?.pushViewController(publishedFilesScreen, animated: true)
    }
    
    //MARK: - Circle Graph
    
    public func addCircleGraphAtView() {
        print("addCircleGraphAtView()")
        pieChart.frame = CGRect(x: 0,
                                y: 0,
                                width: 210,
                                height: 210)
        pieChart.center = stackViewWithDiagram.center
        
        var entries = [ChartDataEntry]()

        let freeSpace = diskModel!.totalSpace - diskModel!.usedSpace
        
        entries.append(ChartDataEntry(x: Double(freeSpace),
                                      y: Double(freeSpace)))
        entries.append(ChartDataEntry(x: Double(diskModel!.usedSpace),
                                      y: Double(diskModel!.usedSpace)))
        
        let set = PieChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.joyful()
        let data = PieChartData(dataSet: set)
        pieChart.data = data
        pieChart.centerText = String(Int(diskModel!.totalSpace)/(1024*1024*1024)) + " Gb"
        pieChart.data?.setDrawValues(false)
        pieChart.legend.enabled = false
        stackViewWithDiagram.addArrangedSubview(pieChart)
    }
    
}
