//
//  Recording.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import UIKit

class Recording: UIViewController {
    
    /**
     model -> controller -> view
     controller hold the Recording(model) and set nil as default
     once the model is set to arbitrary object controller will update view via updateForChangedRecording()
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
