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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        recording = nil
    }
    
    @objc func storeChanged(notification: Notification) {
        guard let item = notification.object as? Item, item === recording else { return }
        updateForChangedRecording()
    }
    
    func updateForChangedRecording() {
        // create an audioPlayer
        if let r = recording, let url = r.fileURL {
            audioPlayer = Player(url: url) { [weak self] time in
                if let t = time {
                    self?.updateProgressDisplays(progress: t, duration: self?.audioPlayer?.duration ?? 0)
                } else {
                    self?.recording = nil
                }
            }
            
            // adjust UI according to status of audioPlayer
            if let ap = audioPlayer {
                updateProgressDisplays(progress: 0, duration: ap.duration)
                title = r.name
                nameTextField?.text = r.name
                activeItemElements?.isHidden = false
                noRecordingLabel?.isHidden = true
            } else {
                recording = nil
            }
        } else {
            updateProgressDisplays(progress: 0, duration: 0)
            audioPlayer = nil
            title = ""
            activeItemElements?.isHidden = true
            noRecordingLabel?.isHidden = false
        }
    }
    
    func updateProgressDisplays(progress: TimeInterval, duration: TimeInterval) {
        progressLabel?.text = timeString(progress)
        durationLabel?.text = timeString(duration)
        progressSlider?.maximumValue = Float(duration)
        progressSlider?.value = Float(progress)
        updatePlayButton()
    }
    
    func updatePlayButton() {
        if audioPlayer?.isPlaying == true {
            playButton?.setTitle(.pause, for: .normal)
        } else if audioPlayer?.isPaused == true {
            playButton?.setTitle(.pause, for: .normal)
        } else {
            playButton?.setTitle(.play, for: .normal)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let r = recording, let text = textField.text {
            r.setName(text)
            title = r.name
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        NSLog("resignFirstResponder() is fired")
        return true
    }
    
    @IBAction func setProgress(_ sender: Any) {
        guard let s = progressSlider else { return }
        audioPlayer?.setProgress(TimeInterval(s.value))
    }
    
    @IBAction func play(_ sender: Any) {
        audioPlayer?.togglePlay()
        updatePlayButton()
    }
    
    // MARK: UIStateRestoring
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(recording?.uuidPath, forKey: .uuidPathKey)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let uuidPath = coder.decodeObject(forKey: .uuidPathKey) as? [UUID], let recording = Store.shared.item(atUUIDPath: uuidPath) as? Recording {
            self.recording = recording
        }
    }
    
}

fileprivate extension String {
    static let uuidPathKey = "uuidPath"
    
    static let pause = NSLocalizedString("Pause", comment: "")
    static let resume = NSLocalizedString("Resume playing", comment: "")
    static let play = NSLocalizedString("Play", comment: "")
}
