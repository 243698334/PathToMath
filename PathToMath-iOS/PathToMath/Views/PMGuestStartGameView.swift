//
//  PMGuestStartGameView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/22/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

protocol PMGuestStartGameViewDelegate: NSObjectProtocol {
    
    func guestStartGameView(guestStartGameView: PMGuestStartGameView, didSelectGameMode gameMode: String)
}

class PMGuestStartGameView: UIView {
    
    weak var delegate: PMGuestStartGameViewDelegate?
    
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    
    private var approximateGameModeButton: UIButton!
    private var exactGameModeButton: UIButton!
    private var abacusGameModeButton: UIButton!
    private var numbersGameModeButton: UIButton!
    private var aPlusBGameModeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        self.titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 50))
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.text = "choose a game mode to start"
    }
    
    

}
