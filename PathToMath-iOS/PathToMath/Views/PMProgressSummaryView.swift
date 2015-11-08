//
//  PMProgressSummaryView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/15/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

protocol PMProgressSummaryViewDataSource: NSObjectProtocol {
    
    func levelInProgressSummaryView(progressSummaryView: PMProgressSummaryView) -> Int
}

protocol PMProgressSummaryViewDelegate: NSObjectProtocol {
    
    func didTapContinueButtonInProgressSummaryView(progressSummaryView: PMProgressSummaryView)
}

class PMProgressSummaryView: UIView {

    weak var dataSource: PMProgressSummaryViewDataSource?
    weak var delegate: PMProgressSummaryViewDelegate?
    
    private var backgroundImageView: UIImageView!
    private var continueButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundImageView = UIImageView()
        self.backgroundImageView.image = UIImage(named: "ProgressSummaryViewBackground")
        self.addSubview(self.backgroundImageView)
        
        self.continueButton = UIButton()
        self.continueButton.layer.cornerRadius = 5
        self.continueButton.layer.masksToBounds = true
        self.continueButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        self.continueButton.setTitle("Continue", forState: .Normal)
        self.continueButton.addTarget(self, action: "didTapContinueButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.continueButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundImageView.frame = self.bounds
        
        for currentLevel in 1...(self.dataSource?.levelInProgressSummaryView(self))! {
            let currentLevelImageView = UIImageView(image: UIImage(named: "ProgressImageLevel" + String(currentLevel)))
            self.addSubview(currentLevelImageView)
        }
        
        self.continueButton.frame = CGRect(x: 0, y: 650, width: 200, height: 50)
        self.continueButton.center = CGPoint(x: self.center.x, y: self.continueButton.center.y)
        self.bringSubviewToFront(self.continueButton)
    }
    
    func didTapContinueButton(button: UIButton) {
        self.delegate?.didTapContinueButtonInProgressSummaryView(self)
    }

}
