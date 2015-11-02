//
//  PMLegalInfoViewController.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/31/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

class PMLegalInfoViewController: UIViewController {

    private var topBarView: UIView!
    private var doneButton: UIButton!
    private var webView: UIWebView!
    private var noInternetConnectionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.topBarView = UIView()
        self.topBarView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.topBarView)
        
        self.doneButton = UIButton()
        self.doneButton.setTitle("Done", forState: .Normal)
        self.doneButton.setTitleColor(UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0), forState: .Normal)
        self.doneButton.addTarget(self, action: "didTapDoneButton:", forControlEvents: .TouchUpInside)
        self.topBarView.addSubview(self.doneButton)
        
        self.webView = UIWebView()
        self.webView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.webView)
        
        self.noInternetConnectionLabel = UILabel()
        self.noInternetConnectionLabel.textColor = UIColor.lightGrayColor()
        self.noInternetConnectionLabel.textAlignment = .Center
        self.noInternetConnectionLabel.text = "Please connect to the Internet to load this page."
        self.noInternetConnectionLabel.hidden = true
        self.view.addSubview(self.noInternetConnectionLabel)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.topBarView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        self.doneButton.frame = CGRect(x: self.topBarView.bounds.width - 80, y: 0, width: 80, height: self.topBarView.frame.height)
        self.webView.frame = CGRect(x: 0, y: CGRectGetMaxY(self.topBarView.frame), width: self.view.bounds.width, height: self.view.bounds.height - self.topBarView.frame.height)
        self.webView.multipleTouchEnabled = false
        self.noInternetConnectionLabel.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30)
        self.noInternetConnectionLabel.center = self.view.center
    }
    
    func didTapDoneButton(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadLegalInfoPageWithURLString(legalInfoPageURLString: String?) {
        if (legalInfoPageURLString == nil) {
            self.noInternetConnectionLabel.hidden = false
        } else {
            self.noInternetConnectionLabel.hidden = true
            self.webView.loadRequest(NSURLRequest(URL: NSURL(string: legalInfoPageURLString!)!))
            self.webView.multipleTouchEnabled = false
        }
    }

}
