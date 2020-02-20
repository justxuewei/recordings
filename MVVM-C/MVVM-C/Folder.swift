//
// Created by XavierNiu on 2020/1/22.
// Copyright (c) 2020 Xavier Niu. All rights reserved.
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
  
  enum FolderKeys: CodingKey { case name, uuid, contents }
  enum FolderOrRecording: CodingKey { case folder, recording }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: FolderKeys.self)
    contents = [Item]()
    
    let name = try container.decode(String.self, forKey: .name)
    let uuid = try container.decode(UUID.self, forKey: .uuid)
    var nested = try container.nestedUnkeyedContainer(forKey: .contents)
    while true {
      let wrapper = try nested.nestedContainer(keyedBy: FolderOrRecording.self)
      print(">>> WRAPPER: \(wrapper)")
      if let folder = try wrapper.decodeIfPresent(Folder.self, forKey: .folder) {
        contents.append(folder)
      } else if let recording = try wrapper.decodeIfPresent(Recording.self, forKey: .recording) {
        contents.append(recording)
      } else {
        break
      }
    }
    
    super.init(name: name, uuid: uuid)
    
    for c in contents {
      c.parent = self
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: FolderKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(uuid, forKey: .uuid)
    var nested = container.nestedUnkeyedContainer(forKey: .contents)
    
    for c in contents {
      var wrapper = nested.nestedContainer(keyedBy: FolderOrRecording.self)
      switch c {
      case let f as Folder: try wrapper.encode(f, forKey: .folder)
      case let r as Recording: try wrapper.encode(r, forKey: .recording)
      default: break
      }
    }
    
    _ = nested.nestedContainer(keyedBy: FolderOrRecording.self)
  }
  
  override func deleted() {
    for item in contents {
      remove(item)
    }
    super.deleted()
  }
  
  func add(_ item: Item) {
    assert(contents.contains { $0 === item } == false)
    contents.append(item)
    contents.sort(by: { $0.name < $1.name })
    let newIndex = contents.firstIndex { $0 === item }!
    item.parent = self
    store?.save(item, userInfo: [
      Item.changeReasonKey: Item.added,
      Item.newValueKey: newIndex,
      Item.parentFolderKey: self
    ])
  }
  
  func reSort(changedItem: Item) -> (oldIndex: Int, newIndex: Int) {
    let oldIndex = contents.firstIndex { $0 === changedItem }!
    contents.sort(by: { $0.name < $1.name })
    let newIndex = contents.firstIndex { $0 === changedItem }!
    return (oldIndex, newIndex)
  }
  
  func remove(_ item: Item) {
    guard let index = contents.firstIndex(where: { $0 === item }) else { return }
    item.deleted()
    contents.remove(at: index)
    store?.save(item, userInfo: [
      Item.changeReasonKey: Item.removed,
      Item.oldValueKey: index,
      Item.parentFolderKey: self
    ])
  }
  
  override func item(atUUIDPath path: ArraySlice<UUID>) -> Item? {
    // "path.count == 1" means the file is in root folder
    // so pass it to the super folder
    guard path.count > 1 else { return super.item(atUUIDPath: path) }
    // check the first uuid, return if it not matches
    guard path.first == uuid else { return nil }
    let subsequent = path.dropFirst()
    guard let second = subsequent.first else { return nil }
    // search next part of path in the contents array
    return contents
      .first { $0.uuid == second }
      .flatMap { $0.item(atUUIDPath: subsequent) }
  }
}
