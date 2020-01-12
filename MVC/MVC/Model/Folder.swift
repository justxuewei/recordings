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
            // recursively notify all the sub-folders of the store
            contents.forEach { $0.store = store }
        }
    }
    
    override init(name: String, uuid: UUID) {
        contents = []
        super.init(name: name, uuid: uuid)
    }
    
    enum FolderKeys: CodingKey { case name, uuid, contents }
    enum FolderOrRecording: CodingKey { case folder, recording } // there are two types of file when serializing: sub-folder and recording file
    
    // for decoding
    required init(from decoder: Decoder) throws {
        // keys: name, uuid, contents(nested container)
        let c = try decoder.container(keyedBy: FolderKeys.self)
        contents = [Item]() // contents initialization
        var nested = try c.nestedUnkeyedContainer(forKey: .contents) // get the nested unkeyed container, that is, get the sub-folders in current folder
        while true {
            let wrapper = try nested.nestedContainer(keyedBy: FolderOrRecording.self)
            if let f = try wrapper.decodeIfPresent(Folder.self, forKey: .folder) {
                contents.append(f)
            } else if let r = try wrapper.decodeIfPresent(Recording.self, forKey: .recording) {
                contents.append(r)
            } else {
                break
            }
        }
        
        let uuid = try c.decode(UUID.self, forKey: .uuid)
        let name = try c.decode(String.self, forKey: .name)
        super.init(name: name, uuid: uuid)
        
        for c in contents {
            c.parent = self
        }
    }
    
    /**
     for encoding
     the sturcture of this class with this encoder in JSON format will be:
     {
        "name": "xxx",
        "uuid": "xxxx",
        "contents": [
            "folder": "xxxxxx",
            "recording": "xxxxxxxx",
            ...
        ]
     }
     */
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: FolderKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(uuid, forKey: .uuid)
        var nested = c.nestedUnkeyedContainer(forKey: .contents)
        for c in contents {
            var wrapper = nested.nestedContainer(keyedBy: FolderOrRecording.self)
            switch c {
            // recursive encoding folders
            case let f as Folder: try wrapper.encode(f, forKey: .folder)
            case let r as Recording: try wrapper.encode(r, forKey: .recording)
            default: break
            }
        }
        // This is for the situation that contents is empty
        _ = nested.nestedContainer(keyedBy: FolderOrRecording.self)
    }
    
    // recursively sub-item deletion
    override func deleted() {
        for item in contents {
            remove(item)
        }
        super.deleted()
    }
    
    
    /// Add a new item in this current folder, e.g. subfolder, recording.
    /// - Parameter item: A folder or recording object you want to add.
    func add(_ item: Item) {
        // prevent from duplicated folder name
        assert(contents.contains { $0 === item } == false)
        contents.append(item)
        contents.sort(by: { $0.name < $1.name })
        let newIndex = contents.firstIndex(where: { $0 === item })!
        item.parent = self
        // notify controller
        store?.save(item, userInfo: [
            Item.changeReasonKey: Item.added,
            Item.newValueKey: newIndex,
            Item.parentFolderKey: self
        ])
    }
    
    func reSort(changedItem: Item) -> (oldIndex: Int, newIndex: Int) {
        let oldIndex = contents.firstIndex { $0 === changedItem }!
        contents.sort { $0.name < $1.name }
        let newIndex = contents.firstIndex { $0 === changedItem }!
        return (oldIndex, newIndex)
    }
    
    // remove sub-folder only
    func remove(_ item: Item) {
        guard let index = contents.firstIndex(where: { $0 === item }) else { return }
        item.deleted()
        contents.remove(at: index)
        store?.save(item, userInfo: [
            Item.changeReasonKey: Item.removed,
            Item.newValueKey: index,
            Item.parentFolderKey: self
        ])
    }
    
    // get file by UUIDPath
    override func item(atUUIDPath path: ArraySlice<UUID>) -> Item? {
        // return if path.count is 1
        guard path.count > 1 else { return super.item(atUUIDPath: path) }
        // return if the root path of array of uuid is not current folder
        guard path.first == uuid else { return nil }
        let subsequent = path.dropFirst()
        guard let second = subsequent.first else { return nil }
        // get sub-folders iteratively
        return contents.first { $0.uuid == second }.flatMap { $0.item(atUUIDPath: subsequent) }
    }

}
