//
//  PMGuestStartGameView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/22/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

protocol PMGuestStartGameViewDelegate: NSObjectProtocol {
    
    func guestStartGameView(guestStartGameView: PMGuestStartGameView, didTapStartButtonWithGameMode gameMode: String)
    
    func didTapBackButtonInGuestStartGameView(guestStartGameView: PMGuestStartGameView)
}

class PMGuestStartGameView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private let kTitleLabelHeight = CGFloat(30)
    private let kButtonHeight = CGFloat(50)
    private let kHorizontalPadding = CGFloat(40)
    private let kVerticalPadding = CGFloat(10)
    private let kSummaryLabelTopMargin = CGFloat(70)
    
    private let gameModes = [kPMGameModeApproximate, kPMGameModeExact, kPMGameModeAbacus, kPMGameModeNumbers, kPMGameModeAPlusB]

    weak var delegate: PMGuestStartGameViewDelegate?
    
    private var titleLabel: UILabel!
    private var selectGameModeButton: UIButton!
    private var selectGameModeButtonDropdownIconLabel: UILabel!
    private var backButton: UIButton!
    private var startButton: UIButton!
    private var selectGameModeTableView: UITableView!
    private var startButtonActivityIndicatorView: UIActivityIndicatorView!
    private var guestModeInfoLabel: UILabel!
    
    private var selectedGameMode: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        self.titleLabel = UILabel()
        self.titleLabel.textAlignment = .Center
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.font = UIFont.systemFontOfSize(14.0)
        self.titleLabel.text = "Select a game mode to start"
        self.addSubview(self.titleLabel)

        self.selectGameModeButton = UIButton()
        self.selectGameModeButton.setTitle("select game mode", forState: .Normal)
        self.selectGameModeButton.layer.cornerRadius = 5
        self.selectGameModeButton.layer.masksToBounds = true
        self.selectGameModeButton.setBackgroundImage(UIImage(named: "ButtonBackgroundOrange"), forState: .Normal)
        self.selectGameModeButton.contentVerticalAlignment = .Center
        self.selectGameModeButton.addTarget(self, action: "didTapSelectGameModeButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.selectGameModeButton)

        self.selectGameModeButtonDropdownIconLabel = UILabel()
        self.selectGameModeButtonDropdownIconLabel.text = "▼"
        self.selectGameModeButtonDropdownIconLabel.textColor = UIColor.whiteColor()
        self.selectGameModeButton.addSubview(self.selectGameModeButtonDropdownIconLabel)
        
        self.backButton = UIButton()
        self.backButton.setTitle("back", forState: .Normal)
        self.backButton.layer.cornerRadius = 5
        self.backButton.layer.masksToBounds = true
        self.backButton.setBackgroundImage(UIImage(named: "ButtonBackgroundRed"), forState: .Normal)
        self.backButton.contentVerticalAlignment = .Center
        self.backButton.addTarget(self, action: "didTapBackButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.backButton)
        
        self.startButton = UIButton()
        self.startButton.setTitle("start", forState: .Normal)
        self.startButton.layer.cornerRadius = 5
        self.startButton.layer.masksToBounds = true
        self.startButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        self.startButton.contentVerticalAlignment = .Center
        self.startButton.addTarget(self, action: "didTapStartButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.startButton)

        self.guestModeInfoLabel = UILabel()
        self.guestModeInfoLabel.textAlignment = .Center
        self.guestModeInfoLabel.textColor = UIColor.whiteColor()
        self.guestModeInfoLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        self.guestModeInfoLabel.numberOfLines = 0
        self.guestModeInfoLabel.text = "You can try the first level problem set in the game mode you choose without logging in."
        self.addSubview(self.guestModeInfoLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.frame = CGRect(x: kHorizontalPadding, y: kSummaryLabelTopMargin, width: self.bounds.width - 2 * kHorizontalPadding, height: kTitleLabelHeight)
        self.selectGameModeButton.frame = CGRect(x: kHorizontalPadding, y: CGRectGetMaxY(self.titleLabel.frame) + kVerticalPadding, width: self.bounds.width - 2 * kHorizontalPadding, height: kButtonHeight)
        self.selectGameModeButtonDropdownIconLabel.frame = CGRect(x: self.selectGameModeButton.bounds.width - 40, y: (self.selectGameModeButton.bounds.height - 25) / 2, width: 25, height: 25)
        self.backButton.frame = CGRect(x: kHorizontalPadding, y: CGRectGetMaxY(self.selectGameModeButton.frame) + kVerticalPadding, width: self.bounds.width / 2 - kHorizontalPadding - kVerticalPadding / 2, height: kButtonHeight)
        self.startButton.frame = CGRect(x: (self.bounds.width + kVerticalPadding) / 2.0, y: CGRectGetMaxY(self.selectGameModeButton.frame) + kVerticalPadding, width: self.bounds.width / 2 - kHorizontalPadding - kVerticalPadding / 2, height: kButtonHeight)
        self.guestModeInfoLabel.frame = CGRect(x: kHorizontalPadding, y: CGRectGetMaxY(self.backButton.frame) + kVerticalPadding, width: self.bounds.width - 2 * kHorizontalPadding, height: kButtonHeight)
    }
    
    func didTapSelectGameModeButton(button: UIButton) {
        if (self.selectGameModeTableView == nil) {
            self.showSelectGameModeTableView()
        } else {
            self.hideSelectGameModeTableView()
        }
    }
    
    func didTapBackButton(button: UIButton) {
        self.delegate?.didTapBackButtonInGuestStartGameView(self)
    }
    
    func didTapStartButton(button: UIButton) {
        if (self.selectedGameMode == nil) {
            self.performShakeAnimationOnSelectGameModeButton()
        } else {
            self.delegate?.guestStartGameView(self, didTapStartButtonWithGameMode: self.selectedGameMode)
        }
    }
    
    func startStartButtonActivityIndicatorAnimation() {
        self.startButtonActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.startButtonActivityIndicatorView?.frame = self.startButton.bounds
        self.startButtonActivityIndicatorView.startAnimating()
        self.startButton.setTitle("", forState: .Normal)
        self.startButton.addSubview(self.startButtonActivityIndicatorView)
        self.startButton.userInteractionEnabled = false
    }
    
    func stopStartButtonActivityIndicatorAnimation() {
        self.startButton.setTitle("start", forState: .Normal)
        self.startButton.userInteractionEnabled = true
        self.startButtonActivityIndicatorView.stopAnimating()
        self.startButtonActivityIndicatorView.removeFromSuperview()
        self.startButtonActivityIndicatorView = nil
    }
    
    private func performShakeAnimationOnSelectGameModeButton() {
        self.selectGameModeButton.transform = CGAffineTransformMakeTranslation(8.0, 0.0);
        UIView.animateWithDuration(0.08, delay: 0.0, options: .Autoreverse, animations: { () -> Void in
            self.selectGameModeButton.transform = CGAffineTransformMakeTranslation(-8.0, 0.0);
        }) { (finished: Bool) -> Void in
            self.selectGameModeButton.transform = CGAffineTransformIdentity
        }
    }
    
    private func showSelectGameModeTableView() {
        let selectGameModeTableViewInitialFrame = CGRect(origin: self.backButton.frame.origin, size: CGSize(width: self.selectGameModeButton.frame.width, height: 0))
        let selectGameModeTableViewFinalFrame = CGRect(origin: self.backButton.frame.origin, size: CGSize(width: self.selectGameModeButton.frame.width, height: 3 * kButtonHeight))
        
        self.selectGameModeTableView = UITableView(frame: selectGameModeTableViewInitialFrame)
        self.selectGameModeTableView.dataSource = self
        self.selectGameModeTableView.delegate = self
        self.selectGameModeTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SelectGameModeTableViewCell")
        self.selectGameModeTableView.layer.cornerRadius = 5
        self.selectGameModeTableView.layer.masksToBounds = true
        self.selectGameModeTableView.backgroundColor = UIColor(red: 224.0/255.0, green: 143.0/255.0, blue: 0.0, alpha: 0.9)
        self.addSubview(self.selectGameModeTableView)

        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.selectGameModeTableView.frame = selectGameModeTableViewFinalFrame
        }) { (finished: Bool) -> Void in
            if (finished == true) {
                self.selectGameModeTableView.flashScrollIndicators()
            }
        }
    }
    
    private func hideSelectGameModeTableView() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            var selectGameModeTableViewFrame = self.selectGameModeTableView.frame
            selectGameModeTableViewFrame.size.height = 0
            self.selectGameModeTableView.frame = selectGameModeTableViewFrame
        }) { (finished: Bool) -> Void in
            self.selectGameModeTableView.removeFromSuperview()
            self.selectGameModeTableView = nil
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectGameModeTableViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.gameModes[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.textAlignment = .Center
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0.9 * kButtonHeight
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.selectedGameMode = self.gameModes[indexPath.row]
        self.selectGameModeButton.setTitle(self.gameModes[indexPath.row], forState: .Normal)
        self.hideSelectGameModeTableView()
    }
    

}
