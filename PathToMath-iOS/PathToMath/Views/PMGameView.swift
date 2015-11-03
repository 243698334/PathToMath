//
//  PMGameView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/17/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

public enum PMGameViewBasketPosition: Int {
    case Left
    case Right
}

public enum PMGameViewCloudPosition: Int {
    case Left
    case Right
}

protocol PMGameViewDataSource: NSObjectProtocol {
    
    /**
    Asks the data source for the progress of the current session.
    
    - parameters:
        - gameView: The GameView requesting such information.
    - returns: A Float value (between 0.0 and 1.0) represents the percentage of the progress.
    */
    func currentProgressInGameView(gameView: PMGameView) -> Float
    
    /**
    Asks the data source for the number of items in each clouds.
    
    - note: The state and progress of the game session is managed by the view controller who owns the PMGameView.
    - parameters:
        - gameView: The GameView requesting such information.
        - cloudPosition: The position of the cloud where the items are in, either Left or Right.
    - returns: An integer as the first term.
    */
    func gameView(gameView: PMGameView, numberOfItemsInCloudAtPosition cloudPosition: PMGameViewCloudPosition) -> Int
    
    /**
    Asks the data source for the number of items in each basket.
    
    - note: The state and progress of the game session is managed by the view controller who owns the PMGameView.
    - parameters:
        - gameView: The GameView requesting such information.
        - basketPosition: The position of the basket where the items are in, either Left or Right.
    - returns: An integer as the first term.
    */
    func gameView(gameView: PMGameView, numberOfItemsInBasketAtPosition basketPosition: PMGameViewBasketPosition) -> Int
    
    /**
    Asks the data source for the image of the item in this session.
    
    - parameters:
        - gameView: The GameView requesting such information.
    - returns: An image for the current item being used for counting.
    */
    func itemImageInGameView(gameView: PMGameView) -> UIImage
    
    /**
    Asks the data source for the image of the item in this session.
    
    - parameters:
        - gameView: The GameView requesting such information.
        - basketPosition: The position of the basket, either Left or Right.
    - returns: An image for the current item being used for counting.
    */
    func gameView(gameView: PMGameView, itemHidingImageAtBasketPosition basketPosition: PMGameViewBasketPosition) -> UIImage
    
    /**
    Asks the data source for the name of the item in this session.
    
    - parameters:
        - gameView: The GameView requesting such information.
    - returns: An image for the current item being used for counting.
    */
    func itemNameInGameView(gameView: PMGameView) -> String
}

protocol PMGameViewDelegate: NSObjectProtocol {
    
    /**
    Tells the delegate that the user has selected a basket as the answer.
    
    - parameters:
        - gameView: The GameView where the selection takes place.
        - basketPosition: The position of the selected basket, either Left or Right.
    */
    func gameView(gameView: PMGameView, didTapBasketAtPosition basketPosition: PMGameViewBasketPosition)
    
    /**
    Tells the delegate that the user has tapped a cloud.
    
    - parameters:
        - gameView: The GameView where the selection takes place.
    - cloudPosition: The position of the tapped cloud, either Left or Right.
    */
    func gameView(gameView: PMGameView, didTapCloudAtPosition cloudPosition: PMGameViewCloudPosition)
    
    /**
    Tells the delegate that the user has moved an item to the basket
    
    - parameters:
        - gameView: The GameView where the selection takes place.
        - cloudPosition: The position of the cloud where the item was in, either Left or Right.
    */
    func gameView(gameView: PMGameView, didDragAndDropItemToBasketFromCloudAtPosition cloudPosition: PMGameViewCloudPosition)
    
    /**
    Tells the delegate that the the space bar was tapped.
    
    - parameters:
        - gameView: The GameView where the control event took place.
    */
    func didTapSpaceBarButtonInGameView(gameView: PMGameView)
}


class PMGameView: UIView {

    private let kCloudImageViewSubviewIndexIndex: Int = 0
    private let kBasketAboveImageViewSubviewIndex: Int = 0
    private let kBasketBehindButtonSubviewIndex: Int = 0
    private let kItemImageViewSubviewIndex: Int = 1
    private let kBasketFrontButtonSubviewIndex: Int = 2
    private let kHidingItemImageViewSubviewIndex: Int = 3
    
    private let kRoadProgressWidth: CGFloat = 950.0
    private let kRoadProgressOriginX: CGFloat = 70.0
    private let kLeftBasketOriginX: CGFloat = 90.0
    private let kRightBasketOriginX: CGFloat = 593.0
    private let kBasketsOriginY: CGFloat = 350.0
    private let kCloudsOriginY: CGFloat = 90.0
    private let kHintLabelOriginY: CGFloat = 90.0
    private let kAbacusFirstBeadRowOriginY: CGFloat = 14.0
    private let kAbacusFirstBeadColumnOriginX: CGFloat = 93.0
    private let kAbacusBeadMovementOffset: CGFloat = 69.0
    private let kCloudItemDestinationPoint: CGPoint = CGPoint(x: 260, y: 450)
    
    weak var delegate: PMGameViewDelegate?
    weak var dataSource: PMGameViewDataSource?
    
    private var backgroundImageView: UIImageView!
    private var spaceBarButton : UIButton!
    private var interactionHintLabel: UILabel!

    private var progressRoadImageView: UIImageView!
    private var munduGuyImageView: UIImageView!
    
    private var leftBasketFrontButton: UIButton!
    private var leftBasketBehindButton: UIButton!
    private var leftBasketAboveImageView: UIImageView!
    private var leftBasketItemContainerView: UIView!
    private var leftBasketItemOriginalOriginPoints: [CGPoint]!

    private var rightBasketFrontImageView: UIImageView!
    private var rightBasketBehindImageView: UIImageView!
    private var rightBasketAboveButton: UIButton!
    private var rightBasketItemContainerView: UIView!
    private var rightBasketItemOriginalOriginPoints: [CGPoint]!
    
    private var leftCloudButton: UIButton!
    private var leftCloudItemContainerView: UIView!
    private var leftCloudItemOriginalOriginPoints: [CGPoint]!
    private var rightCloudButton: UIButton!
    private var rightCloudItemContainerView: UIView!
    private var rightCloudItemOriginalOriginPoints: [CGPoint]!
    
    private var leftHidingItemImageView: UIImageView!
    private var rightHidingItemImageView: UIImageView!
    
    private var leftAbacusView: UIView!
    private var leftAbacusBlueBeadImageViews: [UIImageView]!
    private var leftAbacusRedBeadImageViews: [UIImageView]!
    private var leftAbacusNumber: Int!
    
    private var rightAbacusView: UIView!
    private var rightAbacusBlueBeadImageViews: [UIImageView]!
    private var rightAbacusRedBeadImageViews: [UIImageView]!
    private var rightAbacusNumber: Int!
    
    private var interactionHintOverlayView: UIView!
    private var basketInteractionHintOverlayView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        self.drawBackground()
        self.drawSpaceBar()
        self.drawInteractionHint()
        self.drawProgressRoad()
        self.drawClouds()
        self.drawBaskets()
        self.drawHidingItems()
        self.drawAbacuses()
        self.bringSubviewToFront(self.leftBasketFrontButton)
        self.bringSubviewToFront(self.rightBasketFrontImageView)
        self.sendSubviewToBack(self.backgroundImageView)
    }
    
    private func drawBackground() {
        self.backgroundImageView = UIImageView(image: UIImage(named: "GameViewBackground"))
        self.backgroundImageView.frame = self.bounds
        self.addSubview(self.backgroundImageView)
    }
    
    private func drawSpaceBar() {
        self.spaceBarButton = UIButton(frame: CGRect(x: 0, y: 650, width: 200, height: 50))
        self.spaceBarButton.center = CGPoint(x: self.center.x, y: self.spaceBarButton.center.y)
        self.spaceBarButton.layer.cornerRadius = 5
        self.spaceBarButton.layer.masksToBounds = true
        self.spaceBarButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        self.spaceBarButton.setTitle("space", forState: .Normal)
        self.spaceBarButton.addTarget(self, action: "didTapSpaceBarButton:", forControlEvents: .TouchUpInside)
        self.spaceBarButton.hidden = true
        self.addSubview(self.spaceBarButton)
    }
    
    private func drawInteractionHint() {
        self.interactionHintLabel = UILabel(frame: CGRect(x: 0, y: kHintLabelOriginY, width: 500, height: 40))
        self.interactionHintLabel.center = CGPoint(x: self.center.x, y: self.interactionHintLabel.center.y)
        self.interactionHintLabel.textAlignment = .Center
        self.interactionHintLabel.font = UIFont.systemFontOfSize(28)
        self.interactionHintLabel.text = "Choose the basket with more \((self.dataSource?.itemNameInGameView(self))!)s"
        self.interactionHintLabel.hidden = true
        self.addSubview(self.interactionHintLabel)
    }
    
    private func drawProgressRoad() {
        self.progressRoadImageView = UIImageView(frame: CGRect(x: kRoadProgressOriginX, y: 50, width: kRoadProgressWidth, height: 30))
        self.progressRoadImageView.image = UIImage(named: "RoadProgress")
        self.addSubview(self.progressRoadImageView)
        
        self.munduGuyImageView = UIImageView(frame: CGRect(x: kRoadProgressOriginX, y: 20, width: 25, height: 50))
        self.munduGuyImageView.image = UIImage(named: "RoadMunduGuy1")
        self.addSubview(self.munduGuyImageView)
    }
    
    private func drawClouds() {
        self.leftCloudButton = UIButton(frame: CGRect(x: 0, y: kCloudsOriginY, width: 350, height: 260))
        self.leftCloudButton.setImage(UIImage(named: "Cloud"), forState: .Normal)
        self.leftCloudButton.addTarget(self, action: "didTapLeftCloudButton:", forControlEvents: .TouchUpInside)
        self.leftCloudButton.hidden = true
        self.insertSubview(self.leftCloudButton, atIndex: kCloudImageViewSubviewIndexIndex)
        self.leftCloudItemContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 180))
        self.leftCloudItemContainerView.center = CGPoint(x: self.leftCloudButton.bounds.width / 2.0, y: self.leftCloudButton.bounds.height / 2.0)
        self.leftCloudItemContainerView.userInteractionEnabled = false
        self.leftCloudButton.addSubview(self.leftCloudItemContainerView)
        
        self.rightCloudButton = UIButton(frame: CGRect(x: CGRectGetMaxX(self.leftCloudButton.frame) - 20, y: kCloudsOriginY, width: 350, height: 260))
        self.rightCloudButton.setImage(UIImage(named: "Cloud"), forState: .Normal)
        self.rightCloudButton.addTarget(self, action: "didTapRightCloudButton:", forControlEvents: .TouchUpInside)
        self.rightCloudButton.hidden = true
        self.insertSubview(self.rightCloudButton, aboveSubview:self.leftCloudButton)
        self.rightCloudItemContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 180))
        self.rightCloudItemContainerView.center = CGPoint(x: self.rightCloudButton.bounds.width / 2.0, y: self.rightCloudButton.bounds.height / 2.0)
        self.rightCloudItemContainerView.userInteractionEnabled = false
        self.rightCloudButton.addSubview(self.rightCloudItemContainerView)
    }
    
    private func drawBaskets() {
        self.leftBasketAboveImageView = UIImageView(frame: CGRect(x: kLeftBasketOriginX, y: kBasketsOriginY, width: 341, height: 310))
        self.leftBasketAboveImageView.image = UIImage(named: "BasketAboveContrast")
        self.leftBasketAboveImageView.hidden = true
        self.insertSubview(self.leftBasketAboveImageView, atIndex: kBasketAboveImageViewSubviewIndex)
        self.leftBasketItemContainerView = UIView(frame: CGRect(x: 45, y: 30, width: 250, height: 200))
        self.leftBasketAboveImageView.addSubview(self.leftBasketItemContainerView)
        
        self.leftBasketBehindButton = UIButton(frame: CGRect(x: kLeftBasketOriginX, y: kBasketsOriginY, width: 341, height: 132))
        self.leftBasketBehindButton.setImage(UIImage(named: "BasketBehind"), forState: .Normal)
        self.leftBasketBehindButton.userInteractionEnabled = false
        self.leftBasketBehindButton.hidden = true
        self.insertSubview(self.leftBasketBehindButton, atIndex: kBasketBehindButtonSubviewIndex)
        
        self.leftBasketFrontButton = UIButton(frame: CGRect(x: kLeftBasketOriginX, y: kBasketsOriginY, width: 341, height: 305))
        self.leftBasketFrontButton.setImage(UIImage(named: "BasketFront"), forState: .Normal)
        self.leftBasketFrontButton.userInteractionEnabled = false
        self.leftBasketFrontButton.addTarget(self, action: "didTapLeftBasketButton:", forControlEvents: .TouchUpInside)
        self.leftBasketFrontButton.addTarget(self, action: "enableHighlightForLeftBasketButton", forControlEvents: .TouchDown)
        self.leftBasketFrontButton.addTarget(self, action: "enableHighlightForLeftBasketButton", forControlEvents: .TouchDragEnter)
        self.leftBasketFrontButton.addTarget(self, action: "disableHighlightForLeftBasketButton", forControlEvents: .TouchDragExit)
        self.leftBasketFrontButton.hidden = true
        self.insertSubview(self.leftBasketFrontButton, atIndex: kBasketFrontButtonSubviewIndex)
        
        self.rightBasketAboveButton = UIButton(frame: CGRect(x: kRightBasketOriginX, y: kBasketsOriginY, width: 341, height: 310))
        self.rightBasketAboveButton.setImage(UIImage(named: "BasketAboveContrast"), forState: .Normal)
        self.rightBasketAboveButton.addTarget(self, action: "didTapRightBasketButton:", forControlEvents: .TouchUpInside)
        self.rightBasketAboveButton.hidden = true
        self.insertSubview(self.rightBasketAboveButton, atIndex: kBasketAboveImageViewSubviewIndex)
        self.rightBasketItemContainerView = UIView(frame: CGRect(x: 45, y: 30, width: 250, height: 200))
        self.rightBasketItemContainerView.userInteractionEnabled = false
        self.rightBasketAboveButton.addSubview(self.rightBasketItemContainerView)
        
        self.rightBasketBehindImageView = UIImageView(frame: CGRect(x: kRightBasketOriginX, y: kBasketsOriginY, width: 341, height: 132))
        self.rightBasketBehindImageView.image = UIImage(named: "BasketBehind")
        self.rightBasketBehindImageView.hidden = true
        self.insertSubview(self.rightBasketBehindImageView, atIndex: kBasketBehindButtonSubviewIndex)

        self.rightBasketFrontImageView = UIImageView(frame: CGRect(x: kRightBasketOriginX, y: kBasketsOriginY, width: 341, height: 305))
        self.rightBasketFrontImageView.image = UIImage(named: "BasketFront")
        self.rightBasketFrontImageView.userInteractionEnabled = false
        self.rightBasketFrontImageView.hidden = true
        self.insertSubview(self.rightBasketFrontImageView, atIndex: kBasketFrontButtonSubviewIndex)
    }
    
    private func drawAbacuses() {
        self.leftAbacusView = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(self.leftBasketAboveImageView.frame), width: 205, height: 100))
        self.leftAbacusView.center = CGPoint(x: self.leftBasketAboveImageView.center.x, y: self.leftAbacusView.center.y)
        self.leftAbacusView.addSubview(UIImageView(image: UIImage(named: "AbacusBackground")))
        self.leftAbacusRedBeadImageViews = [UIImageView]()
        self.leftAbacusBlueBeadImageViews = [UIImageView]()
        self.leftAbacusView.hidden = true
        self.leftAbacusNumber = 0
        
        self.rightAbacusView = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(self.rightBasketAboveButton.frame), width: 205, height: 100))
        self.rightAbacusView.center = CGPoint(x: self.rightBasketAboveButton.center.x, y: self.rightAbacusView.center.y)
        self.rightAbacusView.addSubview(UIImageView(image: UIImage(named: "AbacusBackground")))
        self.rightAbacusRedBeadImageViews = [UIImageView]()
        self.rightAbacusBlueBeadImageViews = [UIImageView]()
        self.rightAbacusView.hidden = true
        self.rightAbacusNumber = 0
        
        for beadIndex in 0...19 {
            let currentRow = beadIndex / 5
            let currentColumn = beadIndex % 5
            
            let currentLeftRedBeadImageView = UIImageView(image: UIImage(named: "AbacusBeadRed"))
            let currentLeftBlueBeadImageView = UIImageView(image: UIImage(named: "AbacusBeadBlue"))
            currentLeftRedBeadImageView.center = CGPoint(x: kAbacusFirstBeadColumnOriginX + CGFloat(currentColumn * 22), y: kAbacusFirstBeadRowOriginY + CGFloat(currentRow * 24))
            currentLeftBlueBeadImageView.center = CGPoint(x: kAbacusFirstBeadColumnOriginX + CGFloat(currentColumn * 22), y: kAbacusFirstBeadRowOriginY + CGFloat(currentRow * 24))
            self.leftAbacusRedBeadImageViews.append(currentLeftRedBeadImageView)
            self.leftAbacusBlueBeadImageViews.append(currentLeftBlueBeadImageView)
            self.leftAbacusView.addSubview(currentLeftRedBeadImageView)
            self.leftAbacusView.addSubview(currentLeftBlueBeadImageView)
            
            let currentRightRedBeadImageView = UIImageView(image: UIImage(named: "AbacusBeadRed"))
            let currentRightBlueBeadImageView = UIImageView(image: UIImage(named: "AbacusBeadBlue"))
            currentRightRedBeadImageView.center = CGPoint(x: kAbacusFirstBeadColumnOriginX + CGFloat(currentColumn * 22), y: kAbacusFirstBeadRowOriginY + CGFloat(currentRow * 24))
            currentRightBlueBeadImageView.center = CGPoint(x: kAbacusFirstBeadColumnOriginX + CGFloat(currentColumn * 22), y: kAbacusFirstBeadRowOriginY + CGFloat(currentRow * 24))
            self.rightAbacusRedBeadImageViews.append(currentRightRedBeadImageView)
            self.rightAbacusBlueBeadImageViews.append(currentRightBlueBeadImageView)
            self.rightAbacusView.addSubview(currentRightRedBeadImageView)
            self.rightAbacusView.addSubview(currentRightBlueBeadImageView)
            currentLeftBlueBeadImageView.alpha = 0
            currentRightBlueBeadImageView.alpha = 0
        }
        
        self.addSubview(self.leftAbacusView)
        self.addSubview(self.rightAbacusView)
    }
    
    private func drawHidingItems() {
        self.leftHidingItemImageView = UIImageView(image: self.dataSource?.gameView(self, itemHidingImageAtBasketPosition: .Left))
        self.leftHidingItemImageView.center = self.leftBasketAboveImageView.center
        self.leftHidingItemImageView.hidden = true
        self.insertSubview(self.leftHidingItemImageView, belowSubview: self.leftBasketAboveImageView)
        
        self.rightHidingItemImageView = UIImageView(image: self.dataSource?.gameView(self, itemHidingImageAtBasketPosition: .Right))
        self.rightHidingItemImageView.center = self.rightBasketAboveButton.center
        self.rightHidingItemImageView.hidden = true
        self.insertSubview(self.rightHidingItemImageView, belowSubview: self.rightBasketAboveButton)
    }
    
    func didTapLeftCloudButton(_: UIButton) {
        self.delegate?.gameView(self, didTapCloudAtPosition: .Left)
    }
    
    func didTapRightCloudButton(_: UIButton) {
        self.delegate?.gameView(self, didTapCloudAtPosition: .Right)
    }
    
    func didTapLeftBasketButton(_: UIButton) {
        self.disableHighlightForLeftBasketButton()
        self.delegate?.gameView(self, didTapBasketAtPosition: .Left)
    }
    
    func didTapRightBasketButton(_: UIButton) {
        self.delegate?.gameView(self, didTapBasketAtPosition: .Right)
    }
    
    func enableHighlightForLeftBasketButton() {
        self.leftBasketBehindButton.highlighted = true
    }
    
    func disableHighlightForLeftBasketButton() {
        self.leftBasketBehindButton.highlighted = false
    }
    
    func didTapSpaceBarButton(_: UIButton) {
        self.delegate?.didTapSpaceBarButtonInGameView(self)
    }
    
    private func drawItemImage(itemImage: UIImage, amount: Int, inContainerView containerView: UIView) {
        let extralargeItemImageResizeRatio = sqrt(0.4 * containerView.bounds.size.width * containerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 4))
        let largeItemImageResizeRatio = sqrt(0.4 * containerView.bounds.size.width * containerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 8))
        let mediumItemImageResizeRatio = sqrt(0.4 * containerView.bounds.size.width * containerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 12))
        let smallItemImageResizeRatio = sqrt(0.4 * containerView.bounds.size.width * containerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 16))
        let extraSmallItemImageResizeRatio = sqrt(0.4 * containerView.bounds.size.width * containerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 20))
        
        let attemptLimit = 20
        var attemptLimitExceeded = false
        repeat {
            for currentExistingSubview in containerView.subviews {
                currentExistingSubview.removeFromSuperview()
            }
            attemptLimitExceeded = false
            let itemImageResizeRatio = amount <= 4 ? extralargeItemImageResizeRatio : amount <= 8 ? largeItemImageResizeRatio : amount <= 12 ? mediumItemImageResizeRatio : amount <= 16 ? smallItemImageResizeRatio : extraSmallItemImageResizeRatio
            let itemImageWidth = itemImage.size.width * CGFloat(itemImageResizeRatio), itemImageHeight = itemImage.size.height * CGFloat(itemImageResizeRatio)
            for _ in 1...amount {
                let currentItemButton = UIButton()
                var hasIntersection = false, attemptCount = 0
                repeat {
                    hasIntersection = false
                    currentItemButton.frame = CGRect(x: CGFloat(arc4random() % UInt32(containerView.frame.width - itemImageWidth)), y: CGFloat(arc4random() % UInt32(containerView.frame.height - itemImageHeight)), width: itemImageWidth, height: itemImageHeight)
                    currentItemButton.setImage(itemImage, forState: .Normal)
                    currentItemButton.userInteractionEnabled = false
                    for currentExistingSubview in containerView.subviews {
                        hasIntersection = hasIntersection || CGRectIntersectsRect(currentExistingSubview.frame, currentItemButton.frame)
                    }
                    attemptLimitExceeded = (attemptCount++ > attemptLimit)
                } while hasIntersection && (!attemptLimitExceeded)
                if (attemptLimitExceeded) {
                    break
                }
                containerView.addSubview(currentItemButton)
            }
        } while attemptLimitExceeded
    }
    
    func itemButtonDragged(itemButton: UIButton, withEvent event: UIEvent) {
        let touch = event.allTouches()?.first
        let previousLocation = touch?.previousLocationInView(itemButton)
        let location = touch?.locationInView(itemButton)
        
        var itemButtonTargetCenter = itemButton.center
        itemButtonTargetCenter.x += (location?.x)! - (previousLocation?.x)!
        itemButtonTargetCenter.y += (location?.y)! - (previousLocation?.y)!
        itemButton.center = itemButtonTargetCenter
    }
    
    func itemButtonInLeftCloudDropped(itemButton: UIButton) {
        let targetFrame = CGRect(x: self.leftBasketFrontButton.frame.origin.x, y: self.leftBasketFrontButton.frame.origin.y, width: self.leftBasketFrontButton.frame.width, height: self.leftBasketFrontButton.frame.height)
        let droppedPoint = CGPoint(x: itemButton.center.x + self.leftCloudItemContainerView.frame.origin.x + self.leftCloudButton.frame.origin.x, y: itemButton.center.y + self.leftCloudItemContainerView.frame.origin.y + self.leftCloudButton.frame.origin.y)
        
        if (CGRectContainsPoint(targetFrame, droppedPoint)) {
            itemButton.removeFromSuperview()
            self.delegate?.gameView(self, didDragAndDropItemToBasketFromCloudAtPosition: .Left)
        } else {
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                itemButton.frame.origin = self.leftCloudItemOriginalOriginPoints[itemButton.tag]
            }, completion: nil)
        }
    }
    
    func itemButtonInRightCloudDropped(itemButton: UIButton) {
        let targetFrame = CGRect(x: self.leftBasketFrontButton.frame.origin.x, y: self.leftBasketFrontButton.frame.origin.y, width: self.leftBasketFrontButton.frame.width, height: self.leftBasketFrontButton.frame.height)
        let droppedPoint = CGPoint(x: itemButton.center.x + self.rightCloudItemContainerView.frame.origin.x + self.rightCloudButton.frame.origin.x, y: itemButton.center.y + self.rightCloudItemContainerView.frame.origin.y + self.rightCloudButton.frame.origin.y)
        
        if (CGRectContainsPoint(targetFrame, droppedPoint)) {
            itemButton.removeFromSuperview()
            self.delegate?.gameView(self, didDragAndDropItemToBasketFromCloudAtPosition: .Right)
        } else {
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                itemButton.frame.origin = self.rightCloudItemOriginalOriginPoints[itemButton.tag]
            }, completion: nil)
        }
    }
    
    
    // MARK: Methods for Game View Controller
    
    func drawCloudItems() {
        let itemImage = self.dataSource?.itemImageInGameView(self)
        let leftCloudItemCount = self.dataSource?.gameView(self, numberOfItemsInCloudAtPosition: .Left)
        let rightCloudItemCount = self.dataSource?.gameView(self, numberOfItemsInCloudAtPosition: .Right)
        
        self.drawItemImage(itemImage!, amount: leftCloudItemCount!, inContainerView: self.leftCloudItemContainerView)
        self.drawItemImage(itemImage!, amount: rightCloudItemCount!, inContainerView: self.rightCloudItemContainerView)
        
        self.leftCloudItemOriginalOriginPoints = [CGPoint]()
        for currentSubview in self.leftCloudItemContainerView.subviews {
            self.leftCloudItemOriginalOriginPoints.append(currentSubview.frame.origin)
        }
        self.rightCloudItemOriginalOriginPoints = [CGPoint]()
        for currentSubview in self.rightCloudItemContainerView.subviews {
            self.rightCloudItemOriginalOriginPoints.append(currentSubview.frame.origin)
        }
    }
    
    func drawBasketItems() {
        let itemImage = self.dataSource?.itemImageInGameView(self)
        let leftBasketItemCount = self.dataSource?.gameView(self, numberOfItemsInBasketAtPosition: .Left)
        let rightBasketItemCount = self.dataSource?.gameView(self, numberOfItemsInBasketAtPosition: .Right)
        
        self.drawItemImage(itemImage!, amount: leftBasketItemCount!, inContainerView: self.leftBasketItemContainerView)
        self.drawItemImage(itemImage!, amount: rightBasketItemCount!, inContainerView: self.rightBasketItemContainerView)
        
        self.leftBasketItemOriginalOriginPoints = [CGPoint]()
        for currentSubview in self.leftBasketItemContainerView.subviews {
            self.leftBasketItemOriginalOriginPoints.append(currentSubview.frame.origin)
        }
        self.rightBasketItemOriginalOriginPoints = [CGPoint]()
        for currentSubview in self.rightBasketItemContainerView.subviews {
            self.rightBasketItemOriginalOriginPoints.append(currentSubview.frame.origin)
        }
    }
    
    func enableDragAndDropForCloudItems() {
        self.bringSubviewToFront(self.leftBasketFrontButton)
        self.leftCloudItemContainerView.userInteractionEnabled = true
        self.leftCloudButton.userInteractionEnabled = true
        self.leftCloudButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
        for i in 0...self.leftCloudItemContainerView.subviews.count - 1 {
            let currentItemButton = self.leftCloudItemContainerView.subviews[i] as! UIButton
            currentItemButton.tag = i
            currentItemButton.userInteractionEnabled = true
            currentItemButton.addTarget(self, action: "itemButtonDragged:withEvent:", forControlEvents: .TouchDragInside)
            currentItemButton.addTarget(self, action: "itemButtonDragged:withEvent:", forControlEvents: .TouchDragOutside)
            currentItemButton.addTarget(self, action: "itemButtonInLeftCloudDropped:", forControlEvents: .TouchUpInside)
            currentItemButton.addTarget(self, action: "itemButtonInLeftCloudDropped:", forControlEvents: .TouchUpOutside)
        }
        
        self.rightCloudItemContainerView.userInteractionEnabled = true
        self.rightCloudButton.userInteractionEnabled = true
        self.rightCloudButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
        for i in 0...self.rightCloudItemContainerView.subviews.count - 1 {
            let currentItemButton = self.rightCloudItemContainerView.subviews[i] as! UIButton
            currentItemButton.tag = i
            currentItemButton.userInteractionEnabled = true
            currentItemButton.addTarget(self, action: "itemButtonDragged:withEvent:", forControlEvents: .TouchDragInside)
            currentItemButton.addTarget(self, action: "itemButtonDragged:withEvent:", forControlEvents: .TouchDragOutside)
            currentItemButton.addTarget(self, action: "itemButtonInRightCloudDropped:", forControlEvents: .TouchUpInside)
            currentItemButton.addTarget(self, action: "itemButtonInRightCloudDropped:", forControlEvents: .TouchUpOutside)
        }
    }
    
    func enableUserInteractionOnBaskets() {
        self.leftBasketFrontButton.userInteractionEnabled = true
        self.rightBasketAboveButton.userInteractionEnabled = true
    }
    
    func disableUserInteractionOnBaskets() {
        self.leftBasketFrontButton.userInteractionEnabled = false
        self.rightBasketAboveButton.userInteractionEnabled = false
    }
    
    func showSpaceBar() {
        self.spaceBarButton.alpha = 0
        self.spaceBarButton.hidden = false
        UIView.animateWithDuration(0.25) { () -> Void in
            self.spaceBarButton.alpha = 1
        }
    }
    
    func hideSpaceBar() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.spaceBarButton.alpha = 0
        }) { (finished: Bool) -> Void in
            self.spaceBarButton.hidden = true
        }
    }
    
    func showBaskets() {
        self.leftBasketBehindButton.alpha = 0
        self.leftBasketBehindButton.hidden = false
        self.leftBasketFrontButton.alpha = 0
        self.leftBasketFrontButton.hidden = false
        self.rightBasketBehindImageView.alpha = 0
        self.rightBasketBehindImageView.hidden = false
        self.rightBasketFrontImageView.alpha = 0
        self.rightBasketFrontImageView.hidden = false
        UIView.animateWithDuration(0.25) { () -> Void in
            self.leftBasketBehindButton.alpha = 1
            self.leftBasketFrontButton.alpha = 1
            self.rightBasketBehindImageView.alpha = 1
            self.rightBasketFrontImageView.alpha = 1
        }
    }
    
    func hideBaskets() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.leftBasketBehindButton.alpha = 0
            self.leftBasketFrontButton.alpha = 0
            self.leftBasketAboveImageView.alpha = 0
            self.rightBasketBehindImageView.alpha = 0
            self.rightBasketFrontImageView.alpha = 0
            self.rightBasketAboveButton.alpha = 0
        }) { (finished: Bool) -> Void in
            self.leftBasketBehindButton.hidden = true
            self.leftBasketFrontButton.hidden = true
            self.leftBasketAboveImageView.hidden = true
            self.rightBasketBehindImageView.hidden = true
            self.rightBasketFrontImageView.hidden = true
            self.rightBasketAboveButton.hidden = true
        }
    }
    
    func showCloudAtPosition(cloudPosition: PMGameViewCloudPosition) {
        let cloudImageView = cloudPosition == .Left ? self.leftCloudButton : self.rightCloudButton
        cloudImageView.alpha = 0
        cloudImageView.hidden = false
        UIView.animateWithDuration(0.25) { () -> Void in
            cloudImageView.alpha = 1
        }
    }
    
    func hideCloudAtPosition(cloudPosition: PMGameViewCloudPosition) {
        let cloudImageView = cloudPosition == .Left ? self.leftCloudButton : self.rightCloudButton
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            cloudImageView.alpha = 0
        }) { (finished: Bool) -> Void in
            cloudImageView.hidden = true
        }
    }
    
    func showInteractionHint() {
        self.interactionHintLabel.alpha = 0
        self.interactionHintLabel.hidden = false
        UIView.animateWithDuration(0.25) { () -> Void in
            self.interactionHintLabel.alpha = 1
        }
    }
    
    func hideInteractionHint() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.interactionHintLabel.alpha = 0
        }) { (finished: Bool) -> Void in
            self.interactionHintLabel.hidden = true
        }
    }
    
    func showAbacusAtPosition(basketPosition: PMGameViewBasketPosition) {
        let abacusView = basketPosition == .Left ? self.leftAbacusView : self.rightAbacusView
        abacusView.alpha = 0
        abacusView.hidden = false
        UIView.animateWithDuration(0.25) { () -> Void in
            abacusView.alpha = 1
        }
    }
    
    func hideAbacusAtPosition(basketPosition: PMGameViewBasketPosition) {
        let abacusView = basketPosition == .Left ? self.leftAbacusView : self.rightAbacusView
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            abacusView.alpha = 0
        }) { (finished: Bool) -> Void in
            abacusView.hidden = true
        }
    }
    
    func moveNextItemInCloudAtPosition(cloudPosition: PMGameViewCloudPosition, withDuration duration: NSTimeInterval) -> Bool {
        let cloudContainerView = cloudPosition == .Left ? self.leftCloudItemContainerView : self.rightCloudItemContainerView
        let cloudContainerViewOrigin = CGPoint(x: (cloudContainerView.superview?.frame.origin.x)! + cloudContainerView.frame.origin.x, y: (cloudContainerView.superview?.frame.origin.y)! + cloudContainerView.frame.origin.y)
        let nextItemInCloudImageView = cloudContainerView.subviews.first
        if (nextItemInCloudImageView == nil) {
            return false
        }
        
        let animationStartPoint = (nextItemInCloudImageView?.center)!
        let animationEndPoint = CGPoint(x: kCloudItemDestinationPoint.x - cloudContainerViewOrigin.x, y: kCloudItemDestinationPoint.y - cloudContainerViewOrigin.y)
        
        nextItemInCloudImageView?.layer.position = animationStartPoint
        
        let moveToBasketAnimation = CAKeyframeAnimation(keyPath: "position")
        moveToBasketAnimation.calculationMode = kCAAnimationCubicPaced
        moveToBasketAnimation.fillMode = kCAFillModeForwards
        moveToBasketAnimation.removedOnCompletion = false
        moveToBasketAnimation.duration = duration
        let curvedPath = CGPathCreateMutable()
        CGPathMoveToPoint(curvedPath, nil, animationStartPoint.x, animationStartPoint.y)
        CGPathAddCurveToPoint(curvedPath, nil, animationEndPoint.x, animationStartPoint.y, animationEndPoint.x, animationEndPoint.y - 50, animationEndPoint.x, animationEndPoint.y);
        moveToBasketAnimation.path = curvedPath
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            nextItemInCloudImageView?.removeFromSuperview()
        }
        nextItemInCloudImageView?.layer.addAnimation(moveToBasketAnimation, forKey: "moveToBasketAnimation")
        CATransaction.commit()
        
        return true
    }
    
    func moveAllItemsInCloudAtPosition(cloudPosition: PMGameViewCloudPosition, withDuration duration: NSTimeInterval) {
        let cloudContainerView = cloudPosition == .Left ? self.leftCloudItemContainerView : self.rightCloudItemContainerView
        let cloudContainerViewOrigin = CGPoint(x: (cloudContainerView.superview?.frame.origin.x)! + cloudContainerView.frame.origin.x, y: (cloudContainerView.superview?.frame.origin.y)! + cloudContainerView.frame.origin.y)
        if (cloudContainerView.subviews.count == 0) {
            return
        }
        
        let animationEndPoint = CGPoint(x: kCloudItemDestinationPoint.x - cloudContainerViewOrigin.x, y: kCloudItemDestinationPoint.y - cloudContainerViewOrigin.y)
        
        for currentCloudItemButton in cloudContainerView.subviews {
            let currentAnimationStartPoint = currentCloudItemButton.center
            let currentMoveToBasketAnimation = CAKeyframeAnimation(keyPath: "position")
            currentMoveToBasketAnimation.calculationMode = kCAAnimationCubicPaced
            currentMoveToBasketAnimation.fillMode = kCAFillModeForwards
            currentMoveToBasketAnimation.removedOnCompletion = false
            currentMoveToBasketAnimation.duration = duration
            let curvedPath = CGPathCreateMutable()
            CGPathMoveToPoint(curvedPath, nil, currentAnimationStartPoint.x, currentAnimationStartPoint.y)
            CGPathAddCurveToPoint(curvedPath, nil, animationEndPoint.x, currentAnimationStartPoint.y, animationEndPoint.x, animationEndPoint.y - 50, animationEndPoint.x, animationEndPoint.y);
            currentMoveToBasketAnimation.path = curvedPath
            
            CATransaction.begin()
            CATransaction.setCompletionBlock { () -> Void in
                currentCloudItemButton.removeFromSuperview()
            }
            currentCloudItemButton.layer.addAnimation(currentMoveToBasketAnimation, forKey: "moveToBasketAnimation")
            CATransaction.commit()
        }
    }
    
    func restoreItemsInCloudAtPosition(cloudPosition: PMGameViewCloudPosition) {
        let itemImage = self.dataSource?.itemImageInGameView(self) as UIImage!
        let cloudContainerView = cloudPosition == .Left ? self.leftCloudItemContainerView : self.rightCloudItemContainerView
        let cloudItemOriginalOriginPoints = cloudPosition == .Left ? self.leftCloudItemOriginalOriginPoints : self.rightCloudItemOriginalOriginPoints
        
        let extralargeItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 4))
        let largeItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 8))
        let mediumItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 12))
        let smallItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 16))
        let extraSmallItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 20))
        
        let itemImageResizeRatio = cloudItemOriginalOriginPoints.count <= 4 ? extralargeItemImageResizeRatio : cloudItemOriginalOriginPoints.count <= 8 ? largeItemImageResizeRatio : cloudItemOriginalOriginPoints.count <= 12 ? mediumItemImageResizeRatio : cloudItemOriginalOriginPoints.count <= 16 ? smallItemImageResizeRatio : extraSmallItemImageResizeRatio
        for currentCloudItemOriginalOriginPoint in cloudItemOriginalOriginPoints {
            let currentCloudItemButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemImage.size.width * CGFloat(itemImageResizeRatio), height: itemImage.size.height * CGFloat(itemImageResizeRatio)))
            currentCloudItemButton.setImage(itemImage, forState: .Normal)
            currentCloudItemButton.frame.origin = currentCloudItemOriginalOriginPoint
            currentCloudItemButton.userInteractionEnabled = false
            cloudContainerView.addSubview(currentCloudItemButton)
        }
    }
    
    func restoreAllItemsInBasketToCloudsWithDuration(duration: NSTimeInterval) {
        self.bringSubviewToFront(self.leftBasketAboveImageView)
        let itemImage = self.dataSource?.itemImageInGameView(self) as UIImage!
        let leftCloudItemsCount = self.dataSource?.gameView(self, numberOfItemsInCloudAtPosition: .Left)
        for i in 0...self.leftBasketItemContainerView.subviews.count - 1 {
            let currentBasketItemButton = self.leftBasketItemContainerView.subviews[i] as! UIButton
            
            let cloudContainerView = i < leftCloudItemsCount ? self.leftCloudItemContainerView : self.rightCloudItemContainerView
            let cloudButton = i < leftCloudItemsCount ? self.leftCloudButton : self.rightCloudButton
            let cloudItemOriginalOriginPoints = i < leftCloudItemsCount ? self.leftCloudItemOriginalOriginPoints : self.rightCloudItemOriginalOriginPoints

            let extralargeItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 4))
            let largeItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 8))
            let mediumItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 12))
            let smallItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 16))
            let extraSmallItemImageResizeRatio = sqrt(0.4 * cloudContainerView.bounds.size.width * cloudContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 20))
            let itemImageResizeRatio = cloudItemOriginalOriginPoints.count <= 4 ? extralargeItemImageResizeRatio : cloudItemOriginalOriginPoints.count <= 8 ? largeItemImageResizeRatio : cloudItemOriginalOriginPoints.count <= 12 ? mediumItemImageResizeRatio : cloudItemOriginalOriginPoints.count <= 16 ? smallItemImageResizeRatio : extraSmallItemImageResizeRatio
            
            let currentItemTargetOrigin = i < leftCloudItemsCount! ? cloudItemOriginalOriginPoints[i] : cloudItemOriginalOriginPoints[i - leftCloudItemsCount!]
            let currentItemTargetSize = CGSize(width: itemImage.size.width * CGFloat(itemImageResizeRatio), height: itemImage.size.height * CGFloat(itemImageResizeRatio))

            let destinationAbsoluteX = currentItemTargetOrigin.x + cloudContainerView.frame.origin.x + cloudButton.frame.origin.x
            let originAbsoluteX = self.leftBasketItemContainerView.frame.origin.x + self.leftBasketAboveImageView.frame.origin.x
            let destinationAbsoluteY = currentItemTargetOrigin.y + cloudContainerView.frame.origin.y + cloudButton.frame.origin.y
            let originAbsoluteY = self.leftBasketItemContainerView.frame.origin.y + self.leftBasketAboveImageView.frame.origin.y
            
            let currentAnimationEndPoint = CGPoint(x: destinationAbsoluteX - originAbsoluteX, y: destinationAbsoluteY - originAbsoluteY)
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                currentBasketItemButton.frame = CGRect(origin: currentAnimationEndPoint, size: currentItemTargetSize)
            }, completion: { (finished: Bool) -> Void in
                currentBasketItemButton.hidden = true
                let currentCloudItemButton = UIButton(frame: CGRect(origin: currentItemTargetOrigin, size: currentItemTargetSize))
                currentCloudItemButton.setImage(itemImage, forState: .Normal)
                cloudContainerView.addSubview(currentCloudItemButton)
            })
        }
        for currentSubview in self.leftCloudItemContainerView.subviews {
            currentSubview.removeFromSuperview()
        }
    }
    
    func restoreAllItemsInCloudAtPosition(cloudPosition: PMGameViewCloudPosition, withDuration duration: NSTimeInterval) {
        let cloudContainerView = cloudPosition == .Left ? self.leftCloudItemContainerView : self.rightCloudItemContainerView
        if (cloudContainerView.subviews.count == 0) {
            return
        }
        let cloudButton = cloudPosition == .Left ? self.leftCloudButton : self.rightCloudButton
        self.bringSubviewToFront(cloudButton)

        let itemImage = self.dataSource?.itemImageInGameView(self) as UIImage!
        let containerViewWidth = self.leftBasketItemContainerView.bounds.size.width
        let containerViewHeight = self.leftBasketItemContainerView.bounds.size.height
        let extralargeItemImageResizeRatio = sqrt(0.4 * containerViewWidth * containerViewHeight / (itemImage.size.width * itemImage.size.height * 4))
        let largeItemImageResizeRatio = sqrt(0.4 * containerViewWidth * containerViewHeight / (itemImage.size.width * itemImage.size.height * 8))
        let mediumItemImageResizeRatio = sqrt(0.4 * containerViewWidth * containerViewHeight / (itemImage.size.width * itemImage.size.height * 12))
        let smallItemImageResizeRatio = sqrt(0.4 * containerViewWidth * containerViewHeight / (itemImage.size.width * itemImage.size.height * 16))
        let extraSmallItemImageResizeRatio = sqrt(0.4 * containerViewWidth * containerViewHeight / (itemImage.size.width * itemImage.size.height * 20))
        let itemImageResizeRatio = self.leftBasketItemOriginalOriginPoints.count <= 4 ? extralargeItemImageResizeRatio : self.leftBasketItemOriginalOriginPoints.count <= 8 ? largeItemImageResizeRatio : self.leftBasketItemOriginalOriginPoints.count <= 12 ? mediumItemImageResizeRatio : self.leftBasketItemOriginalOriginPoints.count <= 16 ? smallItemImageResizeRatio : extraSmallItemImageResizeRatio
        let basketItemSize = CGSize(width: itemImage.size.width * CGFloat(itemImageResizeRatio), height: itemImage.size.height * CGFloat(itemImageResizeRatio))

        for i in 0...cloudContainerView.subviews.count - 1 {
            let currentCloudItemButton = cloudContainerView.subviews[i] as! UIButton
            currentCloudItemButton.clipsToBounds = true

            let currentBasketItemOrigin = self.leftBasketItemOriginalOriginPoints[cloudPosition == .Left ? i : i + self.leftCloudItemOriginalOriginPoints.count]
            
            let destinationAbsoluteX = basketItemSize.width / 2.0 + currentBasketItemOrigin.x + self.leftBasketItemContainerView.frame.origin.x + self.leftBasketAboveImageView.frame.origin.x
            let containerViewAbsoluteX = cloudContainerView.frame.origin.x + cloudButton.frame.origin.x
            let destinationAbsoluteY = basketItemSize.height / 2.0 + currentBasketItemOrigin.y + self.leftBasketItemContainerView.frame.origin.y + self.leftBasketAboveImageView.frame.origin.y
            let containerViewAbsoluteY = cloudContainerView.frame.origin.y + cloudButton.frame.origin.y
            
            let currentAnimationStartPoint = currentCloudItemButton.center
            let currentAnimationEndPoint = CGPoint(x: destinationAbsoluteX - containerViewAbsoluteX, y: destinationAbsoluteY - containerViewAbsoluteY)
            
            let resizeAnimation = CABasicAnimation(keyPath: "bounds.size")
            resizeAnimation.toValue = NSValue(CGSize: basketItemSize)
            resizeAnimation.fillMode = kCAFillModeForwards
            resizeAnimation.removedOnCompletion = false
            resizeAnimation.duration = duration
            
            let restoreToBasketAnimation = CAKeyframeAnimation(keyPath: "position")
            restoreToBasketAnimation.calculationMode = kCAAnimationCubicPaced
            restoreToBasketAnimation.fillMode = kCAFillModeForwards
            restoreToBasketAnimation.removedOnCompletion = false
            restoreToBasketAnimation.duration = duration
            let curvedPath = CGPathCreateMutable()
            CGPathMoveToPoint(curvedPath, nil, currentAnimationStartPoint.x, currentAnimationStartPoint.y)
            CGPathAddCurveToPoint(curvedPath, nil, currentAnimationEndPoint.x, currentAnimationStartPoint.y, currentAnimationEndPoint.x, currentAnimationEndPoint.y - 50, currentAnimationEndPoint.x, currentAnimationEndPoint.y);
            restoreToBasketAnimation.path = curvedPath
            
            currentCloudItemButton.layer.position = currentAnimationStartPoint
            CATransaction.begin()
            CATransaction.setCompletionBlock { () -> Void in
                let currentBasketItemButton = UIButton(frame: CGRect(origin: currentBasketItemOrigin, size: basketItemSize))
                currentBasketItemButton.setImage(itemImage, forState: .Normal)
                self.leftBasketItemContainerView.addSubview(currentBasketItemButton)
                currentCloudItemButton.removeFromSuperview()
            }
            currentCloudItemButton.imageView?.layer.addAnimation(resizeAnimation, forKey: "restoreToBasketAnimation")
            currentCloudItemButton.layer.addAnimation(restoreToBasketAnimation, forKey: "restoreToBasketAnimation")
            CATransaction.commit()
        }
    }
    
    func restoreNextItemInCloudsToBasketWithDuration(duration: NSTimeInterval) -> Bool {
        let itemImage = self.dataSource?.itemImageInGameView(self) as UIImage!
        let cloudButton = self.leftCloudItemContainerView.subviews.count > 0 ? self.leftCloudButton : self.rightCloudButton
        let cloudItemContainerView = self.leftCloudItemContainerView.subviews.count > 0 ? self.leftCloudItemContainerView : self.rightCloudItemContainerView
        let nextCloudItemButton = cloudItemContainerView.subviews.first as? UIButton
        if (nextCloudItemButton == nil) {
            return false
        }
        self.bringSubviewToFront(cloudButton)
        nextCloudItemButton?.clipsToBounds = true
        
        let extralargeItemImageResizeRatio = sqrt(0.4 * self.leftBasketItemContainerView.bounds.size.width * self.leftBasketItemContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 4))
        let largeItemImageResizeRatio = sqrt(0.4 * self.leftBasketItemContainerView.bounds.size.width * self.leftBasketItemContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 8))
        let mediumItemImageResizeRatio = sqrt(0.4 * self.leftBasketItemContainerView.bounds.size.width * self.leftBasketItemContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 12))
        let smallItemImageResizeRatio = sqrt(0.4 * self.leftBasketItemContainerView.bounds.size.width * self.leftBasketItemContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 16))
        let extraSmallItemImageResizeRatio = sqrt(0.4 * self.leftBasketItemContainerView.bounds.size.width * self.leftBasketItemContainerView.bounds.size.height / (itemImage.size.width * itemImage.size.height * 20))
        let itemImageResizeRatio = self.leftBasketItemOriginalOriginPoints.count <= 4 ? extralargeItemImageResizeRatio : self.leftBasketItemOriginalOriginPoints.count <= 8 ? largeItemImageResizeRatio : self.leftBasketItemOriginalOriginPoints.count <= 12 ? mediumItemImageResizeRatio : self.leftBasketItemOriginalOriginPoints.count <= 16 ? smallItemImageResizeRatio : extraSmallItemImageResizeRatio
        
        let itemTargetSize = CGSize(width: itemImage.size.width * CGFloat(itemImageResizeRatio), height: itemImage.size.height * CGFloat(itemImageResizeRatio))
        let itemTargetOrigin = self.leftBasketItemOriginalOriginPoints[self.leftBasketItemOriginalOriginPoints.count - self.leftCloudItemContainerView.subviews.count - self.rightCloudItemContainerView.subviews.count]
        
        let destinationAbsoluteX = itemTargetSize.width / 2.0 + itemTargetOrigin.x + self.leftBasketItemContainerView.frame.origin.x + self.leftBasketAboveImageView.frame.origin.x
        let originAbsoluteX = cloudItemContainerView.frame.origin.x + cloudButton.frame.origin.x
        let destinationAbsoluteY = itemTargetSize.height / 2.0 + itemTargetOrigin.y + self.leftBasketItemContainerView.frame.origin.y + self.leftBasketAboveImageView.frame.origin.y
        let originAbsoluteY = cloudItemContainerView.frame.origin.y + cloudButton.frame.origin.y
        
        let animationStartPoint = (nextCloudItemButton?.center)!
        let animationEndPoint = CGPoint(x: destinationAbsoluteX - originAbsoluteX, y: destinationAbsoluteY - originAbsoluteY)
        
        let resizeAnimation = CABasicAnimation(keyPath: "bounds.size")
        resizeAnimation.toValue = NSValue(CGSize: itemTargetSize)
        resizeAnimation.fillMode = kCAFillModeForwards
        resizeAnimation.removedOnCompletion = false
        resizeAnimation.duration = duration
        
        let restoreToBasketAnimation = CAKeyframeAnimation(keyPath: "position")
        restoreToBasketAnimation.calculationMode = kCAAnimationCubicPaced
        restoreToBasketAnimation.fillMode = kCAFillModeForwards
        restoreToBasketAnimation.removedOnCompletion = false
        restoreToBasketAnimation.duration = duration
        let curvedPath = CGPathCreateMutable()
        CGPathMoveToPoint(curvedPath, nil, animationStartPoint.x, animationStartPoint.y)
        CGPathAddCurveToPoint(curvedPath, nil, animationEndPoint.x, animationStartPoint.y, animationEndPoint.x, animationEndPoint.y - 50, animationEndPoint.x, animationEndPoint.y);
        restoreToBasketAnimation.path = curvedPath
        
        nextCloudItemButton?.layer.position = animationStartPoint
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            let basketItemButton = UIButton(frame: CGRect(origin: itemTargetOrigin, size: itemTargetSize))
            basketItemButton.setImage(itemImage, forState: .Normal)
            self.leftBasketItemContainerView.addSubview(basketItemButton)
            nextCloudItemButton?.removeFromSuperview()
        }
        nextCloudItemButton?.imageView?.layer.addAnimation(resizeAnimation, forKey: "restoreToBasketAnimation")
        nextCloudItemButton?.layer.addAnimation(restoreToBasketAnimation, forKey: "restoreToBasketAnimation")
        CATransaction.commit()
        return true
    }
    
    func highlightNextItemInRightBasketWithDuration(duration: NSTimeInterval) {
        if (self.rightBasketItemOriginalOriginPoints.count == 0) {
            return
        }
        let currentItemButton = self.rightBasketItemContainerView.subviews[self.rightBasketItemOriginalOriginPoints.count - 1] as! UIButton
        UIView.animateWithDuration(duration / 2.0, animations: { () -> Void in
            currentItemButton.transform = CGAffineTransformMakeScale(1.5, 1.5)
        }) { (finished: Bool) -> Void in
            if (finished == true) {
                UIView.animateWithDuration(duration / 2.0, animations: { () -> Void in
                    currentItemButton.transform = CGAffineTransformMakeScale(1, 1)
                })
            }
        }
        self.rightBasketItemOriginalOriginPoints.removeLast()
    }
    
    func presentHidingItemAtBasketPosition(basketPosition: PMGameViewBasketPosition, withDuration duration: NSTimeInterval) {
        let hidingItemImageView = basketPosition == .Left ? self.leftHidingItemImageView : self.rightHidingItemImageView
        let basketAboveView = basketPosition == .Left ? self.leftBasketAboveImageView : self.rightBasketAboveButton
        let hidingItemDestinationCenter = CGPoint(x: basketPosition == .Left ? CGRectGetMaxX(basketAboveView.frame) : CGRectGetMinX(basketAboveView.frame), y: basketAboveView.center.y)
        hidingItemImageView.hidden = false
        let singleAnimationDuration = duration < 1.0 ? duration / 2.0 : 0.5
        UIView.animateWithDuration(singleAnimationDuration, animations: { () -> Void in
            hidingItemImageView.center = hidingItemDestinationCenter
        }) { (finished: Bool) -> Void in
            if (finished == true) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((duration - 2 * singleAnimationDuration) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    UIView.animateWithDuration(singleAnimationDuration, animations: { () -> Void in
                        hidingItemImageView.center = basketAboveView.center
                    }, completion: { (finished: Bool) -> Void in
                        hidingItemImageView.hidden = true
                    })
                }
            }
        }
    }
    
    func flipBasketAboveAtPosition(basketPosition: PMGameViewBasketPosition) {
        let basketAboveView = basketPosition == .Left ? self.leftBasketAboveImageView : self.rightBasketAboveButton
        let basketFrontView = basketPosition == .Left ? self.leftBasketFrontButton : self.rightBasketFrontImageView
        let basketBehindView = basketPosition == .Left ? self.leftBasketBehindButton : self.rightBasketBehindImageView
        basketAboveView.alpha = 0
        basketAboveView.hidden = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            basketAboveView.alpha = 1
            basketFrontView.alpha = 0
            basketBehindView.alpha = 0
        }) { (finished: Bool) -> Void in
            basketFrontView.hidden = true
            basketBehindView.hidden = true
        }
    }
    
    func flipBasketFrontAtPosition(basketPosition: PMGameViewBasketPosition) {
        let basketAboveView = basketPosition == .Left ? self.leftBasketAboveImageView : self.rightBasketAboveButton
        let basketFrontView = basketPosition == .Left ? self.leftBasketFrontButton : self.rightBasketFrontImageView
        let basketBehindView = basketPosition == .Left ? self.leftBasketBehindButton : self.rightBasketBehindImageView
        basketFrontView.alpha = 0
        basketFrontView.hidden = false
        basketBehindView.alpha = 0
        basketBehindView.hidden = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            basketFrontView.alpha = 1
            basketBehindView.alpha = 1
            basketAboveView.alpha = 0
        }) { (finished: Bool) -> Void in
            basketAboveView.hidden = true
        }
    }
    
    func highlightOnBasketAtPosition(basketPosition: PMGameViewBasketPosition, withDuration duration: NSTimeInterval) {
        let basketAboveView = basketPosition == .Left ? self.leftBasketAboveImageView : self.rightBasketAboveButton
        let basketAboveSnapshotView = basketAboveView.snapshotViewAfterScreenUpdates(true)
        basketAboveSnapshotView.center = basketAboveView.center
        let overlayView = UIView(frame: self.bounds)
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.0
        UIApplication.sharedApplication().keyWindow!.addSubview(overlayView)
        UIApplication.sharedApplication().keyWindow!.addSubview(basketAboveSnapshotView)
        let singleAnimationDuration = duration < 1.0 ? duration / 2.0 : 0.5
        UIView.animateWithDuration(singleAnimationDuration, animations: { () -> Void in
            overlayView.alpha = 0.7
        }) { (finished: Bool) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((duration - 2 * singleAnimationDuration) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                UIView.animateWithDuration(singleAnimationDuration, animations: { () -> Void in
                    overlayView.alpha = 0.0
                    basketAboveSnapshotView.alpha = 0.0
                }, completion: { (finished: Bool) -> Void in
                    overlayView.removeFromSuperview()
                    basketAboveSnapshotView.removeFromSuperview()
                })
            }
        }
    }
    
    func addOneInAbacusAtPosition(basketPosition: PMGameViewBasketPosition, withDuration duration: NSTimeInterval) {
        let abacusNumber = basketPosition == .Left ? self.leftAbacusNumber : self.rightAbacusNumber
        let abacusRedBeadImageViews = basketPosition == .Left ? self.leftAbacusRedBeadImageViews : self.rightAbacusRedBeadImageViews
        let abacusBlueBeadImageViews = basketPosition == .Left ? self.leftAbacusBlueBeadImageViews : self.rightAbacusBlueBeadImageViews

        if (abacusNumber >= 20) {
            return
        }
        let abacusRedBeadImageView = abacusRedBeadImageViews[abacusNumber]
        let abacusBlueBeadImageView = abacusBlueBeadImageViews[abacusNumber]
        UIView.animateWithDuration(duration) { () -> Void in
            abacusRedBeadImageView.center = CGPoint(x: abacusRedBeadImageView.center.x - self.kAbacusBeadMovementOffset, y: abacusRedBeadImageView.center.y)
            abacusBlueBeadImageView.center = CGPoint(x: abacusBlueBeadImageView.center.x - self.kAbacusBeadMovementOffset, y: abacusBlueBeadImageView.center.y)
            abacusRedBeadImageView.alpha = 0
            abacusBlueBeadImageView.alpha = 1
        }
        if (basketPosition == .Left) {
            self.leftAbacusNumber = self.leftAbacusNumber + 1
        } else {
            self.rightAbacusNumber = self.rightAbacusNumber + 1
        }
    }
    
    func minusOneInAbacusAtPosition(basketPosition: PMGameViewBasketPosition, withDuration duration: NSTimeInterval) {
        let abacusRedBeadImageViews = basketPosition == .Left ? self.leftAbacusRedBeadImageViews : self.rightAbacusRedBeadImageViews
        let abacusBlueBeadImageViews = basketPosition == .Left ? self.leftAbacusBlueBeadImageViews : self.rightAbacusBlueBeadImageViews
        
        if ((basketPosition == .Left ? self.leftAbacusNumber : self.rightAbacusNumber) <= 0) {
            return
        }
        if (basketPosition == .Left) {
            self.leftAbacusNumber = self.leftAbacusNumber - 1
        } else {
            self.rightAbacusNumber = self.rightAbacusNumber - 1
        }
        let abacusNumber = basketPosition == .Left ? self.leftAbacusNumber : self.rightAbacusNumber
        let abacusRedBeadImageView = abacusRedBeadImageViews[abacusNumber]
        let abacusBlueBeadImageView = abacusBlueBeadImageViews[abacusNumber]
        UIView.animateWithDuration(duration) { () -> Void in
            abacusRedBeadImageView.center = CGPoint(x: abacusRedBeadImageView.center.x + self.kAbacusBeadMovementOffset, y: abacusRedBeadImageView.center.y)
            abacusBlueBeadImageView.center = CGPoint(x: abacusBlueBeadImageView.center.x + self.kAbacusBeadMovementOffset, y: abacusBlueBeadImageView.center.y)
            abacusRedBeadImageView.alpha = 1
            abacusBlueBeadImageView.alpha = 0
        }
    }
    
    func setAbacusAtPosition(basketPosition: PMGameViewBasketPosition, toNumber number: Int, withDuration duration: NSTimeInterval) {
        let abacusNumber = basketPosition == .Left ? self.leftAbacusNumber : self.rightAbacusNumber
        let abacusNumberBeforeReset = Int(abacusNumber)

        if (abacusNumberBeforeReset < number) {
            for _ in 1...number - abacusNumberBeforeReset {
                self.addOneInAbacusAtPosition(basketPosition, withDuration: duration)
            }
        } else if (abacusNumberBeforeReset > number) {
            for _ in 1...abacusNumberBeforeReset - number {
                self.minusOneInAbacusAtPosition(basketPosition, withDuration: duration)
            }
        } else {
            return
        }
    }
    
    func enterIntermission() {
        self.hideInteractionHint()
        self.hideSpaceBar()
        self.hideBaskets()
        self.hideAbacusAtPosition(.Left)
        self.hideAbacusAtPosition(.Right)
        self.hideCloudAtPosition(.Left)
        self.hideCloudAtPosition(.Right)
    }
    
    func updateRoadProgressWithDuration(duration: NSTimeInterval) {
        let munduGuyTargetOriginX = kRoadProgressWidth * CGFloat((self.dataSource?.currentProgressInGameView(self))!) + kRoadProgressOriginX
        var munduGuyImageViewTargetFrame = self.munduGuyImageView.frame
        munduGuyImageViewTargetFrame.origin.x = munduGuyTargetOriginX
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.munduGuyImageView.frame = munduGuyImageViewTargetFrame
        })
    }
    
    func showTapInteractionHintOverlayOnCloud() {
        self.interactionHintOverlayView = UIView(frame: self.bounds)
        self.interactionHintOverlayView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        self.interactionHintOverlayView.alpha = 0.0
        
        let cloudInteractionHintImageView = UIImageView(image: UIImage(named: "InteractionHintCloudTap"))
        cloudInteractionHintImageView.frame = (UIApplication.sharedApplication().keyWindow?.frame)!
        self.interactionHintOverlayView.addSubview(cloudInteractionHintImageView)

        let gotItButton = UIButton(frame: CGRect(x: 0, y: 650, width: 200, height: 50))
        gotItButton.center = CGPoint(x: UIApplication.sharedApplication().keyWindow!.center.x, y: gotItButton.center.y)
        gotItButton.layer.cornerRadius = 5
        gotItButton.layer.masksToBounds = true
        gotItButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        gotItButton.setTitle("Got It!", forState: .Normal)
        gotItButton.addTarget(self, action: "hideInteractionHintOverlay", forControlEvents: .TouchUpInside)
        self.interactionHintOverlayView.addSubview(gotItButton)
        
        UIApplication.sharedApplication().keyWindow!.addSubview(self.interactionHintOverlayView)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.interactionHintOverlayView.alpha = 1.0
        })
    }
    
    func showDragAndDropInteractionHintOverlayOnCloud() {
        self.interactionHintOverlayView = UIView(frame: self.bounds)
        self.interactionHintOverlayView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        self.interactionHintOverlayView.alpha = 0.0
        
        let cloudInteractionHintImageView = UIImageView(image: UIImage(named: "InteractionHintCloudDragAndDrop"))
        cloudInteractionHintImageView.frame = (UIApplication.sharedApplication().keyWindow?.frame)!
        self.interactionHintOverlayView.addSubview(cloudInteractionHintImageView)
        
        let gotItButton = UIButton(frame: CGRect(x: 0, y: 650, width: 200, height: 50))
        gotItButton.center = CGPoint(x: UIApplication.sharedApplication().keyWindow!.center.x, y: gotItButton.center.y)
        gotItButton.layer.cornerRadius = 5
        gotItButton.layer.masksToBounds = true
        gotItButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        gotItButton.setTitle("Got It!", forState: .Normal)
        gotItButton.addTarget(self, action: "hideInteractionHintOverlay", forControlEvents: .TouchUpInside)
        self.interactionHintOverlayView.addSubview(gotItButton)
        
        UIApplication.sharedApplication().keyWindow!.addSubview(self.interactionHintOverlayView)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.interactionHintOverlayView.alpha = 1.0
        })
    }
    
    func showInteractionHintOverlayOnBaskets() {
        self.interactionHintOverlayView = UIView(frame: self.bounds)
        self.interactionHintOverlayView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        self.interactionHintOverlayView.alpha = 0.0
        
        let basketInteractionHintImageView = UIImageView(image: UIImage(named: "InteractionHintBasket"))
        basketInteractionHintImageView.frame = (UIApplication.sharedApplication().keyWindow?.frame)!
        self.interactionHintOverlayView.addSubview(basketInteractionHintImageView)
        
        let gotItButton = UIButton(frame: CGRect(x: 0, y: 650, width: 200, height: 50))
        gotItButton.center = CGPoint(x: UIApplication.sharedApplication().keyWindow!.center.x, y: gotItButton.center.y)
        gotItButton.layer.cornerRadius = 5
        gotItButton.layer.masksToBounds = true
        gotItButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        gotItButton.setTitle("Got it!", forState: .Normal)
        gotItButton.addTarget(self, action: "hideInteractionHintOverlay", forControlEvents: .TouchUpInside)
        self.interactionHintOverlayView.addSubview(gotItButton)
        
        UIApplication.sharedApplication().keyWindow!.addSubview(self.interactionHintOverlayView)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.interactionHintOverlayView.alpha = 1.0
        })
    }
    
    func hideInteractionHintOverlay() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.interactionHintOverlayView.alpha = 0.0
        }) { (finished: Bool) -> Void in
            if (finished == true) {
                self.interactionHintOverlayView.removeFromSuperview()
                self.interactionHintOverlayView = nil
            }
        }
    }
 
}
