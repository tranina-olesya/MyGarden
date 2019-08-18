//
//  UINavigationController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 12/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

extension UINavigationController {
    func designTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        navigationBar.tintColor = .white
    }
    
    func designWhite() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = .white
        navigationBar.tintColor = .darkGray
    }
}
