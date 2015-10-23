//
//  PMAPlusBGameViewController.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/18/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

class PMAPlusBGameViewController: PMGameViewController {
    
    private var cloudInteractionCount: Int = 0
    
    override func showInteractionHintOverlayOnCloudInGameView(gameView: PMGameView) {
        gameView.showTapInteractionHintOverlayOnCloud()
    }
    
    override func startReviewInGameView(gameView: PMGameView, selectedBasketPosition: PMGameViewBasketPosition, correctness: Bool) {
        super.startReviewInGameView(gameView, selectedBasketPosition: selectedBasketPosition, correctness: correctness)
        let leftBasketNumber = self.problems[self.currentProblemIndex].firstTerm + self.problems[self.currentProblemIndex].secondTerm
        let rightBasketNumber = self.problems[self.currentProblemIndex].comparisonNumber
        if (correctness == true) {
            self.playReviewAudioWithCompletion(nil)
            self.performGameViewAnimation({ (duration) -> Void in
                gameView.highlightOnBasketAtPosition(leftBasketNumber > rightBasketNumber ? .Left : .Right, withDuration: duration)
            }, duration: 1.5, delay: 0.0, completion: { () -> Void in
                self.performGameViewAnimation({ (duration) -> Void in
                    gameView.highlightOnBasketAtPosition(leftBasketNumber > rightBasketNumber ? .Right : .Left, withDuration: duration)
                }, duration: 4.0, delay: 0.0, completion: { () -> Void in
                    super.startIntermissionInGameView(gameView)
                })
            })
        } else {
            self.playSoundWithName("Look")
            self.performGameViewAnimation({ (duration) -> Void in
                gameView.showCloudAtPosition(.Left)
                gameView.showCloudAtPosition(.Right)
                gameView.restoreAllItemsInBasketToCloudsWithDuration(0.5)
            }, duration: 1.0, delay: 0.0, completion: { () -> Void in
                self.performGameViewAnimation({ (duration) -> Void in
                    let firstTermAudioPlayer = PMAudioPlayer.audioPlayerWithSoundName(String(self.problems[self.currentProblemIndex].firstTerm))
                    PMAudioPlayer.sharedPlayer().registerAudioPlayer(firstTermAudioPlayer!, withCompletionBlock: nil, startPlaying: true)
                    gameView.restoreAllItemsInCloudAtPosition(.Left, withDuration: duration)
                }, duration: 0.5, delay: 0.0, completion: { () -> Void in
                    self.performGameViewAnimation({ (duration) -> Void in
                        let secondTermAudioPlayer = PMAudioPlayer.queuePlayerWithSoundNames("Plus", String(self.problems[self.currentProblemIndex].secondTerm))
                        PMAudioPlayer.sharedPlayer().registerQueuePlayer(secondTermAudioPlayer, withCompletionBlock: nil, startPlaying: true)
                        gameView.restoreAllItemsInCloudAtPosition(.Right, withDuration: 0.5)
                    }, duration: 1.0, delay: 1.0, completion: { () -> Void in
                        let sumAudioPlayer = PMAudioPlayer.queuePlayerWithSoundNames("Makes", String(leftBasketNumber))
                        PMAudioPlayer.sharedPlayer().registerQueuePlayer(sumAudioPlayer, withCompletionBlock: nil, startPlaying: true)
                        
                        self.performGameViewAnimation({ (duration) -> Void in
                            self.playReviewAudioWithCompletion(nil)
                            self.performGameViewAnimation({ (duration) -> Void in
                                gameView.highlightOnBasketAtPosition(leftBasketNumber > rightBasketNumber ? .Left : .Right, withDuration: duration)
                            }, duration: 2.0, delay: 0.0, completion: { () -> Void in
                                self.performGameViewAnimation({ (duration) -> Void in
                                    gameView.highlightOnBasketAtPosition(leftBasketNumber > rightBasketNumber ? .Right : .Left, withDuration: duration)
                                }, duration: 5.0, delay: 0.0, completion: { () -> Void in
                                    super.startIntermissionInGameView(gameView)
                                })
                            })
                        }, duration: 0.0, delay: 2.0, completion: nil)
                    })
                })
                
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
                let firstTermAudioPlayer = PMAudioPlayer.audioPlayerWithSoundName(String(self.problems[self.currentProblemIndex].firstTerm))
                PMAudioPlayer.sharedPlayer().registerAudioPlayer(firstTermAudioPlayer!, withCompletionBlock: nil, startPlaying: true)
            }, duration: 0.5, delay: 0.0, completion: { () -> Void in
                gameView.showCloudAtPosition(.Right)
            })
        } else if (cloudPosition == .Right && self.cloudInteractionCount == 1) {
            self.cloudInteractionCount = 0
            super.performGameViewAnimation({ (duration) -> Void in
                gameView.moveAllItemsInCloudAtPosition(.Right, withDuration: 0.5)
                let secondTermAudioPlayer = PMAudioPlayer.queuePlayerWithSoundNames("Plus", String(self.problems[self.currentProblemIndex].secondTerm), "Makes", String(self.problems[self.currentProblemIndex].firstTerm + self.problems[self.currentProblemIndex].secondTerm))
                PMAudioPlayer.sharedPlayer().registerQueuePlayer(secondTermAudioPlayer, withCompletionBlock: nil, startPlaying: true)
            }, duration: 2.0, delay: 0.0, completion: { () -> Void in
                gameView.hideCloudAtPosition(.Left)
                gameView.hideCloudAtPosition(.Right)
                super.startInteractionInGameView(gameView)
            })
        }
    }
    
    private func playReviewAudioWithCompletion(completion: (() -> Void)?) {
        let leftBasketNumber = self.problems[self.currentProblemIndex].firstTerm + self.problems[self.currentProblemIndex].secondTerm
        let rightBasketNumber = self.problems[self.currentProblemIndex].comparisonNumber
        
        let reviewAudioQueuePlayer = PMAudioPlayer.queuePlayerWithSoundNames(String(max(leftBasketNumber, rightBasketNumber)), "IsMoreThan", String(min(leftBasketNumber, rightBasketNumber)))
        PMAudioPlayer.sharedPlayer().registerQueuePlayer(reviewAudioQueuePlayer, withCompletionBlock: completion, startPlaying: true)
    }

}
