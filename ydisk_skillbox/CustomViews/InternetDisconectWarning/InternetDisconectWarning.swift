//
//  InternetDisconectWarning.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 29.07.2022.
//

import Foundation
import UIKit

protocol InternetDisconectWarningProtocol {
    func makeInternetDisconectWarningLabel() -> UILabel
}

class InternetDisconectWarning: InternetDisconectWarningProtocol {
    
    func makeInternetDisconectWarningLabel() -> UILabel {
        let label = UILabel()
        label.text = "No Internet connection"
        label.textColor = .white
        label.backgroundColor = .red
        label.textAlignment = .center
        return label
    }
    
}
