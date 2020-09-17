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
    @IBOutlet weak var downloadOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func downloadAction(_ sender: UIButton) {
//        let one = FileInfoViewController()
//        
//        self.navigationController?.pushViewController(one, animated: true)

    }
    
}
