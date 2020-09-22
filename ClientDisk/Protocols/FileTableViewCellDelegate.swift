//
//  FileTableViewCellDelegate.swift
//  ClientDisk
//
//  Created by Roman on 22.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation
import UIKit

protocol FileTableViewCellDelegate: class {
    func loadImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void))
}
