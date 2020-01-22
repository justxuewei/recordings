//
//  Store.swift
//  MVVM-C
//
//  Created by XavierNiu on 2020/1/22.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import Foundation

class Store: NSObject {
    
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
    }

}

fileprivate extension String {
    static let storeLocation = "store.json"
}
