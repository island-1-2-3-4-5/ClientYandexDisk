//
//  TableViewCell.swift
//  MyCloudDisk
//
//  Created by Roman on 13.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    weak var delegate: FileTableViewCellDelegate?

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    
    func bindModel(_ model: StorageFiles.DiskFile, _ indexPath: IndexPath) {
        previewImage.layer.cornerRadius = 8
        previewImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        previewImage.layer.shadowColor = UIColor.black.cgColor
        previewImage.layer.shadowRadius = 4
        previewImage.layer.shadowOpacity = 0.3
        
        
        
        
        if model.type == "dir"{
        
        nameLabel.text = "Директория" + " - " + model.name
        previewImage.image = UIImage(named: "directory")

        } else {
            let size = Double(model.size ?? 0) / 1024.0 / 1024.0
            
            sizeLabel.text = String(format: "%.2f", size) + " МБ"
            nameLabel.text = "Файл" + " - " + model.name
            
            if let previewUrl = model.preview {
                delegate?.loadImage(stringUrl: previewUrl, completion: { [weak self] (image) in
                    self?.previewImage.image = image
                    let a = image!.pngData() as Data?
                    StorageFiles.storage.embeded?._embedded?.items[indexPath.row].previewImage = a
                })
            } else {
                previewImage.image = UIImage(named: "file")

            }
        }


        
        
    }
    
    
    
    // срабатывает каждый раз когда создается(переиспользуется) ячейка
    override func prepareForReuse() {
        previewImage.image = nil
        sizeLabel.text = nil
        super.prepareForReuse()
    }

}
