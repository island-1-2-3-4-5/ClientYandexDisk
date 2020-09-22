//
//  DownloadDelegate.swift
//  ClientDisk
//
//  Created by Roman on 22.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation

protocol DownloadDelegate: class {
    func handleDownloadDataChanged(url: URL)
}
