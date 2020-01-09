//
//  PlayViewController.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController, UITextFieldDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var noRecordingLabel: UILabel!
    @IBOutlet weak var activeItemElements: UIStackView!
    
    var audioPlayer: Player?
    /**
     the second way to get the model in a controller:
     model(changed) -> controller -> view
     controller hold the Recording(model) and set nil as default
     once the model is set to a specific object controller will update view via updateForChangedRecording()
     */
    var recording: Recording? {
        didSet {
            updateForChangedRecording()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // question: it seems no changes happen after applied to the following lines
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        updateForChangedRecording()
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(notification:)), name: Store.changedNotification, object: nil)
    }
    
    @objc func storeChanged(notification: Notification) {
        guard let item = notification.object as? Item, item === recording else { return }
        updateForChangedRecording()
    }
    
    func updateForChangedRecording() {
        if let r = recording, let url = r.fileURL {
            audioPlayer = Player(url: url) { [weak self] time in
                if let t = time {
                    self?.updateProgressDisplays(progress: t, duration: self?.audioPlayer?.duration ?? 0)
                } else {
                    self?.recording = nil
                }
            }
        }
    }
    
    func updateProgressDisplays(progress: TimeInterval, duration: TimeInterval) {
        
    }
    
}
