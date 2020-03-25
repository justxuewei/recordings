//
//  FolderViewControllerTests.swift
//  MVVM-CTests
//
//  Created by XavierNiu on 2020/3/25.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxDataSources
@testable import MVVM_C

let uuid1 = UUID()
let uuid2 = UUID()
let uuid3 = UUID()
let uuid4 = UUID()
let uuid5 = UUID()

func constructTestingStore() -> (Store, Folder, Folder) {
    let store = Store(url: nil)
    
    let folder1 = Folder(name: "Child 1", uuid: uuid1)
    let folder2 = Folder(name: "Child 2", uuid: uuid2)
    store.rootFolder.add(folder1)
    folder1.add(folder2)
    
    let recording1 = Recording(name: "Recording 1", uuid: uuid3)
    let recording2 = Recording(name: "Recording 2", uuid: uuid4)
    store.rootFolder.add(recording1)
    folder1.add(recording2)
    
    store.placeholder = Bundle(for: FolderViewControllerTests.self).url(forResource: "empty", withExtension: "m4a")!
    
    return (store, folder1, folder2)
}

class FolderViewControllerTests: XCTestCase, UINavigationControllerDelegate {

    var store: Store = Store(url: nil)
    var childFolder1: Folder = Folder(name: "", uuid: UUID())
    var childFolder2: Folder = Folder(name: "", uuid: UUID())
    var viewModel: FolderViewModel! = nil
    var contentsObserved = [[AnimatableSectionModel<Int, Item>]]()
    var titleObserverd = [String]()
    var disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        
        (store, childFolder1, childFolder2) = constructTestingStore()
        
        viewModel = FolderViewModel(initialFolder: childFolder1)
        
        viewModel.folderContents.subscribe(onNext: { [weak self] in self?.contentsObserved.append($0) }).disposed(by: disposeBag)
        viewModel.navigationTitle.subscribe(onNext: { [weak self] in self?.titleObserverd.append($0) }).disposed(by: disposeBag)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFolderContents() {
        XCTAssertEqual(contentsObserved.count, 1)
        
        guard contentsObserved.count == 1 else { XCTFail(); return }
        let sections1 = contentsObserved[0]
        guard sections1.count == 1 else { XCTFail(); return }
        let rows1 = sections1[0].items
        guard rows1.count == 2 else { XCTFail(); return }
        
        XCTAssertEqual(rows1[0], childFolder2)
        XCTAssertEqual(rows1[1].uuid, uuid4)
        
        viewModel.folder.accept(store.rootFolder)
        
        guard contentsObserved.count == 2 else { XCTFail(); return }
        let sections2 = contentsObserved[1]
        guard sections2.count == 1 else { XCTFail(); return }
        let rows2 = sections2[0].items
        guard rows2.count == 2 else { XCTFail(); return }
        
        XCTAssertEqual(rows2[0], childFolder1)
        XCTAssertEqual(rows2[1].uuid, uuid3)
    }
    
}
