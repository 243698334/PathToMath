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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        self.backgroundImageView = UIImageView(frame: self.bounds)
        self.backgroundImageView.image = UIImage(named: "LoadingViewBackground")
        self.addSubview(self.backgroundImageView)
        
        self.backgroundBlurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        self.backgroundBlurVisualEffectView.frame = self.bounds
        self.addSubview(self.backgroundBlurVisualEffectView)
        
        self.titleLabel = UILabel(frame: CGRect(x: 0, y: 300, width: 256, height: 64))
        self.titleLabel.center = CGPoint(x: self.center.x, y: self.titleLabel.center.y)
        self.titleLabel.textAlignment = .Center
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.font = UIFont.systemFontOfSize(36)
        self.titleLabel.text = "Please Wait"
        self.titleLabel.alpha = 0
        self.addSubview(self.titleLabel)
        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.titleLabel.alpha = 1
        }, completion: nil)
        
        self.detailTextLabel = UILabel(frame: CGRect(x: 0, y: CGRectGetMaxY(self.titleLabel.frame), width: 400, height: 64))
        self.detailTextLabel.center = CGPoint(x: self.center.x, y: self.detailTextLabel.center.y)
        self.detailTextLabel.textAlignment = .Center
        self.detailTextLabel.textColor = UIColor.whiteColor()
        self.detailTextLabel.numberOfLines = 2
        self.detailTextLabel.text = "If you are playing for the first time on this device,\nplease make sure you are connected to the Internet."
        self.detailTextLabel.alpha = 0
        self.addSubview(self.detailTextLabel)
        UIView.animateWithDuration(1.0, delay: 5.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.detailTextLabel.alpha = 1
        }, completion: nil)
    }

}
