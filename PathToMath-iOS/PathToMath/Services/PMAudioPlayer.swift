//
//  PMAudioPlayer.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/20/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import AVFoundation

class PMAudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private static let sharedInstance = PMAudioPlayer()
    
    typealias PMAudioPlayerCompletionBlock = () -> Void
    
    private var activeQueuePlayers: [AVQueuePlayer]!
    private var activeQueuePlayerCompletionBlocks: [PMAudioPlayerCompletionBlock?]!
    
    private var activeAudioPlayers: [AVAudioPlayer]!
    private var activeAudioPlayerCompletionBlocks: [PMAudioPlayerCompletionBlock?]!
    
    private override init() {
        super.init()
        self.activeQueuePlayers = [AVQueuePlayer]()
        self.activeQueuePlayerCompletionBlocks = [PMAudioPlayerCompletionBlock?]()
        self.activeAudioPlayers = [AVAudioPlayer]()
        self.activeAudioPlayerCompletionBlocks = [PMAudioPlayerCompletionBlock?]()
    }
    
    class func sharedPlayer() -> PMAudioPlayer {
        return sharedInstance
    }
    
    class func queuePlayerWithSoundNames(soundNames: String...) -> AVQueuePlayer {
        var playerItems = [AVPlayerItem]()
        for currentSoundName: String in soundNames {
            playerItems.append(AVPlayerItem(URL: NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource(currentSoundName, ofType: "wav")!)))
        }
        return AVQueuePlayer(items: playerItems)
    }
    
    class func audioPlayerWithSoundName(soundName: String) -> AVAudioPlayer? {
        do {
            return try AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource(soundName, ofType: "wav")!))
        } catch {
            return nil
        }
    }
    
    func registerQueuePlayer(queuePlayer: AVQueuePlayer, withCompletionBlock completionBlock: PMAudioPlayerCompletionBlock?, startPlaying: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveQueuePlayerDidFinishPlayingNotification:", name: AVPlayerItemDidPlayToEndTimeNotification, object: queuePlayer.items().last)
        self.activeQueuePlayers.append(queuePlayer)
        self.activeQueuePlayerCompletionBlocks.append(completionBlock)
        if (startPlaying == true) {
            queuePlayer.play()
        }
    }
    
    func registerAudioPlayer(audioPlayer: AVAudioPlayer, withCompletionBlock completionBlock: PMAudioPlayerCompletionBlock?, startPlaying: Bool) {
        audioPlayer.delegate = self
        self.activeAudioPlayers.append(audioPlayer)
        self.activeAudioPlayerCompletionBlocks.append(completionBlock)
        if (startPlaying == true) {
            audioPlayer.play()
        }
    }
    
    func didReceiveQueuePlayerDidFinishPlayingNotification(notification: NSNotification) {
        let lastPlayerItem = notification.object as! AVPlayerItem
        //for i in 0...self.activeQueuePlayers.count - 1 {
        // TODO sometimes the queue is already empty. need to figure out why
        for var i = 0; i < self.activeQueuePlayers.count; ++i {
            let currentQueuePlayer = self.activeQueuePlayers[i]
            if (currentQueuePlayer.items().last == lastPlayerItem) {
                objc_sync_enter(self)
                self.activeQueuePlayers.removeAtIndex(i)
                let completionBlock = self.activeQueuePlayerCompletionBlocks.removeAtIndex(i)
                objc_sync_exit(self)
                if (completionBlock != nil) {
                    completionBlock!()
                }
                return
            }
        }
    }
    
    
    // MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        for i in 0...self.activeAudioPlayers.count - 1 {
            let currentActiveAudioPlayer = self.activeAudioPlayers[i]
            if (currentActiveAudioPlayer == player) {
                objc_sync_enter(self)
                self.activeAudioPlayers.removeAtIndex(i)
                let completionBlock = self.activeAudioPlayerCompletionBlocks.removeAtIndex(i)
                objc_sync_exit(self)
                if (completionBlock != nil) {
                    completionBlock!()
                }
                return
            }
        }
    }
    
}
