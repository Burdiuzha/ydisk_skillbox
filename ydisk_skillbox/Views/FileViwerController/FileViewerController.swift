//
//  FileViewerController.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 11.07.2022.
//

import UIKit
import PDFKit
import WebKit

class FileViewerController: UIViewController {
    
    private var linkGetter: LinkForDownloadGetterProtocol = LinkForDownloadGetter()
    
    private var fileDownloader: FileDownloaderProtocol = FileDownloader()
    
    private var apiManger: ApiManagerProtocol = ApiManager()
    
    var file: ResourсeModel? = nil
    
    var dataFile: Data? = nil
    
    private var fileToShare: Any?
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinerSizes = CGRect(x: 0, y: 0, width: 150, height: 150)
        let spinner = UIActivityIndicatorView(frame: spinerSizes)
        spinner.color = .white
        
        return spinner
    }()
    
    private var spinnerCheck = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseFromWhereLoadDataForFile()
        setupView()
        
        switchSpinner()
    }
    
    private func chooseFromWhereLoadDataForFile() {
        if NetworkMonitor.shared.isConnected {
            print("Загружаем ФАЙЛ из интернета")
            loadFileFromApi()
        } else {
            print("Загружаем ФАЙЛ из кеша")
            loadFileFromCoreData()
        }
    }
    
    private func loadFileFromApi() {
        linkGetter.getLinkForDownload(path: (file?.path)!, completion: { link in
            DispatchQueue.main.async {
                self.fileDownloader.downloadFile(link: link!.href, completion: { data in
                    DispatchQueue.main.async {
                        self.dataToFile(data: data)
                        self.switchSpinner()
                        self.saveFileToCoreData(data: data)
                    }
                })
            }
        })
    }
    
    //MARK: - Core Data methods
    
    private func loadFileFromCoreData() {
        guard let dataFile = dataFile else {
            print("Нет данных для загрузки файла")
            return
        }
        
        self.dataToFile(data: dataFile)
        switchSpinner()
        print("loadFileFromCoreData()", dataFile)
    }
    
    private func saveFileToCoreData(data: Data) {
        deleteFileByPath(path: (file?.path!)!)
        
        let fileCoreData = ModelToCoreDataConverter.share.resourceModelToFileCoreData(resource: file!, data: data)
        
        print("Данные которые сохраняются для файла", data)
        
        CoreDataManager.instanse.saveContext()
    }
    
    private func deleteFileByPath(path: String) {
        CoreDataManager.instanse.deleteFileByPath(path: path)
    }
    
    //MARK: -
    
    private func setupView() {
        mainView.contentMode = .scaleAspectFit
        shareButton.titleLabel?.text = ""
        deleteButton.titleLabel?.text = ""
    }
    
    private func switchSpinner() {
        if spinnerCheck {
            mainView.addSubview(spinner)
            spinner.center = view.center
            spinner.startAnimating()
            spinnerCheck = false
        } else {
            mainView.willRemoveSubview(spinner)
            spinner.stopAnimating()
            spinnerCheck = true
        }
    }
    
    private func dataToFile(data: Data) {
        let fileType = file?.mime_type
        
        if fileType == "image/png" || fileType == "image/jpeg" {
            let image = UIImage(data: data)
            let imageView = UIImageView()
            imageView.image = image
            // For share
            fileToShare = image
            
            mainView.addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            imageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            imageView.bottomAnchor.constraint(equalTo: self.stackView.topAnchor, constant: 0).isActive = true
            imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            
            imageView.contentMode = .scaleAspectFit
            
        } else if fileType == "application/pdf" {
            let pdfView = PDFView()
            let pdfDoc = PDFDocument(data: data)
            pdfView.document = pdfDoc
            // For share
            fileToShare = pdfDoc
            mainView.addSubview(pdfView)
            
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            
            pdfView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            pdfView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            pdfView.bottomAnchor.constraint(equalTo: self.stackView.topAnchor, constant: 0).isActive = true
            pdfView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            
            pdfView.autoScales = true
            
        } else if fileType == "application/vnd.openxmlformats-officedocument.wordprocessingml.document" || fileType == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" {
            let webView = UIWebView()
            
            var mimeType = ""
            
            webView.load(data, mimeType: fileType!, textEncodingName: "UTF-8", baseURL: Bundle.main.bundleURL)
            fileToShare = webView
            mainView.addSubview(webView)
            
            webView.translatesAutoresizingMaskIntoConstraints = false
            
            webView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            webView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            webView.bottomAnchor.constraint(equalTo: self.stackView.topAnchor, constant: 0).isActive = true
            webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        } else {
            makeAlert(message: "This file format is not supported")
        }
        
    }
    
    //MARK: - Share button
    
    @IBAction func pressShareButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Share".localized(),
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let shareLink = UIAlertAction(title: "Share link".localized(), style: .default, handler: { _ in
            print("share link")
            self.shareLink()
        })
        let shareFile = UIAlertAction(title: "Share file".localized(), style: .default, handler: { _ in
            print("share file")
            self.shareFile()
        })
        let cencel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        actionSheet.addAction(shareLink)
        actionSheet.addAction(shareFile)
        actionSheet.addAction(cencel)
        present(actionSheet, animated: true)
    }
    
    private func shareLink() {
        linkGetter.getLinkForDownload(path: (file?.path!)!, completion: { result in
            UIPasteboard.general.string = result?.href
            DispatchQueue.main.async {
                self.makeAlert(message: "Link successfully copied".localized())
            }
        })
    }
    
    private func shareFile() {
        guard let fileToShare = fileToShare else { return }
        
        let shareSheet = UIActivityViewController(activityItems: [fileToShare], applicationActivities: nil)
        
        self.present(shareSheet, animated: true)
        
    }
    
    //MARK: - Delete button
    
    @IBAction func pressDeleteButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "This image will be removed".localized(),
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete image".localized(), style: .destructive, handler: { _ in
            if NetworkMonitor.shared.isConnected {
                self.deleteFile()
            } else {
                self.makeAlert(message: "This feature is not available without internet".localized())
            }
        })
        let cencel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        actionSheet.addAction(delete)
        actionSheet.addAction(cencel)
        present(actionSheet, animated: true)
    }
    
    private func deleteFile() {
        let alertController = UIAlertController(title: "Delete a file".localized(),
                                                message: "Are you sure you want to delete the file?".localized(),
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized(),
                                         style: .cancel,
                                         handler: nil)
        let yesDeleteAction = UIAlertAction(title: "Yes, delete".localized(), style: .default, handler: { _ in
            self.apiManger.deleteFile(path: (self.file?.path)!, completiton: { response in
                if response == 204 {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.makeAlert(message: "Failed to delete file".localized())
                    }
                }
            })
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(yesDeleteAction)
        present(alertController, animated: true)
    }
    
    //MARK: - Edit button
    
    @IBAction func pressEditButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Rename".localized(),
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { textField in
            textField.text = self.file?.name
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(),
                                         style: .cancel,
                                         handler: nil)
        
        let renameAction = UIAlertAction(title: "Rename".localized(),
                                         style: .default,
                                         handler: { _ in
            //rename code
            if NetworkMonitor.shared.isConnected {
                let newName = (alertController.textFields![0] as UITextField).text
                self.apiManger.rename(path: (self.file?.path)!, newName: newName ?? "New Name") { responseStatusCode in
                    if responseStatusCode == 201 {
                        DispatchQueue.main.async {
                            self.makeAlert(message: "File renamed successfully".localized())
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.makeAlert(message: "Failed to rename file".localized())
                        }
                    }
                }
            } else {
                self.makeAlert(message: "This feature is not available without internet".localized())
            }
        })
        
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(renameAction)
        
        present(alertController, animated: true)
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
