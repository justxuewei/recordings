//
//  Store.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import Foundation

final class Store {
    static let changedNotification = Notification.Name("StoreChanged")
    // root path for user
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    // make Store become a singleton and set root path as default
    static let shared = Store(url: documentDirectory)
    
    let baseURL: URL?;
    // "private(set)" makes rootFolder having setter privately only, for more info please refer to [this post](https://bit.ly/36hmFyL)
    private(set) var rootFolder: Folder;
    
    init(url: URL?) {
        // do something...
    }
    
    func save(_ notifying: Item, userInfo: [AnyHashable: Any]) {
        // try? will return nil if "JSONEncoder().encode(rootFolder)" throws error or exception
        if let url = baseURL, let data = try? JSONEncoder().encode(rootFolder) {
            // try! is to disable error propagation, if an error actually is thrown, you'll get a runtime error
            try! data.write(to: url.appendingPathComponent(.storeLocation))
            // error handling omitted
        }
        NotificationCenter.default.post(name: Store.changedNotification, object: notifying, userInfo: userInfo)
    }
    
}

fileprivate extension String {
    static let storeLocation = "store.json"
}
