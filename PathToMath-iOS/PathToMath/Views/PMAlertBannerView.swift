//
//  PMAlertBannerView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/19/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

enum PMAlertBannerViewStyle : Int {
    case Success
    case Error
    case Warning
    case Info
}

class PMAlertBannerView: UIView {
    
    let showFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 120)
    let hideFrame = CGRect(x: 0, y: -120, width: UIScreen.mainScreen().bounds.width, height: 120)

    private(set) var style: PMAlertBannerViewStyle
    private var iconImageView: UIImageView!

    var titleLabel: UILabel!
    var detailTextLabel: UILabel!
    
    init(style: PMAlertBannerViewStyle) {
        self.style = style
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 120))
        
        self.titleLabel = UILabel()
        self.titleLabel.font = UIFont.systemFontOfSize(26)
        self.titleLabel.textAlignment = .Left
        self.titleLabel.textColor = UIColor.whiteColor()
        self.addSubview(self.titleLabel)
        
        self.detailTextLabel = UILabel()
        self.detailTextLabel.numberOfLines = 0
        self.detailTextLabel.font = UIFont.systemFontOfSize(14)
        self.detailTextLabel.textAlignment = .Left
        self.detailTextLabel.textColor = UIColor.whiteColor()
        self.addSubview(self.detailTextLabel)
        
        switch self.style {
        case .Success:
            self.backgroundColor = UIColor(red: 86.0/255.0, green: 194.0/255.0, blue: 4.0/255.0, alpha: 0.5)
            self.iconImageView = UIImageView(image: UIImage(named: "AlertBannerViewSuccess"))
            break
        case .Error:
            self.backgroundColor = UIColor(red: 215.0/255.0, green: 0.0/255.0, blue: 3.0/255.0, alpha: 0.5)
            self.iconImageView = UIImageView(image: UIImage(named: "AlertBannerViewError"))
            break
        case .Warning:
            self.backgroundColor = UIColor(red: 240.0/255.0, green: 182.0/255.0, blue: 12.0/255.0, alpha: 0.5)
            self.iconImageView = UIImageView(image: UIImage(named: "AlertBannerViewWarning"))
            break
        case .Info:
            self.backgroundColor = UIColor(red: 29.0/255.0, green: 131.0/255.0, blue: 188.0/255.0, alpha: 0.5)
            self.iconImageView = UIImageView(image: UIImage(named: "AlertBannerViewInfo"))
            break
        }
        self.addSubview(self.iconImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconImageView.center = CGPoint(x: self.bounds.width * 0.25, y: self.bounds.height * 0.5)
        self.titleLabel.frame = CGRect(x: self.bounds.width / 3.0, y: 25.0, width: self.bounds.width * 2.0/3.0, height: 30)
        self.detailTextLabel.frame = CGRect(x: CGRectGetMinX(self.titleLabel.frame), y: CGRectGetMaxY(self.titleLabel.frame), width: CGRectGetWidth(self.titleLabel.frame), height: 55)
    }

}
