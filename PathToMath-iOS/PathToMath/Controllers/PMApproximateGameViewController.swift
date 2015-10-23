//
//  PMApproximateGameViewController.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/18/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

class PMApproximateGameViewController: PMGameViewController {
    
    private var cloudInteractionCount: Int = 0
    
    override func showInteractionHintOverlayOnCloudInGameView(gameView: PMGameView) {
        gameView.showTapInteractionHintOverlayOnCloud()
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
        if (cloudPosition == .Left && self.cloudInteractionCount == 0) {
            self.cloudInteractionCount = self.cloudInteractionCount + 1
            super.performGameViewAnimation({ (duration) -> Void in
                gameView.moveAllItemsInCloudAtPosition(.Left, withDuration: 0.5)
            }, duration: 0.5, delay: 0.0, completion: { () -> Void in
                gameView.showCloudAtPosition(.Right)
            })
        } else if (cloudPosition == .Right && self.cloudInteractionCount == 1) {
            self.cloudInteractionCount = 0
            super.performGameViewAnimation({ (duration) -> Void in
                gameView.moveAllItemsInCloudAtPosition(.Right, withDuration: duration)
            }, duration: 0.5, delay: 0.0, completion: { () -> Void in
                gameView.hideCloudAtPosition(.Left)
                gameView.hideCloudAtPosition(.Right)
                super.startInteractionInGameView(gameView)
            })
        }
    }

}
