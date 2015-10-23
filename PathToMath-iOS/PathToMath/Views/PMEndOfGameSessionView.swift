//
//  PMEndOfGameSessionView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/16/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

protocol PMEndOfGameSessionViewDelegate: NSObjectProtocol {
    
    func didTapPlayMoreButtonInEndOfGameSessionView(endOfGameSessionView: PMEndOfGameSessionView)
    
    func didTapMainMenuButtonInEndOfGameSessionView(endOfGameSessionView: PMEndOfGameSessionView)
}

class PMEndOfGameSessionView: UIView {

    weak var delegate: PMEndOfGameSessionViewDelegate?
    
    private var backgroundVisualEffectView: UIVisualEffectView!
    private var titleLabel: UILabel!
    private var detailTextLabel: UILabel!
    private var syncAlertView: UIView!
    private var playMoreButton: UIButton!
    private var mainMenuButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        self.backgroundVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        self.backgroundVisualEffectView.frame = self.bounds
        self.addSubview(self.backgroundVisualEffectView)
        
        self.titleLabel = UILabel(frame: CGRect(x: 0, y: 180, width: self.bounds.width, height: 80))
        self.titleLabel.textAlignment = .Center
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.font = UIFont.systemFontOfSize(34)
        self.titleLabel.text = "Well Done!"
        self.addSubview(self.titleLabel)
        
        self.detailTextLabel = UILabel(frame: CGRect(x: 0, y: 260, width: self.bounds.width, height: 100))
        self.detailTextLabel.textAlignment = .Center
        self.detailTextLabel.textColor = UIColor.whiteColor()
        self.detailTextLabel.font = UIFont.systemFontOfSize(20)
        self.detailTextLabel.numberOfLines = 2
        self.detailTextLabel.text = "You have finished all the problems in this session!" //\nWould you like to play one more? Or go back to main menu and take some rest?"
        self.addSubview(self.detailTextLabel)
        
        self.playMoreButton = UIButton(frame: CGRect(x: 0, y: 480, width: 200, height: 50))
        self.playMoreButton.center = CGPoint(x: self.center.x, y: self.playMoreButton.center.y)
        self.playMoreButton.layer.cornerRadius = 5
        self.playMoreButton.layer.masksToBounds = true
        self.playMoreButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        self.playMoreButton.setTitle("play more", forState: .Normal)
        self.playMoreButton.addTarget(self, action: "didTapPlayMoreButton:", forControlEvents: .TouchUpInside)
        self.playMoreButton.hidden = true // TODO: Delete this
        self.addSubview(self.playMoreButton)

        self.mainMenuButton = UIButton(frame: CGRect(x: 0, y: CGRectGetMaxY(self.playMoreButton.frame) + 15, width: 200, height: 50))
        self.mainMenuButton.center = CGPoint(x: self.center.x, y: self.mainMenuButton.center.y)
        self.mainMenuButton.layer.cornerRadius = 5
        self.mainMenuButton.layer.masksToBounds = true
        self.mainMenuButton.setBackgroundImage(UIImage(named: "ButtonBackgroundRed"), forState: .Normal)
        self.mainMenuButton.setTitle("main menu", forState: .Normal)
        self.mainMenuButton.addTarget(self, action: "didTapMainMenuButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.mainMenuButton)
    }
    
    func didTapPlayMoreButton(button: UIButton) {
        self.delegate?.didTapPlayMoreButtonInEndOfGameSessionView(self)
    }
    
    func didTapMainMenuButton(button: UIButton) {
        self.delegate?.didTapMainMenuButtonInEndOfGameSessionView(self)
    }
}
