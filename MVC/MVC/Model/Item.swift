//
//  Item.swift
//  MVC
//
//  Created by XavierNiu on 2020/1/1.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import Foundation

class Item: NSObject {
    
    let uuid: UUID
    private(set) var name: String
    weak var store: Store?
    weak var parent: Folder? {
        didSet {
            store = parent?.store
        }
    }
    
    init(name: String, uuid: UUID) {
        self.name = name
        self.uuid = uuid
        self.store = nil
    }
    
    func setName(_ newName: String) {
        name = newName
        if let p = parent {
            let (oldIndex, newIndex) = p.reSort(changedItem: self)
            store?.save(self, userInfo: [Item.changeReasonKey: Item.renamed, Item.oldValueKey: oldIndex, Item.newValueKey: newIndex, Item.parentFolderKey: p])
        }
    }

}

extension Item {
    static let changeReasonKey = "reason"
    static let newValueKey = "newValue"
    static let oldValueKey = "oldValue"
    static let parentFolderKey = "parentFolder"
    static let renamed = "renamed"
    static let added = "added"
    static let removed = "removed"
}
