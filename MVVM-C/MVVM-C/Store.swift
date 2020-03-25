//
//  Store.swift
//  MVVM-C
//
//  Created by XavierNiu on 2020/1/22.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import Foundation

class Store {
    
    static let changedNotification = Notification.Name("StoreChanged")
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static let shared = Store(url: documentDirectory)

    let baseURL: URL?
    var placeholder: URL?
    private(set) var rootFolder: Folder

    init(url: URL?) {
        self.baseURL = url
        self.placeholder = nil

        // decoding JSON file which stores the structure of folders
        if let u = url,
           let data = try? Data(contentsOf: u.appendingPathComponent(.storeLocation)),
           let folder = try? JSONDecoder().decode(Folder.self, from: data) {
            self.rootFolder = folder
        } else {
            self.rootFolder = Folder(name: "", uuid: UUID())
        }
        
        self.rootFolder.store = self
    }
    
    func fileURL(for recording: Recording) -> URL? {
        return baseURL?.appendingPathComponent(recording.uuid.uuidString + ".m4a") ?? placeholder
    }
    
    /**
     `save(_:userInfo:)` is to persist changes in json file and sent a notification to NotificationCenter to inform a change
     happened.
     
     Q: Why is it only encoding `rootFolder`?
     A: Because both encoding and decoding are recursively. Please refer to `encode(to:)` and `init(from:)` in `Folder.swift`.
        So, you only need to encode `rootFolder` and rewrite them to json file to save all contents when every change comes.
     */
    func save(_ notifying: Item, userInfo: [AnyHashable: Any]) {
        if let url = baseURL,
           let data = try? JSONEncoder().encode(rootFolder) {
            try! data.write(to: url.appendingPathComponent(.storeLocation))
        }
        NotificationCenter.default.post(name: Store.changedNotification, object: notifying, userInfo: userInfo)
    }
    
    func item(atUUIDPath path: [UUID]) -> Item? {
        guard let first = path.first, first == rootFolder.uuid else { return nil }
        return rootFolder.item(atUUIDPath: ArraySlice(path))
    }
    
    func removeFile(for recording: Recording) {
        if let url = fileURL(for: recording),
           url != placeholder {
            _ = try? FileManager.default.removeItem(at: url)
        }
    }

}

fileprivate extension String {
    static let storeLocation = "store.json"
}
