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
    
    var image: UIImage?
    var name: String?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageOutlet.image = image
        nameFile.text = name
        


        if StorageFiles.storage.embeded?._embedded?.items[indexPath!.row].media_type == "image"{
        guard let url = URL(string: (StorageFiles.storage.embeded?._embedded?.items[indexPath!.row].file)!) else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(StorageFiles.storage.token!)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self.imageOutlet.image = UIImage(data: data)
            }
        }
        task.resume()
        
        }
        

    }
    

    @IBAction func downloadAction(_ sender: UIButton) {
//        let one = FileInfoViewController()
//        
//        self.navigationController?.pushViewController(one, animated: true)

    }
    
}
