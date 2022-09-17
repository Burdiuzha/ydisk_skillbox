//
//  WebViewController.swift
//  ydisk_skillbox
//
//  Created by Евгений Бурдюжа on 26.07.2022.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var storage: StorageSettingsProtocol = StorageSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
        
        loadAuthorizationPage()
        // Do any additional setup after loading the view.
    }
    
    private func loadAuthorizationPage() {
        let urlString = "https://oauth.yandex.ru/authorize?response_type=token&client_id=cb42d8483a124c9db75e182702f50280"
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        
        webView.load(request)
    }
    
    private func loadTokenFromUrl(urlString: String) -> String {
        var token = ""
        var flag = false
        
        for value in urlString {
            if value == "=" {
                flag = true
            } else if value == "&" {
                break
            }
            if flag {
                token += String(value)
            }
        }
        
        token.remove(at: token.startIndex)
        return token
    }
    
    private func makeNewScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newScreen = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        navigationController?.pushViewController(newScreen, animated: true)
    }
    
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let urlResponse = webView.url?.absoluteString
        if urlResponse?.contains("access_token") == true {
            let token = self.loadTokenFromUrl(urlString: urlResponse!)
            storage.saveTokenToStorage(token: token)
            makeNewScreen()
        }
    }
}
