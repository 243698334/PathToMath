//
//  PMStartGameView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/17/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

protocol PMStartGameViewDelegate: NSObjectProtocol {
    
    func didTapStartButtonInStartGameView(startGameView: PMStartGameView)
    
    func didTapLogoutButtonInStartGameView(startGameView: PMStartGameView)
}

class PMStartGameView: UIView {
    
    private let kSummaryLabelHeight = CGFloat(30)
    private let kButtonHeight = CGFloat(50)
    private let kHorizontaladding = CGFloat(40)
    private let kVerticalPadding = CGFloat(10)
    private let kSummaryLabelTopMargin = CGFloat(70)
    
    weak var delegate: PMStartGameViewDelegate?
    
    private var summaryLabel: UILabel!
    private var startButton: UIButton!
    private var logoutButton: UIButton!
    private var logoutButtonActivityIndicatorView: UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clearColor()
        
        self.summaryLabel = UILabel()
        self.summaryLabel.textAlignment = .Center
        self.summaryLabel.textColor = UIColor.whiteColor()
        self.summaryLabel.font = UIFont.systemFontOfSize(14.0)
        self.summaryLabel.text = "Loading stats..."
        self.addSubview(self.summaryLabel)
        
        self.startButton = UIButton()
        self.startButton.setTitle("start", forState: .Normal)
        self.startButton.layer.cornerRadius = 5
        self.startButton.layer.masksToBounds = true
        self.startButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        self.startButton.contentVerticalAlignment = .Center
        self.startButton.addTarget(self, action: "didTapStartButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.startButton)
        
        self.logoutButton = UIButton()
        self.logoutButton.setTitle("log out", forState: .Normal)
        self.logoutButton.layer.cornerRadius = 5
        self.logoutButton.layer.masksToBounds = true
        self.logoutButton.setBackgroundImage(UIImage(named: "ButtonBackgroundRed"), forState: .Normal)
        self.logoutButton.contentVerticalAlignment = .Center
        self.logoutButton.addTarget(self, action: "didTapLogoutButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.logoutButton)
        
        self.logoutButtonActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.summaryLabel.frame = CGRect(x: kHorizontaladding, y: kSummaryLabelTopMargin, width: self.bounds.width - 2 * kHorizontaladding, height: kSummaryLabelHeight)
        self.startButton.frame = CGRect(x: kHorizontaladding, y: CGRectGetMaxY(self.summaryLabel.frame) + kVerticalPadding, width: self.bounds.width - 2 * kHorizontaladding, height: kButtonHeight)
        self.logoutButton.frame = CGRect(x: kHorizontaladding, y: CGRectGetMaxY(self.startButton.frame) + kVerticalPadding, width: self.bounds.width - 2 * kHorizontaladding, height: kButtonHeight)
    }
    
    func startLogoutActivityIndicatorAnimation() {
        self.logoutButton.setTitle("", forState: .Normal)
        self.logoutButtonActivityIndicatorView?.frame = self.logoutButton.bounds
        self.logoutButton.addSubview(logoutButtonActivityIndicatorView!)
        self.logoutButton.userInteractionEnabled = false
        self.logoutButtonActivityIndicatorView?.startAnimating()
    }
    
    func stopLogoutActivityIndicatorAnimation() {
        self.logoutButton.setTitle("log out", forState: .Normal)
        self.logoutButtonActivityIndicatorView?.stopAnimating()
        self.logoutButtonActivityIndicatorView?.removeFromSuperview()
        self.logoutButton.userInteractionEnabled = true
    }
    
    func updateSummaryLabelWithHoursPlayed(hoursPlayed: Int, minutesPlayed: Int) {
        let hoursText = hoursPlayed == 0 ? "" : (hoursPlayed == 1 ? "\(hoursPlayed) hour " : "\(hoursPlayed) hours ")
        let minutesText = minutesPlayed == 0 ? "" : (minutesPlayed == 1 ? "\(minutesPlayed) minute " : "\(minutesPlayed) minutes ")
        if (hoursText.isEmpty && minutesText.isEmpty) {
            self.summaryLabel.text = "You haven't played Path to Math today"
        } else {
            self.summaryLabel.text = "You've played \(hoursText)\(minutesText)today"
        }
    }
    
    func didTapStartButton(button: UIButton) {
        self.delegate?.didTapStartButtonInStartGameView(self)
    }
    
    func didTapLogoutButton(button: UIButton) {
        self.delegate?.didTapLogoutButtonInStartGameView(self)
    }
    
}
