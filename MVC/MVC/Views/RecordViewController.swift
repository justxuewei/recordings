//
//  RecordViewController.swift
//  MVC
//
//  Created by XavierNiu on 2020/1/5.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import UIKit
import AVFoundation

final class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioRecorder: Recorder?
    var folder: Folder? = nil
    var recording = Recording(name: "", uuid: UUID())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.text = timeString(0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // flatMap is to unwrap optional value in this case
        // more infomation you may refer to objccn-functional-swift
        audioRecorder = folder?.store?.fileURL(for: recording).flatMap { url in
            Recorder(url: url) { [weak self] time in
                if let t = time {
                    self?.timeLabel.text = timeString(t)
                } else {
                    self?.dismiss(animated: true)
                }
            }
        }
        if audioRecorder == nil {
            dismiss(animated: true)
        }
    }

    @IBAction func stop(_ sender: Any) {
        audioRecorder?.stop()
        // save the new recording acorrding to the name user inputs
        modalTextAlert(title: .saveRecording, accept: .save, placeholder: .nameForRecording) { string in
            if let title = string {
                self.recording.setName(title)
                self.folder?.add(self.recording)
            } else {
                self.recording.deleted()
            }
            self.dismiss(animated: true)
        }
    }
}

fileprivate extension String {
    static let saveRecording = NSLocalizedString("Save recording", comment: "Heading for audio recording save dialog")
    static let save = NSLocalizedString("Save", comment: "Confirm button text for audio recoding save dialog")
    static let nameForRecording = NSLocalizedString("Name for recording", comment: "Placeholder for audio recording name text field")
}
