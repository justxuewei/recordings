//
//  Player.swift
//  MVC
//
//  Created by XavierNiu on 2020/1/5.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import Foundation
import AVFoundation

class Player: NSObject, AVAudioPlayerDelegate {
    
    enum Activity {
        case stopped
        case playing
        case paused
    }
    
    struct State {
        var currentTime: TimeInterval
        var duration: TimeInterval
        var activity: Activity
    }
    
    private var audioPlayer: AVAudioPlayer
    private var timer: Timer?
    private var update: (State?) -> ()
    
    init?(url: URL, update: @escaping (State?) -> ()) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return nil
        }
        
        if let player = try? AVAudioPlayer(contentsOf: url) {
            audioPlayer = player
            self.update = update
        } else {
            return nil
        }
        
        super.init()
        
        audioPlayer.delegate = self
    }
    
    func togglePlay() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            timer?.invalidate()
            timer = nil
            notify()
        } else {
            audioPlayer.play()
            if let t = timer {
                t.invalidate()
            }
            /**
             grammers:
             - [weak self] means self could be nil
             - [unowned self] means self will never be nil, and the program will crash if self is nil with [unowned self]
             */
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] _ in
                guard let s = self else { return }
                s.notify()
            })
        }
    }
    
    var state: State {
        return State(currentTime: audioPlayer.currentTime, duration: audioPlayer.duration, activity: activity)
    }
    
    func notify() {
        update(state)
    }
    
    func setProgress(_ time: TimeInterval) {
        audioPlayer.currentTime = time
        notify()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        timer = nil
        if flag {
            notify()
        } else {
            update(nil)
        }
    }
    
    var duration: TimeInterval {
        return audioPlayer.duration
    }
    
    var activity: Activity {
        return audioPlayer.isPlaying ? .playing : isPaused ? .paused : .stopped
    }
    
    var isPaused: Bool {
        return !audioPlayer.isPlaying && audioPlayer.currentTime > 0
    }
    
    func cancel() {
        audioPlayer.stop()
        timer?.invalidate()
    }
    
    deinit {
        cancel()
    }

}
