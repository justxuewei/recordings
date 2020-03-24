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

extension Reactive where Base == UISlider {
    
    public var maximumValue: Binder<Float> {
        return Binder(self.base, binding: { (slider: Base, value: Float) in
            slider.maximumValue = value
        })
    }
    
}

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
        viewModel.navigationTitle.bind(to: rx.title).disposed(by: disposeBag)
        viewModel.noRecording.bind(to: activeItemElements.rx.isHidden).disposed(by: disposeBag)
        viewModel.hasRecording.bind(to: noRecordingLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.timeLabelText.bind(to: progressLabel.rx.text).disposed(by: disposeBag)
        viewModel.durationLabelText.bind(to: durationLabel.rx.text).disposed(by: disposeBag)
        viewModel.sliderDuration.bind(to: progressSlider.rx.maximumValue).disposed(by: disposeBag)
        viewModel.sliderProgress.bind(to: progressSlider.rx.value).disposed(by: disposeBag)
        viewModel.playButtonTitle.bind(to: playButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.nameText.bind(to: nameTextField.rx.text).disposed(by: disposeBag)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.nameChanged(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // use `resignFirstResponder()` to lose focus
        // use `becomeFirstResponder()` to get focus
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func setProgress(_ sender: Any) {
        guard let s = sender as? UISlider else { return }
        viewModel.setProgress.onNext(TimeInterval(s.value))
    }
    
    @IBAction func play(_ sender: Any) {
        viewModel.togglePlay.onNext(())
    }
    
    // MARK: UIStateRestoring
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        // Question: try?
        guard let recording = try? viewModel.recording.value() else { return }
        coder.encode(recording.uuidPath, forKey: .uuidPathKey)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let uuidPath = coder.decodeObject(forKey: .uuidPathKey) as? [UUID],
            let recording = Store.shared.item(atUUIDPath: uuidPath) as? Recording {
            self.viewModel.recording.onNext(recording)
        }
    }
    
}

fileprivate extension String {
    static let uuidPathKey = "uuidPath"
}
