//
//  FileCell.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 05.07.2022.
//

import UIKit

class FileCell: UITableViewCell {
    
    @IBOutlet weak var fileImage: UIImageView!
    
    @IBOutlet weak var fileNameLabel: UILabel!
    
    @IBOutlet weak var fileSizeLabel: UILabel!
    
    @IBOutlet weak var fileDataLabel: UILabel!
    
    @IBOutlet weak var fileTimeLabel: UILabel!
    
    private let previewDownloader: PreviewDownloaderProtocol = PreviewDownloader()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(file: ResourсeModel?) {
        if file != nil {
            fileNameLabel.text = file?.name
            fileSizeLabel.text = String((file?.size ?? 0) / 1024) + " Кб"
            let created = getDateFromObject(dataIn: (file?.created)!)
            
            fileDataLabel.text = created.date
            fileTimeLabel.text = created.time
        
            loadPreview(url: file?.preview)
        }
    }
    
    private func loadPreview(url: String?) {
        
        if url != nil {
            previewDownloader.getPreviewImage(urlString: url, completition: { image in
                DispatchQueue.main.async {
                    self.fileImage.image = image
                }
            })
        } else {
            fileImage.image = UIImage(named: "FileIcon")
        }
        
    }
    
    private func getDateFromObject(dataIn: String) -> (date: String, time: String) {
        let isoFormatter = ISO8601DateFormatter()

        let someIsoDate = isoFormatter.date(from: dataIn)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"

        let date = formatter.string(from: someIsoDate!)

        formatter.dateFormat = "HH:mm"

        let time = formatter.string(from: someIsoDate!)
        
        return (date: date, time: time)
    }
    
}
