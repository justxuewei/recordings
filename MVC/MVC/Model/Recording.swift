//
//  Recording.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import Foundation

class Recording: Item, Codable {
    
    var fileURL: URL? {
        return store?.fileURL(for: self)
    }
    
    override func deleted() {
        store?.removeFile(for: self)
        super.deleted()
    }
    
    enum RecordingKeys: CodingKey { case name, uuid }
    
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: RecordingKeys.self)
        let uuid = try c.decode(UUID.self, forKey: .uuid)
        let name = try c.decode(String.self, forKey: .name)
        super.init(name: name, uuid: uuid)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: RecordingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(uuid, forKey: .uuid)
    }
    
}
