//
// Created by XavierNiu on 2020/3/13.
// Copyright (c) 2020 Xavier Niu. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class RecordViewModel {
    
    // Inputs
    var folder: Folder? = nil
    let recording = Recording(name: "", uuid: UUID())
    // where does duration be updated?
    let duration = BehaviorRelay<TimeInterval>(value: 0)
    
    // Actions
    func recordingStopped(title: String?) {
        guard let title = title else {
            recording.deleted()
            return
        }
        recording.setName(title)
        folder?.add(recording)
    }
    
    func recorderStateChanged(time: TimeInterval?) {
        if let t = time {
            duration.accept(t)
        } else {
            dismiss?()
        }
    }
    
    // Outputs
    var timeLabelText: Observable<String?> {
        return duration.asObservable().map(timeString)
    }
    
    var dismiss: (() -> ())?
    
}
