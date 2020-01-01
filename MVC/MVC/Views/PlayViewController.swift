//
//  PlayViewController.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {

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
    
    func updateForChangedRecording() {
        // do something
    }
    
}
