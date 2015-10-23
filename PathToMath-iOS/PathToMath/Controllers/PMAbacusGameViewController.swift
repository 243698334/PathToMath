//
//  PMAbacusGameViewController.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/18/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

class PMAbacusGameViewController: PMGameViewController {

    private var cloudInteractionCount: Int = 0
    
    override func showInteractionHintOverlayOnCloudInGameView(gameView: PMGameView) {
        gameView.showDragAndDropInteractionHintOverlayOnCloud()
    }
    
    override func startPresentationInGameView(gameView: PMGameView) {
        super.startPresentationInGameView(gameView)
        gameView.enableDragAndDropForCloudItems()
        gameView.setAbacusAtPosition(.Left, toNumber: 0, withDuration: 0.0)
        gameView.showAbacusAtPosition(.Left)
    }
    
    override func startInteractionInGameView(gameView: PMGameView) {
        super.startInteractionInGameView(gameView)
        gameView.setAbacusAtPosition(.Right, toNumber: 0, withDuration: 0.0)
        gameView.showAbacusAtPosition(.Right)
    }
    
    override func startFeedbackInGameView(gameView: PMGameView, selectedBasketPosition: PMGameViewBasketPosition, correctness: Bool) {
        super.startFeedbackInGameView(gameView, selectedBasketPosition: selectedBasketPosition, correctness: correctness)
        gameView.setAbacusAtPosition(.Right, toNumber: self.problems[self.currentProblemIndex].comparisonNumber, withDuration: 0.5)
    }

    override func startReviewInGameView(gameView: PMGameView, selectedBasketPosition: PMGameViewBasketPosition, correctness: Bool) {
        super.startReviewInGameView(gameView, selectedBasketPosition: selectedBasketPosition, correctness: correctness)
        let leftBasketNumber = self.problems[self.currentProblemIndex].firstTerm + self.problems[self.currentProblemIndex].secondTerm
        let rightBasketNumber = self.problems[self.currentProblemIndex].comparisonNumber
        
        var animationDelay = 0.0
        if (correctness == false) {
            self.playSoundWithName("Look")
            self.performGameViewAnimation({ (duration) -> Void in
                gameView.showCloudAtPosition(.Left)
                gameView.showCloudAtPosition(.Right)
                gameView.restoreAllItemsInBasketToCloudsWithDuration(0.5)
                gameView.setAbacusAtPosition(.Left, toNumber: 0, withDuration: 0.5)
            }, duration: 1.0, delay: animationDelay, completion: nil)
            
            animationDelay += 1.0
            for _ in 1...leftBasketNumber {
                animationDelay += 1.0
                self.performGameViewAnimation({ (duration) -> Void in
                    gameView.restoreNextItemInCloudsToBasketWithDuration(0.5)
                    gameView.addOneInAbacusAtPosition(.Left, withDuration: duration)
                    self.playSoundWithName("AbacusSlide")
                }, duration: 1.0, delay: animationDelay, completion: nil)
            }
            
            animationDelay += 1.0
            self.performGameViewAnimation({ (duration) -> Void in
                gameView.setAbacusAtPosition(.Right, toNumber: 0, withDuration: duration)
            }, duration: 0.5, delay: animationDelay, completion: nil)
            
            for _ in 1...rightBasketNumber {
                animationDelay += 1.0
                self.performGameViewAnimation({ (duration) -> Void in
                    gameView.highlightNextItemInRightBasketWithDuration(0.5)
                    gameView.addOneInAbacusAtPosition(.Right, withDuration: 0.5)
                    super.playSoundWithName("AbacusSlide")
                }, duration: 1.0, delay: animationDelay, completion: nil)
            }
            
            animationDelay += 2.0
        }
        
        self.performGameViewAnimation({ (duration) -> Void in
            let reviewAudioQueuePlayer = PMAudioPlayer.queuePlayerWithSoundNames(String(max(leftBasketNumber, rightBasketNumber)), "IsMoreThan", String(min(leftBasketNumber, rightBasketNumber)))
            PMAudioPlayer.sharedPlayer().registerQueuePlayer(reviewAudioQueuePlayer, withCompletionBlock: nil, startPlaying: true)
            gameView.highlightOnBasketAtPosition(leftBasketNumber > rightBasketNumber ? .Left : .Right, withDuration: duration)
        }, duration: 1.5, delay: animationDelay, completion: { () -> Void in
            self.performGameViewAnimation({ (duration) -> Void in
                gameView.highlightOnBasketAtPosition(leftBasketNumber > rightBasketNumber ? .Right : .Left, withDuration: duration)
            }, duration: 4.0, delay: 0.0, completion: { () -> Void in
                super.startIntermissionInGameView(gameView)
            })
        })
    }
    
    override func didReceiveCloudInteraction(cloudPosition: PMGameViewCloudPosition, inGameView gameView: PMGameView) {
        super.didReceiveCloudInteraction(cloudPosition, inGameView: gameView)
        if (self.gameState != .Presentation) {
            return
        }
        let numberOfLeftCloudItems = self.problems[self.currentProblemIndex].firstTerm
        let numberOfRightCloudItems = self.problems[self.currentProblemIndex].secondTerm
        self.cloudInteractionCount = self.cloudInteractionCount + 1
        gameView.addOneInAbacusAtPosition(.Left, withDuration: 0.5)
        super.playSoundWithName("AbacusSlide")
        
        if (self.cloudInteractionCount == numberOfLeftCloudItems) {
            gameView.showCloudAtPosition(.Right)
        }
        
        if (self.cloudInteractionCount == numberOfLeftCloudItems + numberOfRightCloudItems) {
            self.cloudInteractionCount = 0
            gameView.hideCloudAtPosition(.Left)
            gameView.hideCloudAtPosition(.Right)
            self.startInteractionInGameView(gameView)
        }
    }
    
    
}
