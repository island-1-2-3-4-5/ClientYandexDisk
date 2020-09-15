//
//  LoginViewControllerDelegate.swift
//  MyCloudDisk
//
//  Created by Roman on 15.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation

protocol LoginViewControllerDelegate: class {
    func handleTokenChanged(token: String)
}
