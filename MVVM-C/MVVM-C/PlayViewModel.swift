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
    
    let recording = BehaviorRelay<Recording?>(value: nil)
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
        
        playState = recordingUntilDeleted.flatMapLatest({ [togglePlay, setProgress] (recording: Recording?) throws -> Observable<Player.State?> in
            guard let r = recording else { return Observable<Player.State?>.just(nil) }
            return Observable<Player.State?>.create( { (o: AnyObserver<Player.State?>) -> Disposable in
                
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
    }
    
}
