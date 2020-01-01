//
//  Folder.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import Foundation

class Folder: Item, Codable {
    
    private(set) var contents: [Item]
    override weak var store: Store? {
        didSet {
            contents.forEach { $0.store = store }
        }
    }
    
    override init(name: String, uuid: UUID) {
        contents = []
        super.init(name: name, uuid: uuid)
    }
    
    func reSort(changedItem: Item) -> (oldIndex: Int, newIndex: Int) {
        let oldIndex = contents.firstIndex { $0 === changedItem }!
        contents.sort { $0.name < $1.name }
        let newIndex = contents.firstIndex { $0 === changedItem }!
        return (oldIndex, newIndex)
    }

}
