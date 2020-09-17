//
//  DiskResponse.swift
//  MyCloudDisk
//
//  Created by Roman on 15.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation

 class StorageFiles {

static var storage = StorageFiles()
    
    var embeded: Embebed?
    var token: String?
    
struct Embebed: Codable {
    var _embedded: DiskResponse?
    var path: String
    let name: String
}

struct DiskResponse: Codable {
    
    var items: [DiskFile] // Массив с объектами
    let limit: Int64
    let offset: Int64

}


// Тут устанавливается порядок записи объектов
struct DiskFile: Codable {
    let name: String
    let path: String
    let type: String
    let preview: String?
    let size: Int64?
    let file: String?
    let media_type: String?
}
}
