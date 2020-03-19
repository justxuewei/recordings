//
//  PlayViewController.swift
//  MVVM-C
//
//  Created by XavierNiu on 2020/3/19.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlayViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var noRecordingLabel: UILabel!
    @IBOutlet weak var activeItemElements: UIStackView!
    
    let viewModel = PlayViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
