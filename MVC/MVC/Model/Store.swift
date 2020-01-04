//
//  Store.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import Foundation

final class Store {
    // an identity for a notification letting controller know the model has been updated
    static let changedNotification = Notification.Name("StoreChanged")
    // root path for user
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    // make Store become a singleton and set root path as default
    static let shared = Store(url: documentDirectory)
    
    let baseURL: URL?
    var placeholder: URL?
    // "private(set)" makes rootFolder having setter privately only, for more info please refer to [this post](https://bit.ly/36hmFyL)
    private(set) var rootFolder: Folder;
    
    init(url: URL?) {
        self.baseURL = url
        self.placeholder = nil
        
        if let u = url,
            let data = try? Data(contentsOf: u.appendingPathComponent(.storeLocation)),
            // get all items stored in this folder from store.json file
            let folder = try? JSONDecoder().decode(Folder.self, from: data) {
            // this condition will be satisfied if there are some contents in this folder already
            self.rootFolder = folder
        } else {
            // the content of root folder is empty
            self.rootFolder = Folder(name: "", uuid: UUID())
        }
        
        self.rootFolder.store = self
    }
    
    func fileURL(for recording: Recording) -> URL? {
        return baseURL?.appendingPathComponent(recording.uuid.uuidString + ".m4a") ?? placeholder
    }
    
    // save a new item
    func save(_ notifying: Item, userInfo: [AnyHashable: Any]) {
        /**
         grammer:
         - try? will return nil if "JSONEncoder().encode(rootFolder)" throws error or exception
         - try! is to disable error propagation, if an error actually is thrown, you'll get a runtime error
         
         update store.json by serializing rootFolder located at baseURL
         Question: but why is updating store.json located at the baseURL only?
        */
        if let url = baseURL, let data = try? JSONEncoder().encode(rootFolder) {
            try! data.write(to: url.appendingPathComponent(.storeLocation))
            // error handling omitted
        }
        NotificationCenter.default.post(name: Store.changedNotification, object: notifying, userInfo: userInfo)
    }
    
    func item(atUUIDPath path: [UUID]) -> Item? {
        return rootFolder.item(atUUIDPath: path[0...])
    }
    
    // remove a recording
    func removeFile(for recording: Recording) {
        if let url = fileURL(for: recording), url != placeholder {
            _ = try? FileManager.default.removeItem(at: url)
        }
    }
    
}

fileprivate extension String {
    static let storeLocation = "store.json"
}
