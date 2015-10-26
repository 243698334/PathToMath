//
//  PMExactGameViewController.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/18/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

class PMExactGameViewController: PMGameViewController {
        
    override func showInteractionHintOverlayOnCloudInGameView(gameView: PMGameView) {
        gameView.showDragAndDropInteractionHintOverlayOnCloud()
    }
    
    override func startPresentationInGameView(gameView: PMGameView) {
        super.startPresentationInGameView(gameView)
        gameView.enableDragAndDropForCloudItems()
    }
    
    override func startReviewInGameView(gameView: PMGameView, selectedBasketPosition: PMGameViewBasketPosition, correctness: Bool) {
        super.startReviewInGameView(gameView, selectedBasketPosition: selectedBasketPosition, correctness: correctness)
        if (correctness == true) {
            super.startIntermissionInGameView(gameView)
        } else {
            let reviewAudioQueuePlayer = PMAudioPlayer.queuePlayerWithSoundNames("ThereAreMore", super.itemName, "InTheOtherBasket")
            PMAudioPlayer.sharedPlayer().registerQueuePlayer(reviewAudioQueuePlayer, withCompletionBlock: nil, startPlaying: true)
            super.performGameViewAnimation({ (duration) -> Void in
                gameView.highlightOnBasketAtPosition(selectedBasketPosition == .Left ? .Right : .Left, withDuration: duration)
            }, duration: 6.0, delay: 0.0, completion: { () -> Void in
                super.startIntermissionInGameView(gameView)
            })
        }
    }
    
    override func didReceiveCloudInteraction(cloudPosition: PMGameViewCloudPosition, inGameView gameView: PMGameView) {
        super.didReceiveCloudInteraction(cloudPosition, inGameView: gameView)
        if (self.gameState != .Presentation) {
            return
        }
        let numberOfLeftCloudItems = self.problems[self.currentProblemIndex].firstTerm
        let numberOfRightCloudItems = self.problems[self.currentProblemIndex].secondTerm
        self.cloudInteractionCount = self.cloudInteractionCount + 1
        
        if (self.cloudInteractionCount == numberOfLeftCloudItems) {
            gameView.showCloudAtPosition(.Right)
        }
        
        if (self.cloudInteractionCount == numberOfLeftCloudItems + numberOfRightCloudItems) {
            self.cloudInteractionCount = 0
            gameView.hideCloudAtPosition(.Left)
            gameView.hideCloudAtPosition(.Right)
            super.startInteractionInGameView(gameView)
        }
    }

}
