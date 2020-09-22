//
//  LoginViewController.swift
//  MyCloudDisk
//
//  Created by Roman on 15.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation
import WebKit



class LoginViewController: UIViewController, UIWebViewDelegate {
    
    weak var delegate: LoginViewControllerDelegate?

    var loginViewModel = LoginViewModel()
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self

        guard let request = loginViewModel.tokenGetRequest else { return }
        webView.load(request)
        webView.navigationDelegate = self

    }


    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
                indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                indicator.stopAnimating()
                indicator.isHidden = true
    }

}

extension LoginViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == loginViewModel.scheme {
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }

            if let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value {
                delegate?.handleTokenChanged(token: token)
            }
            dismiss(animated: true, completion: nil)
        }
        do {
            decisionHandler(.allow)
        }
    }
}
