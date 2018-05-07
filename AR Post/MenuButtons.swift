//
//  MenuButtons.swift
//  AR Post
//
//  Created by yuchong xiang on 5/1/18.
//  Copyright © 2018 uw. All rights reserved.
//

import UIKit

//class OperationButton: UIButton {
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.configureButtonUI()
//    }
//
//    private func configureButtonUI() {
//        self.backgroundColor = UIColor.lightGray
//        self.tintColor = UIColor.white
//        self.layer.cornerRadius = CGFloat(13.0)
//        self.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 24)
//    }
//}

class MenuButtons: UISegmentedControl {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectedSegmentIndex = 0
    }
}


