//
// Created by XavierNiu on 2020/2/20.
// Copyright (c) 2020 Xavier Niu. All rights reserved.
//

import Foundation

class Recording: Item, Codable {
  
  override init(name: String, uuid: UUID) {
    super.init(name: name, uuid: uuid)
  }
  
  var fileURL: URL? {
    return store?.fileURL(for: self)
  }
  
  override func deleted() {
    store?.removeFile(for: self)
    super.deleted()
  }
  
  enum RecordingKeys: CodingKey { case name, uuid }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RecordingKeys.self)
    let uuid = try container.decode(UUID.self, forKey: .uuid)
    let name = try container.decode(String.self, forKey: .name)
    super.init(name: name, uuid: uuid)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: RecordingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(uuid, forKey: .uuid)
  }
}
