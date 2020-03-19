//
// Created by XavierNiu on 2020/1/22.
// Copyright (c) 2020 Xavier Niu. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Differentiator

extension Item: IdentifiableType, Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    var identity: UUID { return uuid }
    
    /**
     Marked by Xavier:
     
     There are two situations that `changeObservable`, an observable for notification, will send a notification:
     - Current item was removed.
     - `self` is an instance of `Folder` and its sub-item has been changed.
     */
    var changeObservable: Observable<()> {
        return NotificationCenter.default.rx.notification(Store.changedNotification).filter { [weak self] (notification: Notification) -> Bool in
            guard let self = self else { return false }
            if let item = notification.object as? Item,
               item == self,
               !(notification.userInfo?[Item.changeReasonKey] as? String == Item.removed) {
                // expect for removal operation
                return true
            } else if let userInfo = notification.userInfo,
                      userInfo[Item.parentFolderKey] as? Folder == self {
                return true
            }
            return false
        }.map { _ in () }
    }
    
    var deletedObservable: Observable<()> {
        return NotificationCenter.default.rx.notification(Store.changedNotification)
          .filter { [weak self] (notification: Notification) -> Bool in
            guard let self = self else { return false }
            if let item = notification.object as? Item,
               item == self,
               notification.userInfo?[Item.changeReasonKey] as? String == Item.removed {
                return true
            }
            return false
          }
          .map { _ in () }
    }
    
}
