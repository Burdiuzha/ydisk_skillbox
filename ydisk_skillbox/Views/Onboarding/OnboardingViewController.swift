//
//  OnboardingViewController.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 03.07.2022.
//

import UIKit
import WebKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                nextButton.setTitle("Start".localized(), for: .normal)
            } else {
                nextButton.setTitle("Next".localized(), for: .normal)
            }
        }
    }
    
    var slides: [OnboardingSlide] = [
        OnboardingSlide(title: "Title", description: "Now all your documents are in one place".localized(), image: UIImage(named: "Onboarding1") ?? UIImage()),
        OnboardingSlide(title: "Title", description: "Access files offline".localized(), image: UIImage(named: "Onboarding2") ?? UIImage()),
        OnboardingSlide(title: "Title", description: "Share your files with others".localized(), image: UIImage(named: "Onboarding3") ?? UIImage())
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if currentPage == slides.count - 1 {
            makeWebScreen()
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    private func makeWebScreen() {
        print("Начать")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webView = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        print(self.navigationController)
        if self.navigationController == nil {
            let navigationController = UINavigationController()
            navigationController.pushViewController(webView, animated: true)
        } else {
            self.navigationController?.pushViewController(webView, animated: true)
        }
    }
    
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage
    }
    
}

