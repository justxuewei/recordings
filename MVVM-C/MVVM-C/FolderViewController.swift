//
// Created by XavierNiu on 2020/2/20.
// Copyright (c) 2020 Xavier Niu. All rights reserved.
//

import UIKit
import RxSwift

protocol FolderViewControllerDelegate: class {
  func didSelect(_ item: Item)
  func createRecording(in folder: Folder)
}

class FolderViewController: UITableViewController {

  weak var delegate: FolderViewControllerDelegate? = nil
  
  let viewModel = FolderViewModel()
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
