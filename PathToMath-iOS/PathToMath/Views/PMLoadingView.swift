//
//  PMLoadingView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/16/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

class PMLoadingView: UIView {
    
    private var backgroundImageView: UIImageView!
    private var backgroundBlurVisualEffectView: UIVisualEffectView!
    private var titleLabel: UILabel!
    private var detailTextLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundImageView = UIImageView()
        self.backgroundImageView.image = UIImage(named: "LoadingViewBackground")
        self.addSubview(self.backgroundImageView)
        
        self.backgroundBlurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        self.addSubview(self.backgroundBlurVisualEffectView)
        
        self.titleLabel = UILabel()
        self.titleLabel.textAlignment = .Center
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.font = UIFont.systemFontOfSize(36)
        self.titleLabel.text = "Please Wait"
        self.addSubview(self.titleLabel)
        
        self.detailTextLabel = UILabel()
        self.detailTextLabel.textAlignment = .Center
        self.detailTextLabel.textColor = UIColor.whiteColor()
        self.detailTextLabel.numberOfLines = 2
        self.detailTextLabel.text = "If you are playing for the first time on this device,\nplease make sure you are connected to the Internet."
        self.detailTextLabel.alpha = 0
        self.addSubview(self.detailTextLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundImageView.frame = self.bounds
        self.backgroundBlurVisualEffectView.frame = self.bounds
        
        self.titleLabel.frame = CGRect(x: 0, y: 300, width: 256, height: 64)
        self.titleLabel.center = CGPoint(x: self.center.x, y: self.titleLabel.center.y)
        
        self.detailTextLabel.frame = CGRect(x: 0, y: CGRectGetMaxY(self.titleLabel.frame), width: 400, height: 64)
        self.detailTextLabel.center = CGPoint(x: self.center.x, y: self.detailTextLabel.center.y)
        UIView.animateWithDuration(1.0, delay: 3.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.detailTextLabel.alpha = 1
        }, completion: nil)
    }

}
