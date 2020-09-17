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
    @IBOutlet weak var label: UILabel!
    
    
    func bindModel(_ model: StorageFiles.DiskFile) {
        
        if model.type == "dir"{
        
        label.text = "Директория" + " - " + model.name

        } else {
            label.text = "Файл" + " - " + model.name

        }
        if let previewUrl = model.preview {
            delegate?.loadImage(stringUrl: previewUrl, completion: { [weak self] (image) in
                self?.previewImage.image = image
            })
        }

        
        
    }
    
    
    
    // срабатывает каждый раз когда создается(переиспользуется) ячейка
    override func prepareForReuse() {
        previewImage.image = nil
        super.prepareForReuse()
    }

}
