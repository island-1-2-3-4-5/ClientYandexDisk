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
    
    var image: UIImage?
    var name: String?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageOutlet.image = image
        nameFile.text = name
        
        imageOutlet.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageOutlet.layer.shadowColor = UIColor.black.cgColor
        imageOutlet.layer.shadowRadius = 16
        imageOutlet.layer.shadowOpacity = 0.4


    }
    

  
 
     }

