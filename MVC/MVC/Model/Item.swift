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
    
    var uuidPath: [UUID] {
        // ?? is nil-coalescing operation which unwraps the left-hand side
        // if it has a value or returns the right-hand side as a default
        var path = parent?.uuidPath ?? []
        path.append(uuid)
        return path
    }
    
    // test whether first element of ArraySlice matchs with uuid in this object, if so return self
    func item(atUUIDPath path: ArraySlice<UUID>) -> Item? {
        guard let first = path.first, first == uuid else { return nil }
        return self
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
