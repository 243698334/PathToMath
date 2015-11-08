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
    private var mainMenuButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        self.backgroundVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        self.addSubview(self.backgroundVisualEffectView)
        
        self.titleLabel = UILabel()
        self.titleLabel.textAlignment = .Center
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.font = UIFont.systemFontOfSize(34)
        self.titleLabel.text = "Well Done!"
        self.addSubview(self.titleLabel)
        
        self.detailTextLabel = UILabel()
        self.detailTextLabel.textAlignment = .Center
        self.detailTextLabel.textColor = UIColor.whiteColor()
        self.detailTextLabel.font = UIFont.systemFontOfSize(20)
        self.detailTextLabel.numberOfLines = 2
        self.detailTextLabel.text = "You have finished all the problems in this session!"
        self.addSubview(self.detailTextLabel)
        
        self.mainMenuButton = UIButton()
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
    
    override func drawRect(rect: CGRect) {
        self.backgroundVisualEffectView.frame = self.bounds
        
        self.titleLabel.frame = CGRect(x: 0, y: 180, width: self.bounds.width, height: 80)
        self.detailTextLabel.frame = CGRect(x: 0, y: 260, width: self.bounds.width, height: 100)
        self.mainMenuButton.frame = CGRect(x: 0, y: 500, width: 200, height: 50)
        self.mainMenuButton.center = CGPoint(x: self.center.x, y: self.mainMenuButton.center.y)
    }
    
    func didTapPlayMoreButton(button: UIButton) {
        self.delegate?.didTapPlayMoreButtonInEndOfGameSessionView(self)
    }
    
    func didTapMainMenuButton(button: UIButton) {
        self.delegate?.didTapMainMenuButtonInEndOfGameSessionView(self)
    }
}
