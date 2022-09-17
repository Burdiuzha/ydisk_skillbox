//
//  String+Extension.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 06.09.2022.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .main,
            value: self,
            comment: self
        )
    }
}
