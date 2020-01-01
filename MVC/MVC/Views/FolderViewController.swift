//
//  FolderViewController.swift
//  MVC
//
//  Created by XavierNiu on 2019/12/27.
//  Copyright © 2019 Xavier Niu. All rights reserved.
//

import UIKit

class FolderViewController: UITableViewController {
    
    /**
     the first way to get the model in a controller: 
     controller holds a model object at the begining of initialization of app
     */
    var folder: Folder = Store.shared.rootFolder {
        didSet {
            tableView.reloadData()
            if folder === folder.store?.rootFolder {
                title = .recordings
            } else {
                title = folder.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeNotification(_:)), name: Store.changedNotification, object: nil)
    }
    
    @objc func handleChangeNotification(_ notification: Notification) {
        // Handle changes to the current folder
        if let item = notification.object as? Folder, item === folder {
            let reason = notification.userInfo?[Item.changeReasonKey] as? String
            if reason == Item.removed, let nc = navigationController {
                nc.setViewControllers(nc.viewControllers.filter { $0 !== self }, animated: false)
            } else {
                folder = item
            }
        }
    }

}

fileprivate extension String {
    static let uuidPathKey = "uuidPath"
    static let showRecorder = "showRecorder"
    static let showPlayer = "showPlayer"
    static let showFolder = "showFolder"
    
    static let recordings = NSLocalizedString("Recordings", comment: "Heading for the list of recorded audio items and folders.")
    static let createFolder = NSLocalizedString("Create Folder", comment: "Header for folder creation dialog")
    static let folderName = NSLocalizedString("Folder Name", comment: "Placeholder for text field where folder name should be entered.")
    static let create = NSLocalizedString("Create", comment: "Confirm button for folder creation dialog")
}
