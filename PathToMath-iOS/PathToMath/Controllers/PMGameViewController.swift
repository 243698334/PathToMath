//
//  PMGameViewController.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/17/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import AVFoundation

let kPMGameModeApproximate = "Approximate"
let kPMGameModeExact = "Exact"
let kPMGameModeAbacus = "Abacus"
let kPMGameModeNumbers = "Numbers"
let kPMGameModeAPlusB = "A Plus B"

enum PMGameState: Int {
    case Start
    case Presentation
    case Interaction
    case Feedback
    case Review
    case Intermission
}

class PMGameViewController: UIViewController, PMProgressSummaryViewDataSource, PMProgressSummaryViewDelegate, PMGameInstructionViewDataSource, PMGameInstructionViewDelegate, PMGameViewDataSource, PMGameViewDelegate, PMSideMenuViewDataSource, PMSideMenuViewDelegate, PMEndOfGameSessionViewDelegate {
    
    var gameProgress: PMGameProgress!
    var problems: [PMProblem]!
    
    var itemName: String!
    var itemImage: UIImage!
    var itemBigImage: UIImage!
    var itemHidingLeftImage: UIImage!
    var itemHidingRightImage: UIImage!

    var gameState: PMGameState = .Start
    var currentProblemIndex: Int = 0
    var currentProblemResponse: PMProblemResponse!
    var problemResponses: [PMProblemResponse]!
    var sessionPerformance: PMSessionPerformance!
    var cloudInteractionCount: Int!
    
    private var isCurrentUserAnonymous: Bool!
    private var progressSummaryView: PMProgressSummaryView!
    private var gameInstructionView: PMGameInstructionView!
    private var gameView: PMGameView!
    private var endOfGameSessionView: PMEndOfGameSessionView!
    private var sideMenuView: PMSideMenuView!
    private var showSideMenuButton: UIButton!
    private var hideSideMenuButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.didStartCurrentSession()
    }
    
    
    // MARK: View Initializers
    
    private func loadItemForCurrentGameSession() {
        let itemNames = ["Armadillo", "Banana", "Bird", "Cashew", "Fish", "Turtle"]
        self.itemName = itemNames[Int(arc4random_uniform(UInt32(itemNames.count)))]
        self.itemImage = UIImage(named: "Item" + self.itemName)
        self.itemBigImage = UIImage(named: "Item" + self.itemName + "Big")
        self.itemHidingLeftImage = UIImage(named: "Item" + self.itemName + "HidingLeft")
        self.itemHidingRightImage = UIImage(named: "Item" + self.itemName + "HidingRight")
    }
    
    private func loadProgressSummaryView() {
        self.progressSummaryView = PMProgressSummaryView(frame: self.view.bounds)
        self.progressSummaryView.dataSource = self
        self.progressSummaryView.delegate = self
    }
    
    private func loadGameInstructionView() {
        self.gameInstructionView = PMGameInstructionView(frame: self.view.bounds)
        self.gameInstructionView.dataSource = self
        self.gameInstructionView.delegate = self
    }
    
    private func loadGameView() {
        self.gameView = PMGameView(frame: self.view.bounds)
        self.gameView.delegate = self
        self.gameView.dataSource = self
    }
    
    private func loadEndOfGameSessionView() {
        self.endOfGameSessionView = PMEndOfGameSessionView(frame: self.view.bounds)
        self.endOfGameSessionView.delegate = self
    }
    
    private func loadSideMenu() {
        self.sideMenuView = PMSideMenuView(frame: CGRect(x: -256, y: 0, width: 256, height: 768))
        self.sideMenuView.dataSource = self
        self.sideMenuView.delegate = self
    }
    
    private func loadSideMenuButtons() {
        self.showSideMenuButton = UIButton(frame: CGRect(x: 20, y: 30, width: 40, height: 40))
        self.showSideMenuButton.setImage(UIImage(named: "SideMenuShowButton"), forState: .Normal)
        self.showSideMenuButton.addTarget(self, action: "didTapShowSideMenuButton:", forControlEvents: .TouchUpInside)
        
        self.hideSideMenuButton = UIButton(frame: CGRect(x: 20, y: 30, width: 40, height: 40))
        self.hideSideMenuButton.setImage(UIImage(named: "SideMenuHideButton"), forState: .Normal)
        self.hideSideMenuButton.addTarget(self, action: "didTapHideSideMenuButton:", forControlEvents: .TouchUpInside)
    }
    
    
    // MARK: UI Effects/Animations
    
    func showInteractionHintOverlayOnCloudInGameView(gameView: PMGameView) {
        // requires override
    }
    
    func showInteractionHintOverlayOnBasketInGameView(gameView: PMGameView) {
        self.gameView.showInteractionHintOverlayOnBaskets()
    }
    
    private func showSideMenuViewAnimated(animated: Bool) {
        if (self.sideMenuView != nil) {
            return
        }
        self.loadSideMenu()
        self.sideMenuView.frame = CGRect(x: -256, y: 0, width: 256, height: 768)
        self.view.addSubview(self.sideMenuView)
        self.hideSideMenuButton.alpha = 0
        self.view.addSubview(self.hideSideMenuButton)
        
        if (self.isCurrentUserAnonymous == false) {
            PMAppSession.loadTimePlayedTodayInBackground { (timePlayedToday: NSTimeInterval) -> Void in
                let hoursPlayed = Int(timePlayedToday / 3600.0)
                let minutesPlayed = Int((timePlayedToday - Double(hoursPlayed * 3600)) / 60.0)
                self.sideMenuView.updateTimePlayedLabelWithHoursPlayed(hoursPlayed, minutesPlayed: minutesPlayed)
            }
        }
        
        if (animated == true) {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.sideMenuView.center = CGPoint(x: self.sideMenuView.center.x + 256, y: self.sideMenuView.center.y)
                self.showSideMenuButton.alpha = 0
                self.hideSideMenuButton.alpha = 1
            }, completion: { (finished: Bool) -> Void in
                self.showSideMenuButton.removeFromSuperview()
            })
        } else {
            self.hideSideMenuButton.alpha = 1
            self.sideMenuView.center = CGPoint(x: self.sideMenuView.center.x + 256, y: self.sideMenuView.center.y)
            self.showSideMenuButton.removeFromSuperview()
        }
    }
    
    private func hideSideMenuViewAnimated(animated: Bool) {
        if (self.sideMenuView == nil) {
            return
        }
        
        self.showSideMenuButton.alpha = 0
        self.view.addSubview(self.showSideMenuButton)
        
        if (animated == true) {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.sideMenuView.center = CGPoint(x: self.sideMenuView.center.x - 256, y: self.sideMenuView.center.y)
                self.hideSideMenuButton.alpha = 0
                self.showSideMenuButton.alpha = 1
            }) { (finished: Bool) -> Void in
                if (finished == true) {
                    self.showSideMenuButton.alpha = 1
                    self.sideMenuView.removeFromSuperview()
                    self.hideSideMenuButton.removeFromSuperview()
                    self.sideMenuView = nil
                }
            }
        } else {
            self.sideMenuView.center = CGPoint(x: self.sideMenuView.center.x - 256, y: self.sideMenuView.center.y)
            self.sideMenuView.removeFromSuperview()
            self.sideMenuView = nil
        }
    }
    
    private func transitionFromView(fromView: UIView, toView: UIView, completion: (() -> Void)?) {
        toView.center = CGPoint(x: self.view.center.x + self.view.bounds.width, y: self.view.center.y)
        self.view.addSubview(toView)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            fromView.center = CGPoint(x: fromView.center.x - self.view.bounds.width, y: fromView.center.y)
            toView.center = CGPoint(x: self.view.center.x, y: toView.center.y)
        }) { (finished: Bool) -> Void in
            fromView.removeFromSuperview()
            completion?()
        }
    }
    
    private func showView(view: UIView, animated: Bool, completion: (() -> Void)?) {
        if (animated == true) {
            view.alpha = 0
            self.view.addSubview(view)
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                view.alpha = 1
            }, completion: { (finished: Bool) -> Void in
                if (finished == true){
                    completion?()
                }
            })
        } else {
            self.view.addSubview(view)
            completion?()
        }
    }
    
    private func hideView(view: UIView, animated: Bool, completion: (() -> Void)?) {
        if (animated == true) {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                view.alpha = 0
            }, completion: { (finished: Bool) -> Void in
                if (finished == true) {
                    view.removeFromSuperview()
                    completion?()
                }
            })
        } else {
            view.removeFromSuperview()
            completion?()
        }
    }
    
    private func showAlertBannerView(alertBannerView: PMAlertBannerView, duration: NSTimeInterval, animated: Bool) {
        if (animated == true) {
            alertBannerView.frame = alertBannerView.hideFrame
            UIApplication.sharedApplication().keyWindow?.addSubview(alertBannerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: { () -> Void in
                alertBannerView.frame = alertBannerView.showFrame
            }, completion: { (finished: Bool) -> Void in
                if (finished == true) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                        self.hideAlertBannerView(alertBannerView, animated: animated)
                    }
                }
            })
        } else {
            UIApplication.sharedApplication().keyWindow?.addSubview(alertBannerView)
        }
    }
    
    private func hideAlertBannerView(alertBannerView: PMAlertBannerView, animated: Bool) {
        if (animated == true) {
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: { () -> Void in
                alertBannerView.frame = alertBannerView.hideFrame
            }, completion: { (finished: Bool) -> Void in
                alertBannerView.removeFromSuperview()
            })
        } else {
            alertBannerView.removeFromSuperview()
        }
    }
    
    func performGameViewAnimation(animation: (duration: NSTimeInterval) -> Void, duration: NSTimeInterval, delay: NSTimeInterval, completion: (() -> Void)?) {
        let animationDelay = Int64(delay * Double(NSEC_PER_SEC))
        let completionDelay = Int64((delay + duration) * Double(NSEC_PER_SEC))
        let tolerance = UInt64(0.1 * Double(NSEC_PER_SEC))
        
        let animationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
        dispatch_source_set_event_handler(animationTimer) { () -> Void in
            dispatch_source_cancel(animationTimer)
            animation(duration: duration)
        }
        
        let completionTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
        dispatch_source_set_event_handler(completionTimer) { () -> Void in
            dispatch_source_cancel(completionTimer)
            completion?()
        }
        
        dispatch_source_set_timer(animationTimer, dispatch_time(DISPATCH_TIME_NOW, animationDelay), DISPATCH_TIME_FOREVER, tolerance)
        dispatch_source_set_timer(completionTimer, dispatch_time(DISPATCH_TIME_NOW, completionDelay), DISPATCH_TIME_FOREVER, tolerance)
        dispatch_resume(animationTimer)
        dispatch_resume(completionTimer)
    }
    
    func didTapShowSideMenuButton(button: UIButton) {
        self.showSideMenuViewAnimated(true)
    }
    
    func didTapHideSideMenuButton(button: UIButton) {
        self.hideSideMenuViewAnimated(true)
    }
    
    
    // MARK: Game States
    
    private func didStartCurrentSession() {
        self.isCurrentUserAnonymous = PFAnonymousUtils.isLinkedWithUser(PMUser.currentUser())
        
        self.loadItemForCurrentGameSession()
        self.loadProgressSummaryView()
        self.loadGameInstructionView()
        self.loadGameView()
        self.loadSideMenuButtons()
        
        self.showView(self.progressSummaryView, animated: true, completion: nil)
        
        if (self.isCurrentUserAnonymous == false) {
            self.sessionPerformance = PMSessionPerformance()
            self.sessionPerformance.user = PMUser.currentUser()
            self.sessionPerformance.level = self.gameProgress.level
            self.sessionPerformance.totalProblems = self.problems.count
            self.sessionPerformance.responses = [PMProblemResponse]()
        }

        self.cloudInteractionCount = 0
    }
    
    private func didFinishCurrentSession() {
        if (self.isCurrentUserAnonymous == true) {
            return
        }
        
        PMProblemResponse.saveAllInBackground(self.problemResponses, block: { (success: Bool, error: NSError?) -> Void in
            if (success == false || error != nil) {
                for currentProblemResponse in self.problemResponses {
                    currentProblemResponse.saveEventually()
                }
                let networkAlertBannerView = PMAlertBannerView(style: .Warning)
                networkAlertBannerView.titleLabel.text = "No Internet connection"
                networkAlertBannerView.detailTextLabel.text = "Path To Math needs to go online to download the problems and save your progress and performance.\nPlease check your Wi-Fi or celluar data and try again."
                self.showAlertBannerView(networkAlertBannerView, duration: 10.0, animated: true)
            }
        })
        self.sessionPerformance.saveEventually()
        
        let levelUpCorrectnessPercentage = PMConfig.getCachedConfigValueWithKey(kPMConfigLevelUpCorrectnessPercentageKey) as? Float
        if (Float(self.sessionPerformance.correctProblems) / Float(self.sessionPerformance.totalProblems) >= levelUpCorrectnessPercentage) {
            if (self.gameProgress.level < 18) {
                self.gameProgress.level = self.gameProgress.level + 1
                self.gameProgress.saveEventually()
            }
        }
    }
    
    func startPresentationInGameView(gameView: PMGameView) {
        self.gameState = .Presentation
        
        self.gameView.addCloudItems()
        self.gameView.addBasketItems()
        self.gameView.showCloudAtPosition(.Left)
        self.gameView.showBaskets()
        
        if (self.currentProblemIndex < 3) {
            self.playPutItemHintAudioWithCompletion(nil)
        }
        
        if (self.currentProblemIndex < 1) {
            self.showInteractionHintOverlayOnCloudInGameView(self.gameView)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: kPMUserDefaultsHasShownInteractionHintForCurrentGameMode)
        }
        
        if (self.isCurrentUserAnonymous == false) {
            self.currentProblemResponse = PMProblemResponse()
            self.currentProblemResponse.problem = self.problems[self.currentProblemIndex]
            self.currentProblemResponse.gameMode = self.gameProgress.mode
        }
    }
    
    func startInteractionInGameView(gameView: PMGameView) {
        self.gameState = .Interaction
        
        self.gameView.flipBasketAboveAtPosition(.Right)
        self.gameView.enableUserInteractionOnBaskets()
        if (self.currentProblemIndex < 1) {
            self.showInteractionHintOverlayOnBasketInGameView(self.gameView)
        }
        self.playChooseBasketHintAudioWithCompletion(nil)
        
        if (self.isCurrentUserAnonymous == false) {
            self.currentProblemResponse.startTimestamp = NSDate()
        }
    }
    
    func startFeedbackInGameView(gameView: PMGameView, selectedBasketPosition: PMGameViewBasketPosition, correctness: Bool) {
        self.gameState = .Feedback
        
        self.gameView.flipBasketAboveAtPosition(.Left)
        self.gameView.disableUserInteractionOnBaskets()
        self.playFeedbackAudioWithCorrectness(correctness, completion: nil)
        self.performGameViewAnimation({ (duration) -> Void in
            if (correctness == true) {
                gameView.presentHidingItemAtBasketPosition(selectedBasketPosition, withDuration: 3.0)
            }
        }, duration: 3.5, delay: 0.5, completion: { () -> Void in
            self.startReviewInGameView(self.gameView, selectedBasketPosition: selectedBasketPosition, correctness: correctness)
        })
    }
    
    func startReviewInGameView(gameView: PMGameView, selectedBasketPosition: PMGameViewBasketPosition, correctness: Bool) {
        self.gameState = .Review
        // requires override
    }
    
    func startIntermissionInGameView(gameView: PMGameView) {
        self.gameState = .Interaction
        
        self.currentProblemIndex = self.currentProblemIndex + 1
        gameView.enterIntermission()
        
        if (self.currentProblemIndex == self.problems.count) {
            self.loadEndOfGameSessionView()
            self.showView(self.endOfGameSessionView, animated: true, completion: nil)
            self.didFinishCurrentSession()
        } else {
            self.playIntermissionAudioWithCompletion(nil)
            self.performGameViewAnimation({ (duration) -> Void in
                gameView.updateRoadProgressWithDuration(2.0)
            }, duration: 3.0, delay: 0.0, completion: { () -> Void in
                self.startPresentationInGameView(self.gameView)
            })
        }
    }
    
    
    // MARK: Game Interaction
    
    func didReceiveBasketSelection(selection: PMGameViewBasketPosition, inGameView gameView: PMGameView) {
        if (self.gameState != .Interaction) {
            return
        }
        let sumOfNumbers = self.problems[self.currentProblemIndex].firstTerm + self.problems[self.currentProblemIndex].secondTerm
        let correctness: Bool
        if (sumOfNumbers > self.problems[self.currentProblemIndex].comparisonNumber) {
            correctness = selection == .Left
        } else {
            correctness = selection == .Right
        }
        self.startFeedbackInGameView(self.gameView, selectedBasketPosition: selection, correctness: correctness)
        
        if (self.isCurrentUserAnonymous == false) {
            self.currentProblemResponse.finishTimestamp = NSDate()
            self.currentProblemResponse.timeElapsed = NSDate().timeIntervalSinceDate(self.currentProblemResponse.startTimestamp)
            self.currentProblemResponse.correct = correctness
            if (correctness == true) {
                self.sessionPerformance.correctProblems++
            } else {
                self.sessionPerformance.incorrectProblems++
            }
            self.sessionPerformance.responses.append(self.currentProblemResponse)
        }
    }
    
    func didReceiveCloudInteraction(cloudPosition: PMGameViewCloudPosition, inGameView gameView: PMGameView) {
        // requires override
    }
        
    func didReceiveUserInteractionInGameView(gameView: PMGameView) {
        // requires override
    }
    

    
    
    // MARK: Audio
    
    func playInstructionAudioWithCompletion(completion: (() -> Void)?) {
        let instructionAudioQueuePlayer = PMAudioPlayer.queuePlayerWithSoundNames("GetAsMany", self.itemName, "AsYouCan")
        PMAudioPlayer.sharedPlayer().registerQueuePlayer(instructionAudioQueuePlayer, withCompletionBlock: completion, startPlaying: true)
    }
    
    func playPutItemHintAudioWithCompletion(completion: (() -> Void)?) {
        let hintAudioQueuePlayer = PMAudioPlayer.queuePlayerWithSoundNames("NowPutThe", self.itemName, "InTheBasket")
        PMAudioPlayer.sharedPlayer().registerQueuePlayer(hintAudioQueuePlayer, withCompletionBlock: completion, startPlaying: true)
    }
    
    func playChooseBasketHintAudioWithCompletion(completion: (() -> Void)?) {
        let hintAudioQueuePlayer = PMAudioPlayer.queuePlayerWithSoundNames("ChooseChime", "ChooseTheBasketWithMore", self.itemName)
        PMAudioPlayer.sharedPlayer().registerQueuePlayer(hintAudioQueuePlayer, withCompletionBlock: completion, startPlaying: true)
    }
    
    func playFeedbackAudioWithCorrectness(correctness: Bool, completion: (() -> Void)?) {
        let feedbackSoundEffectName = correctness == true ? "CorrectMagic" : "WrongPwet"
        let feedbackSoundNames = correctness == true ? ["Correct1", "Correct2"] : ["Wrong1", "Wrong2", "Wrong3"]
        let feedbackNarratorSoundName = feedbackSoundNames[Int(arc4random_uniform(UInt32(feedbackSoundNames.count)))]
        
        let feedbackAudioQueuePlayer = PMAudioPlayer.queuePlayerWithSoundNames(feedbackSoundEffectName, feedbackNarratorSoundName)
        PMAudioPlayer.sharedPlayer().registerQueuePlayer(feedbackAudioQueuePlayer, withCompletionBlock: completion, startPlaying: true)
    }
    
    func playIntermissionAudioWithCompletion(completion: (() -> Void)?) {
        let intermissionAudioPlayer = PMAudioPlayer.audioPlayerWithSoundName("WalkMarimba")
        if (intermissionAudioPlayer != nil) {
            PMAudioPlayer.sharedPlayer().registerAudioPlayer(intermissionAudioPlayer!, withCompletionBlock: completion, startPlaying: true)
        }
    }
    
    func playSoundWithName(soundEffectName: String) {
        let soundEffectAudioPlayer = PMAudioPlayer.audioPlayerWithSoundName(soundEffectName)
        if (soundEffectAudioPlayer != nil) {
            PMAudioPlayer.sharedPlayer().registerAudioPlayer(soundEffectAudioPlayer!, withCompletionBlock: nil, startPlaying: true)
        }
    }
    
    
    // MARK: PMProgressSummaryViewDataSource
    
    func levelInProgressSummaryView(progressSummaryView: PMProgressSummaryView) -> Int {
        return self.gameProgress.level
    }
    
    
    // MARK: PMProgressSummaryViewDelegate
    
    func didTapContinueButtonInProgressSummaryView(progressSummaryView: PMProgressSummaryView) {
        self.transitionFromView(self.progressSummaryView, toView: self.gameInstructionView) { () -> Void in
            self.playInstructionAudioWithCompletion(nil)
            self.progressSummaryView = nil
        }
    }
    
    
    // MARK: PMGameInstructionViewDataSource
    
    func itemNameInGameInstructionView(gameInstructionView: PMGameInstructionView) -> String {
        return self.itemName.lowercaseString
    }
    
    func itemImageInGameInstructionView(gameInstructionView: PMGameInstructionView) -> UIImage {
        return self.itemBigImage
    }
    
    
    // MARK: PMGameInstructionViewDelegate
    
    func didTapContinueButtonInGameInstructionView(gameInstructionView: PMGameInstructionView) {
        self.transitionFromView(self.gameInstructionView, toView: self.gameView) { () -> Void in
            self.gameInstructionView = nil
            self.startPresentationInGameView(self.gameView)
            self.showSideMenuButton.alpha = 0
            self.view.addSubview(self.showSideMenuButton)
            UIView.animateWithDuration(0.25) { () -> Void in
                self.showSideMenuButton.alpha = 1
            }
        }
    }
    
    
    // MARK: PMGameViewDataSource
    
    func currentProgressPercentageInGameView(_: PMGameView) -> Float {
        return Float(self.currentProblemIndex) / Float(self.problems.count)
    }
    
    func gameView(gameView: PMGameView, numberOfItemsInCloudAtPosition cloudPosition: PMGameViewCloudPosition) -> Int {
        switch cloudPosition {
        case .Left:
            return self.problems[self.currentProblemIndex].firstTerm
        case .Right:
            return self.problems[self.currentProblemIndex].secondTerm
        }
    }
    
    func gameView(gameView: PMGameView, numberOfItemsInBasketAtPosition basketPosition: PMGameViewBasketPosition) -> Int {
        switch basketPosition {
        case .Left:
            return self.problems[self.currentProblemIndex].firstTerm + self.problems[self.currentProblemIndex].secondTerm
        case .Right:
            return self.problems[self.currentProblemIndex].comparisonNumber
        }
    }

    func itemImageInGameView(_: PMGameView) -> UIImage {
        return self.itemImage
    }
    
    func gameView(gameView: PMGameView, itemHidingImageAtBasketPosition basketPosition: PMGameViewBasketPosition) -> UIImage {
        switch basketPosition {
        case .Left:
            return self.itemHidingLeftImage
        case .Right:
            return self.itemHidingRightImage
        }
    }
    
    func itemNameInGameView(gameView: PMGameView) -> String {
        return self.itemName.lowercaseString
    }
    
    
    // MARK: PMGameViewDelegate
    
    func gameView(_: PMGameView, didTapBasketAtPosition basketPosition: PMGameViewBasketPosition) {
        self.didReceiveBasketSelection(basketPosition, inGameView: gameView)
    }
    
    func gameView(gameView: PMGameView, didTapCloudAtPosition cloudPosition: PMGameViewCloudPosition) {
        self.didReceiveCloudInteraction(cloudPosition, inGameView: gameView)
    }
    
    func gameView(gameView: PMGameView, didDragAndDropItemToBasketFromCloudAtPosition cloudPosition: PMGameViewCloudPosition) {
        self.didReceiveCloudInteraction(cloudPosition, inGameView: gameView)
    }
    
    
    // MARK: PMSideMenuViewDataSource
    
    func gameModeInCurrentSessionInSideMenuView(sideMenuView: PMSideMenuView) -> String {
        return self.gameProgress.mode
    }
    
    func problemIndexInCurrentSessionInSideMenuView(sideMenuView: PMSideMenuView) -> Int {
        return self.currentProblemIndex
    }
    
    func totalNumberOfProblemsInCurrentSessionInSideMenuView(sideMenuView: PMSideMenuView) -> Int {
        return self.problems.count
    }
    
    func currentUserDisplayNameInSideMenuView(sideMenuView: PMSideMenuView) -> String {
        return PMUser.currentUser()!.displayName
    }
    
    func currentUserAgeInSideMenuView(sideMenuView: PMSideMenuView) -> Int {
        return PMUser.currentUser()!.age
    }
    
    func currentUserIsGuestInSideMenuView(sideMenuView: PMSideMenuView) -> Bool {
        return self.isCurrentUserAnonymous
    }
    
    
    // MARK: PMSideMenuViewDelegate
    
    func didTapRestartSessionButtonInSideMenuView(sideMenuView: PMSideMenuView) {
        self.hideSideMenuViewAnimated(true)
        self.didStartCurrentSession()
    }
    
    func didTapMainMenuButtonInSideMenuView(sideMenuView: PMSideMenuView) {
        let mainMenuAlertController = UIAlertController(title: "Are you sure?", message: "Going back to the main menu will lose your progress of the current session.", preferredStyle: .Alert)
        mainMenuAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        mainMenuAlertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(mainMenuAlertController, animated: true, completion: nil)
    }
    
    
    // MARK: PMEndOfGameSessionViewDelegate
    
    func didTapPlayMoreButtonInEndOfGameSessionView(endOfGameSessionView: PMEndOfGameSessionView) {
        self.hideView(self.endOfGameSessionView, animated: true, completion: { () -> Void in
            self.endOfGameSessionView = nil
            self.didStartCurrentSession()
        })
    }
    
    func didTapMainMenuButtonInEndOfGameSessionView(endOfGameSessionView: PMEndOfGameSessionView) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
