//
//  PMSideMenuView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/15/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

protocol PMSideMenuViewDataSource: NSObjectProtocol {
    
    func gameModeInCurrentSessionInSideMenuView(sideMenuView: PMSideMenuView) -> String
    
    func problemIndexInCurrentSessionInSideMenuView(sideMenuView: PMSideMenuView) -> Int
    
    func totalNumberOfProblemsInCurrentSessionInSideMenuView(sideMenuView: PMSideMenuView) -> Int
    
    func currentUserDisplayNameInSideMenuView(sideMenuView: PMSideMenuView) -> String
    
    func currentUserAgeInSideMenuView(sideMenuView: PMSideMenuView) -> Int
    
    func currentUserIsGuestInSideMenuView(sideMenuView: PMSideMenuView) -> Bool
}

protocol PMSideMenuViewDelegate: NSObjectProtocol {
        
    func didTapRestartSessionButtonInSideMenuView(sideMenuView: PMSideMenuView)
    
    func didTapMainMenuButtonInSideMenuView(sideMenuView: PMSideMenuView)
}

class PMSideMenuView: UIView {
    
    private let kTitleLabelHeight = CGFloat(20)
    private let kValueLabelHeight = CGFloat(30)
    
    weak var dataSource: PMSideMenuViewDataSource?
    weak var delegate: PMSideMenuViewDelegate?
    
    private var backgroundBlurVisualEffectView: UIVisualEffectView!
    
    private var restartSessionButton: UIButton!
    private var mainMenuButton: UIButton!
    
    private var timePlayedView: UIView!
    private var timePlayedTitleLabel: UILabel!
    private var timePlayedLabel: UILabel!
    
    private var gameModeView: UIView!
    private var gameModeTitleLabel: UILabel!
    private var gameModeLabel: UILabel!
    
    private var sessionProgressView: UIView!
    private var sessionProgressTitleLabel: UILabel!
    private var sessionProgressLabel: UILabel!
    
    private var userInfoView: UIView!
    private var userInfoDisplayNameTitleLabel: UILabel!
    private var userInfoDisplayNameLabel: UILabel!
    private var userInfoAgeTitleLabel: UILabel!
    private var userInfoAgeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        self.backgroundBlurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        self.addSubview(self.backgroundBlurVisualEffectView)
        
        self.timePlayedView = UIView()
        self.addSubview(self.timePlayedView)
        
        self.timePlayedTitleLabel = UILabel()
        self.timePlayedTitleLabel.textColor = UIColor.whiteColor()
        self.timePlayedTitleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        self.timePlayedTitleLabel.text = "time played today"
        self.timePlayedView.addSubview(self.timePlayedTitleLabel)
        
        self.timePlayedLabel = UILabel()
        self.timePlayedLabel.textColor = UIColor.whiteColor()
        self.timePlayedLabel.font = UIFont.systemFontOfSize(24.0)
        self.timePlayedLabel.text = "loading..."
        self.timePlayedView.addSubview(self.timePlayedLabel)
        
        self.gameModeView = UIView()
        self.addSubview(self.gameModeView)
        
        self.gameModeTitleLabel = UILabel()
        self.gameModeTitleLabel.textColor = UIColor.whiteColor()
        self.gameModeTitleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        self.gameModeTitleLabel.text = "game mode"
        self.gameModeView.addSubview(self.gameModeTitleLabel)
        
        self.gameModeLabel = UILabel()
        self.gameModeLabel.textColor = UIColor.whiteColor()
        self.gameModeLabel.font = UIFont.systemFontOfSize(24.0)
        self.gameModeView.addSubview(self.gameModeLabel)
        
        self.sessionProgressView = UIView()
        self.addSubview(self.sessionProgressView)
        
        self.sessionProgressTitleLabel = UILabel()
        self.sessionProgressTitleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        self.sessionProgressTitleLabel.textColor = UIColor.whiteColor()
        self.sessionProgressTitleLabel.text = "session progress"
        self.sessionProgressView.addSubview(self.sessionProgressTitleLabel)
        
        self.sessionProgressLabel = UILabel()
        self.sessionProgressLabel.textColor = UIColor.whiteColor()
        self.sessionProgressLabel.font = UIFont.systemFontOfSize(24.0)
        self.sessionProgressView.addSubview(self.sessionProgressLabel)

        self.userInfoView = UIView()
        self.addSubview(self.userInfoView)
        
        self.userInfoDisplayNameTitleLabel = UILabel()
        self.userInfoDisplayNameTitleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        self.userInfoDisplayNameTitleLabel.textColor = UIColor.whiteColor()
        self.userInfoDisplayNameTitleLabel.text = "name"
        self.userInfoView.addSubview(self.userInfoDisplayNameTitleLabel)
        
        self.userInfoDisplayNameLabel = UILabel()
        self.userInfoDisplayNameLabel.textColor = UIColor.whiteColor()
        self.userInfoDisplayNameLabel.font = UIFont.systemFontOfSize(24.0)
        self.userInfoView.addSubview(self.userInfoDisplayNameLabel)

        self.userInfoAgeTitleLabel = UILabel()
        self.userInfoAgeTitleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        self.userInfoAgeTitleLabel.textColor = UIColor.whiteColor()
        self.userInfoAgeTitleLabel.text = "age"
        self.userInfoView.addSubview(self.userInfoAgeTitleLabel)

        self.userInfoAgeLabel = UILabel()
        self.userInfoAgeLabel.textColor = UIColor.whiteColor()
        self.userInfoAgeLabel.font = UIFont.systemFontOfSize(24.0)
        self.userInfoView.addSubview(self.userInfoAgeLabel)
        
        self.restartSessionButton = UIButton()
        self.restartSessionButton.contentVerticalAlignment = .Center
        self.restartSessionButton.layer.cornerRadius = 5
        self.restartSessionButton.layer.masksToBounds = true
        self.restartSessionButton.setBackgroundImage(UIImage(named: "ButtonBackgroundOrange"), forState: .Normal)
        self.restartSessionButton.setTitle("restart session", forState: .Normal)
        self.restartSessionButton.addTarget(self, action: "didTapRestartSessionButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.restartSessionButton)
        
        self.mainMenuButton = UIButton()
        self.mainMenuButton.contentVerticalAlignment = .Center
        self.mainMenuButton.layer.cornerRadius = 5
        self.mainMenuButton.layer.masksToBounds = true
        self.mainMenuButton.setBackgroundImage(UIImage(named: "ButtonBackgroundRed"), forState: .Normal)
        self.mainMenuButton.setTitle("main menu", forState: .Normal)
        self.mainMenuButton.addTarget(self, action: "didTapMainMenuButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.mainMenuButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundBlurVisualEffectView.frame = self.bounds
        
        self.timePlayedView.frame = CGRect(x: 40, y: 150, width: 176, height: (kTitleLabelHeight + kValueLabelHeight))
        self.timePlayedTitleLabel.frame = CGRect(x: self.timePlayedView.bounds.origin.x, y: self.timePlayedView.bounds.origin.y, width: self.timePlayedView.bounds.width, height: kTitleLabelHeight)
        self.timePlayedLabel.frame = CGRect(x: self.timePlayedView.bounds.origin.x, y: CGRectGetMaxY(self.timePlayedTitleLabel.frame), width: self.timePlayedView.bounds.width, height: kValueLabelHeight)
        if (self.dataSource?.currentUserIsGuestInSideMenuView(self) == true) {
            self.timePlayedView.hidden = true
        }
        
        self.gameModeView.frame = CGRect(x: 40, y: CGRectGetMaxY(self.timePlayedView.frame) + 20, width: 176, height: (kTitleLabelHeight + kValueLabelHeight))
        self.gameModeTitleLabel.frame = CGRect(x: self.gameModeView.bounds.origin.x, y: self.gameModeView.bounds.origin.y, width: self.gameModeView.bounds.width, height: kTitleLabelHeight)
        self.gameModeLabel.frame = CGRect(x: self.gameModeView.bounds.origin.x, y: CGRectGetMaxY(self.gameModeTitleLabel.frame), width: self.gameModeView.bounds.width, height: kValueLabelHeight)
        self.gameModeLabel.text = self.dataSource?.gameModeInCurrentSessionInSideMenuView(self)

        
        self.sessionProgressView.frame = CGRect(x: 40, y: CGRectGetMaxY(self.gameModeView.frame) + 20, width: 176, height: (kTitleLabelHeight + kValueLabelHeight))
        self.sessionProgressTitleLabel.frame = CGRect(x: self.sessionProgressView.bounds.origin.x, y: self.sessionProgressView.bounds.origin.y, width: self.sessionProgressView.bounds.width, height: kTitleLabelHeight)
        self.sessionProgressLabel.frame = CGRect(x: self.sessionProgressView.bounds.origin.x, y: CGRectGetMaxY(self.sessionProgressTitleLabel.frame), width: self.sessionProgressView.bounds.width, height: kValueLabelHeight)
        self.sessionProgressLabel.text = "\(self.dataSource?.problemIndexInCurrentSessionInSideMenuView(self) as Int! + 1) / \(self.dataSource?.totalNumberOfProblemsInCurrentSessionInSideMenuView(self) as Int!)"

        self.userInfoView.frame = CGRect(x: 40, y: CGRectGetMaxY(self.sessionProgressView.frame) + 20, width: 176, height: 100)
        self.userInfoDisplayNameTitleLabel.frame = CGRect(x: self.userInfoView.bounds.origin.x, y: self.userInfoView.bounds.origin.y, width: self.userInfoView.bounds.width, height: kTitleLabelHeight)
        self.userInfoDisplayNameLabel.frame = CGRect(x: self.userInfoView.bounds.origin.x, y: CGRectGetMaxY(self.userInfoDisplayNameTitleLabel.frame), width: self.userInfoView.bounds.width, height: kValueLabelHeight)
        self.userInfoAgeTitleLabel.frame = CGRect(x: self.userInfoView.bounds.origin.x, y: CGRectGetMaxY(self.userInfoDisplayNameLabel.frame), width: self.userInfoView.bounds.width, height: kTitleLabelHeight)
        self.userInfoAgeLabel.frame = CGRect(x: self.userInfoView.bounds.origin.x, y: CGRectGetMaxY(self.userInfoAgeTitleLabel.frame), width: self.userInfoView.bounds.width, height: kValueLabelHeight)
        self.userInfoDisplayNameLabel.text = self.dataSource?.currentUserDisplayNameInSideMenuView(self)
        self.userInfoAgeLabel.text = String(self.dataSource?.currentUserAgeInSideMenuView(self) as Int!)
        if (self.dataSource?.currentUserIsGuestInSideMenuView(self) == true) {
            self.userInfoAgeTitleLabel.hidden = true
            self.userInfoAgeLabel.hidden = true
        }
        
        self.restartSessionButton.frame = CGRect(x: 40, y: CGRectGetMaxY(self.userInfoView.frame) + 80, width: 176, height: 50)
        
        self.mainMenuButton.frame = CGRect(x: 40, y: CGRectGetMaxY(self.restartSessionButton.frame) + 15, width: 176, height: 50)
    }
    
    func updateTimePlayedLabelWithHoursPlayed(hoursPlayed: Int, minutesPlayed: Int) {
        let hoursText = hoursPlayed == 0 ? "" : "\(hoursPlayed) hr "
        let minutesText = "\(minutesPlayed) min"
        self.timePlayedLabel.text = "\(hoursText)\(minutesText)"
    }
    
    func didTapRestartSessionButton(button: UIButton) {
        self.delegate?.didTapRestartSessionButtonInSideMenuView(self)
    }

    func didTapMainMenuButton(button: UIButton) {
        self.delegate?.didTapMainMenuButtonInSideMenuView(self)
    }


}
