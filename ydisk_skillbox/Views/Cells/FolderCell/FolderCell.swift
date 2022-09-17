//
//  FolderCell.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 05.07.2022.
//

import UIKit

class FolderCell: UITableViewCell {
    
    @IBOutlet weak var folderNameLabel: UILabel!
    
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    private var public_key: String?
    
    var isItListOfPublicResourses = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(folder: ResourсeModel?) {
        if folder != nil {
            folderNameLabel.text = folder?.name
            sizeLabel.text = "--"
            let created = getDateFromObject(dataIn: (folder?.created)!)
            
            dataLabel.text = created.date
            timeLabel.text = created.time
            public_key = folder?.public_key
            //isThisFolderPublick()
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
