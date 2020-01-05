//
//  RecordViewController.swift
//  MVC
//
//  Created by XavierNiu on 2020/1/5.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import UIKit
import AVFoundation

final class RecordViewController: UIViewController {

    var audioRecorder: Recorder?
    var folder: Folder? = nil
    var recording = Recording(name: "", uuid: UUID())
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
