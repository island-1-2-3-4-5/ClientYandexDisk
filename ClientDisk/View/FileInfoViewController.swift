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
    let fileInfoViewModel = FileInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

    }
    

     func setupView() {
        imageOutlet.image = image
        nameFile.text = "Название:" + " " + name!
        typeFile.text = fileInfoViewModel.type(type: mimeType!)
        sizeFile.text = fileInfoViewModel.memorySize(size: size!)
        createdAtFile.text = fileInfoViewModel.dateFormat(created: created!)
        
        imageOutlet.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageOutlet.layer.shadowColor = UIColor.black.cgColor
        imageOutlet.layer.shadowRadius = 16
        imageOutlet.layer.shadowOpacity = 0.4
    }

 
     }

