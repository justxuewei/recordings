//
//  PlayViewModel.swift
//  MVVM-C
//
//  Created by XavierNiu on 2020/3/19.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class PlayViewModel {
    
    let recording = BehaviorSubject<Recording?>(value: nil)
    let playState: Observable<Player.State?>
    let togglePlay = PublishSubject<()>()
    let setProgress = PublishSubject<TimeInterval>()
    
    private let recordingUntilDeleted: Observable<Recording?>
    
    init() {
        /**
         Marked by Xavier:
         
         `recording` is nil in very beginning. Then `recordingUntilDeleted` should be a nil stream because you
         feed a nil to `flatMapLatest`.
         Once `recording` is not nil, `recordingUntilDeleted` should be:
         - emit the current recording --> `Observable.just(currentRecording)` completes
         - re-emit the recording if current recording was changed --> `concat(currentRecording.changeObservable.map { _ in recording })`
           completes if current recording was deleted
         - emit a nil to indicated current recording was removed
         */
        recordingUntilDeleted = recording.asObservable()
            .flatMapLatest { (recording: Recording?) -> Observable<Recording?> in
                guard let currentRecording = recording else { return Observable.just(nil) }
                return Observable.just(currentRecording)
                    // Question: Does `recording` have any changes?
                    .concat(currentRecording.changeObservable.map { _ in recording })
                    .takeUntil(currentRecording.deletedObservable)
                    .concat(Observable.just(nil))
            }
            .share(replay: 1)
        
        playState = recordingUntilDeleted
            .flatMapLatest({ [togglePlay, setProgress] (recording: Recording?) throws -> Observable<Player.State?> in
                guard let r = recording else { return Observable<Player.State?>.just(nil) }
                return Observable<Player.State?>.create({ (o: AnyObserver<Player.State?>) -> Disposable in
                    guard let url = r.fileURL,
                        let p = Player(url: url, update: { (playState) in
                            o.onNext(playState)
                        }) else {
                            o.onNext(nil)
                            return Disposables.create()
                        }
                    o.onNext(p.state)
                    let disposables = [
                        togglePlay.subscribe(onNext: {
                            p.togglePlay()
                        }),
                        setProgress.subscribe(onNext: { progress in
                            p.setProgress(progress)
                        })
                    ]
                    return Disposables.create {
                        p.cancel()
                        disposables.forEach { $0.dispose() }
                    }
                })
            })
            .share(replay: 1)
    }
    
    func nameChanged(_ name: String?) {
        guard let r = try! recording.value(), let text = name else { return }
        r.setName(text)
    }
    
    var navigationTitle: Observable<String> {
        return recordingUntilDeleted.map { $0?.name ?? "" }
    }
    
    var hasRecording: Observable<Bool> {
        return recordingUntilDeleted.map { $0 != nil }
    }
    
    var noRecording: Observable<Bool> {
        // Question: What is the role of `delay(0, scheduler: MainScheduler())`?
        return hasRecording.map { !$0 }.delay(0, scheduler: MainScheduler())
    }
    
    var progress: Observable<TimeInterval?> {
        return playState.map { $0?.currentTime }
    }
    
    var timeLabelText: Observable<String?> {
        return progress.map { $0.map(timeString) }
    }
    
    var durationLabelText: Observable<String?> {
        return playState.map { $0.map { timeString($0.duration) } }
    }
    
    var sliderDuration: Observable<Float> {
        return playState.map { $0.flatMap { Float($0.duration) } ?? 1.0 }
    }
    
    var sliderProgress: Observable<Float> {
        return playState.map { $0.flatMap { Float($0.duration) } ?? 0.0 }
    }
    
    var isPaused: Observable<Bool> {
        return playState.map { $0?.activity == .paused }
    }
    
    var isPlaying: Observable<Bool> {
        return playState.map { $0?.activity == .playing }
    }
    
    var nameText: Observable<String?> {
        return recordingUntilDeleted.map { $0?.name }
    }
    
    var playButtonTitle: Observable<String> {
        return playState.map { s in
            switch s?.activity {
            case .playing: return .pause
            case .paused: return .resume
            default: return .play
            }
        }
    }
    
}

fileprivate extension String {
    static let pause = NSLocalizedString("Pause", comment: "")
    static let resume = NSLocalizedString("Resume playing", comment: "")
    static let play = NSLocalizedString("Play", comment: "")
}
