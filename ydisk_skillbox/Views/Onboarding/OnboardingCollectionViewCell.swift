//
//  OnboardingCollectionViewCell.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 03.07.2022.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    @IBOutlet weak var slideImageView: UIImageView!
    
    @IBOutlet weak var slideTitleLabel: UILabel!
    
    @IBOutlet weak var slideDescriptionLabel: UILabel!
    
    func setup(_ slide: OnboardingSlide) {
        slideImageView.image = slide.image
        //slideTitleLabel.text = slide.title
        slideDescriptionLabel.text = slide.description
    }
}
