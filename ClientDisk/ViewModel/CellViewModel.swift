//
//  CellViewModel.swift
//  ClientDisk
//
//  Created by Roman on 22.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation


class CellViewModel {
    
    
    func memorySize(size: Int64) -> String{
        
        var sizeDouble = Double(size) / 1024.0 / 1024.0
        var text = ""
        if sizeDouble > 1000 {
            sizeDouble /= 1024.0
            text = String(format: "%.2f", sizeDouble) + " ГБ"
        } else {
          text = String(format: "%.2f", sizeDouble) + " МБ"
        }
        
        return text
    }
    
    
    func type(type: String) -> String{
        let type = type.components(separatedBy: "/")
        let text = type[type.count - 1]
        return text
    }
    
}
