//
//  Store.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import UIKit

final class Store: NSObject {
    
    // root path for user
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    // make Store become a singleton and set root path as default
    static let shared = Store(url: documentDirectory)
    
    init(url: URL?) {
        
    }
    
}
