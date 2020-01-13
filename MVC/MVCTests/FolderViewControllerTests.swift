//
//  FolderViewControllerTests.swift
//  MVCTests
//
//  Created by XavierNiu on 2020/1/13.
//  Copyright © 2020 Xavier Niu. All rights reserved.
//

import XCTest
@testable import MVC

let uuid1 = UUID()
let uuid2 = UUID()
let uuid3 = UUID()
let uuid4 = UUID()
let uuid5 = UUID()

func constructTestingStore() -> Store {
    let store = Store(url: nil)
    
    let folder1 = Folder(name: "Child 1", uuid: uuid1)
    let folder2 = Folder(name: "Child 2", uuid: uuid2)
    store.rootFolder.add(folder1)
    folder1.add(folder2)
    
    let recording1 = Recording(name: "Recording 1", uuid: uuid3)
    let recording2 = Recording(name: "Recording 2", uuid: uuid4)
    store.rootFolder.add(recording1)
    folder1.add(recording2)
    
    store.placeholder = Bundle(for: FolderViewControllerTests.self).url(forResource: "empty", withExtension: "m4a")
    
    return store
}

func constructTestingViews(store: Store, navDelegate: UINavigationControllerDelegate) -> (UIStoryboard, AppDelegate, UISplitViewController, UINavigationController, FolderViewController) {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    let navigationController = storyboard.instantiateViewController(withIdentifier: "navController") as! UINavigationController
    navigationController.delegate = navDelegate
    
    let rootFolderViewController = navigationController.viewControllers.first as! FolderViewController
    rootFolderViewController.folder = store.rootFolder
    rootFolderViewController.loadViewIfNeeded()
    
    let playViewController = storyboard.instantiateViewController(withIdentifier: "playerController")
    let detailNavigationController = UINavigationController(rootViewController: playViewController)
    let splitViewController = UISplitViewController(nibName: nil, bundle: nil)
    splitViewController.preferredDisplayMode = .allVisible
    splitViewController.viewControllers = [navigationController, detailNavigationController]
    
    let appDelegate = AppDelegate()
    let sceneDelegate = SceneDelegate()
    
    let window = UIWindow()
    sceneDelegate.window = window
    splitViewController.delegate = sceneDelegate
    window.rootViewController = splitViewController
    
    window.makeKeyAndVisible()
    
    return (storyboard, appDelegate, splitViewController, navigationController, rootFolderViewController)
}

class FolderViewControllerTests: XCTestCase, UINavigationControllerDelegate {
    
    var store: Store! = nil
    var storyboard: UIStoryboard! = nil
    var appDelegate: AppDelegate! = nil
    var splitViewController: UISplitViewController! = nil
    var navigationController: UINavigationController! = nil
    var rootFolderViewController: FolderViewController! = nil
    var ex: XCTestExpectation? = nil
    
    override func setUp() {
        super.setUp()
        
        store = constructTestingStore()
        
        let tuple = constructTestingViews(store: store, navDelegate: self)
        storyboard = tuple.0
        appDelegate = tuple.1
        splitViewController = tuple.2
        navigationController = tuple.3
        rootFolderViewController = tuple.4
    }
    
    override func tearDown() {
        store = nil
        super.tearDown()
    }
    
    func testRootFolderStartupConfiguration() {
        let viewControllers = navigationController.viewControllers
        XCTAssert(viewControllers.first as? FolderViewController == rootFolderViewController)
        
        let navigationItemTitle = rootFolderViewController.navigationItem.title
        XCTAssert(navigationItemTitle == "Recordings")
        
        let delegate = rootFolderViewController.tableView.delegate as? FolderViewController
        XCTAssert(delegate == rootFolderViewController)
        
        let dataSource = rootFolderViewController.tableView.dataSource as? FolderViewController
        XCTAssert(dataSource == rootFolderViewController)
        
        let navigationItemLeftButtonTitle = rootFolderViewController.navigationItem.leftBarButtonItem?.title
        XCTAssert(navigationItemLeftButtonTitle == "Edit")
        
        let navigationItemRightButtons = rootFolderViewController.navigationItem.rightBarButtonItems
        XCTAssert(navigationItemRightButtons?.first?.target === rootFolderViewController)
        XCTAssert(navigationItemRightButtons?.first?.action == #selector(FolderViewController.createNewRecording(_:)))
        XCTAssert(navigationItemRightButtons?.last?.target === rootFolderViewController)
        XCTAssert(navigationItemRightButtons?.last?.action == #selector(FolderViewController.createNewFolder(_:)))
    }
    
    func testRootTableViewLayout() {
        let sectionsCount = rootFolderViewController.numberOfSections(in: rootFolderViewController.tableView)
        XCTAssert(sectionsCount == 1)
        
        let sectionZeroRowCount = rootFolderViewController.tableView(rootFolderViewController.tableView, numberOfRowsInSection: 0)
        XCTAssert(sectionZeroRowCount == 2)
        
        let firstCell = rootFolderViewController.tableView(rootFolderViewController.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(firstCell.textLabel?.text == "📁 Child 1")
        
        let secondCell = rootFolderViewController.tableView(rootFolderViewController.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(secondCell.textLabel!.text == "🔊 Recording 1")
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        NSLog("navigationController")
        ex?.fulfill()
        ex = nil
    }
    
    func testSelectedFolder() {
        ex = expectation(description: "Wait for segue")
        rootFolderViewController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        rootFolderViewController.performSegue(withIdentifier: "showFolder", sender: nil)
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual((navigationController.viewControllers.last as? FolderViewController)?.folder.uuid, uuid1)
    }
    
}
