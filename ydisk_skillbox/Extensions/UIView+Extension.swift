//
//  UIView+Extension.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 03.07.2022.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
