//
//  FileInfoViewController.swift
//  ClientDisk
//
//  Created by Roman on 16.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import UIKit

class FileInfoViewController: UIViewController {

    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var nameFile: UILabel!
    @IBOutlet weak var typeFile: UILabel!
    @IBOutlet weak var sizeFile: UILabel!
    @IBOutlet weak var createdAtFile: UILabel!
    
    var image: UIImage?
    var name: String?
    var size: Int64?
    var mimeType: String?
    var created: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

    }
    

    fileprivate func setupView() {
        
        var sizeDouble = Double(size ?? 0) / 1024.0 / 1024.0
        
        imageOutlet.image = image
        nameFile.text = "Название:" + " " + name!
        
        let type = mimeType!.components(separatedBy: "/")
        
        typeFile.text = "Тип файла:" + " " + type[type.count - 1]
        
        if sizeDouble > 1000 {
            sizeDouble /= 1024.0
            sizeFile.text = "Размер:" + " " + String(format: "%.2f", sizeDouble) + " ГБ"
            
        } else {
            sizeFile.text = "Размер:" + " " + String(format: "%.2f", sizeDouble) + " МБ"
        }
        
        
        let isoDateString = created!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime]
        let date = formatter.date(from: isoDateString)!
        
        
        createdAtFile.text = "Создан:" + " " + "\(date)"
        
        
        imageOutlet.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageOutlet.layer.shadowColor = UIColor.black.cgColor
        imageOutlet.layer.shadowRadius = 16
        imageOutlet.layer.shadowOpacity = 0.4
    }

 
     }

