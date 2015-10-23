//
//  PMInstructionView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/15/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

protocol PMGameInstructionViewDataSource: NSObjectProtocol {
    
    func itemNameInGameInstructionView(gameInstructionView: PMGameInstructionView) -> String
    
    func itemImageInGameInstructionView(gameInstructionView: PMGameInstructionView) -> UIImage
}

protocol PMGameInstructionViewDelegate: NSObjectProtocol {
    
    func didTapContinueButtonInGameInstructionView(gameInstructionView: PMGameInstructionView)
}

class PMGameInstructionView: UIView {
    
    weak var dataSource: PMGameInstructionViewDataSource?
    weak var delegate: PMGameInstructionViewDelegate?
    
    private var backgroundImageView: UIImageView!
    private var itemImageView: UIImageView!
    private var instructionLabel: UILabel!
    private var continueButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        self.backgroundImageView = UIImageView(frame: self.bounds)
        self.backgroundImageView.image = UIImage(named: "GameInstructionViewBackground")
        self.addSubview(self.backgroundImageView)
        
        self.itemImageView = UIImageView(frame: CGRect(x: 0, y: 100, width: 512, height: 384))
        self.itemImageView.center = CGPoint(x: self.center.x, y: self.itemImageView.center.y)
        self.itemImageView.image = self.dataSource?.itemImageInGameInstructionView(self)
        self.addSubview(self.itemImageView)
        
        self.instructionLabel = UILabel(frame: CGRect(x: 0, y: 512, width: self.bounds.width, height: 40))
        self.instructionLabel.center = CGPoint(x: self.center.x, y: self.instructionLabel.center.y)
        self.instructionLabel.textAlignment = .Center
        self.instructionLabel.font = UIFont.systemFontOfSize(26.0)
        self.instructionLabel.text = "Get as many \(self.dataSource?.itemNameInGameInstructionView(self) as String!)s as you can."
        self.addSubview(self.instructionLabel)
        
        self.continueButton = UIButton(frame: CGRect(x: 0, y: 650, width: 200, height: 50))
        self.continueButton.center = CGPoint(x: self.center.x, y: self.continueButton.center.y)
        self.continueButton.layer.cornerRadius = 5
        self.continueButton.layer.masksToBounds = true
        self.continueButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        self.continueButton.setTitle("Continue", forState: .Normal)
        self.continueButton.addTarget(self, action: "didTapContinueButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.continueButton)
    }
    
    func didTapContinueButton(button: UIButton) {
        self.delegate?.didTapContinueButtonInGameInstructionView(self)
    }

}
