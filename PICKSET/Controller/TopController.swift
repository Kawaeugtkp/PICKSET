//
//  TopController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/10/29.
//

import UIKit

class TopController: UICollectionViewController {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .purple
    }
}
