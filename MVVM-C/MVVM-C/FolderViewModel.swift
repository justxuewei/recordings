//
// Created by XavierNiu on 2020/2/20.
// Copyright (c) 2020 Xavier Niu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator

class FolderViewModel {

  // Variable is replaced by Relays defined in RxCocoa
  let folder: BehaviorRelay<Folder>
  private let folderUntilDeleted: Observable<Folder?>
  
  init(initialFolder: Folder = Store.shared.rootFolder) {
    folder = BehaviorRelay(value: initialFolder)
    folderUntilDeleted = folder.asObservable()
      .flatMapLatest { currentFolder in
        Observable.just(currentFolder)
          .concat(currentFolder.changeObservable.map { _ in currentFolder })
          .takeUntil(currentFolder.deletedObservable)
          .concat(Observable.just(nil))
      }
      .share(replay: 1)
  }
  
  func create(folderNamed name: String?) {
    guard let name = name else { return }
    let newName = Folder(name: name, uuid: UUID())
    folder.value.add(newName)
  }
  
  func deleteItem(_ item: Item) {
    folder.value.remove(item)
  }
  
  var navigationTitle: Observable<String> {
    return folderUntilDeleted.map { folder in
      guard let f = folder else { return "" }
      return f.parent == nil ? .recordings : f.name
    }
  }
  
  var folderContents: Observable<[AnimatableSectionModel<Int, Item>]> {
    return folderUntilDeleted.map { folder in
      guard let f = folder else { return [AnimatableSectionModel(model: 0, items: [])] }
      return [AnimatableSectionModel(model: 0, items: f.contents)]
    }
  }
  
  static func text(for item: Item) -> String {
    return "\((item is Recording) ? "🔊" : "📁")  \(item.name)"
  }

}

fileprivate extension String {
  static let recordings = NSLocalizedString("Recordings", comment: "Heading for the list of recorded audio items and folders.")
}
