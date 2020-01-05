//
//  Recorder.swift
//  MVC
//
//  Created by XavierNiu on 2020/1/5.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import Foundation
import AVFoundation

class Recorder: NSObject, AVAudioRecorderDelegate {
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var update: (TimeInterval?) -> ()
    let url: URL?
    
    init?(url: URL, update: @escaping (TimeInterval?) -> ()) {
        self.update = update
        self.url = url
        
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            AVAudioSession.sharedInstance().requestRecordPermission({ allowed in
                if allowed {
                    self.start(url)
                } else {
                    self.update(nil)
                }
            })
        } catch {
            return nil
        }
    }
    
    private func start(_ url: URL) {
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0 as Float,
            AVNumberOfChannelsKey: 1
        ]
        if let recorder = try? AVAudioRecorder(url: url, settings: settings) {
            recorder.delegate = self
            audioRecorder = recorder
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.update(self.audioRecorder?.currentTime)
            })
        } else {
            update(nil)
        }
    }
    
    func stop() {
        audioRecorder?.stop()
        timer?.invalidate()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            stop()
        } else {
            update(nil)
        }
    }
    
}
