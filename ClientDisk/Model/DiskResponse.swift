//
//  DiskResponse.swift
//  MyCloudDisk
//
//  Created by Roman on 15.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation

struct DiskResponse: Decodable {
    
    let items: [DiskFile]? // Массив с объектами
    let limit: Int64
    let offset: Int64

}


// Тут устанавливается порядок записи объектов
struct DiskFile: Decodable {
    let name: String
    let preview: String?
    let size: Int64
    let path: String
    let type: String
    let file: String
    let media_type: String
}
