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
    var cellViewModel = CellViewModel()
    

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    //MARK: Заполнение ячейки
    func bindModel(_ model: StorageFiles.DiskFile, _ indexPath: IndexPath) {
        previewImage.layer.cornerRadius = 8
        previewImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        previewImage.layer.shadowColor = UIColor.black.cgColor
        previewImage.layer.shadowRadius = 4
        previewImage.layer.shadowOpacity = 0.3
        

        if model.type == "dir"{
            
        nameLabel.text = model.name
        previewImage.image = UIImage(named: "directory")

        } else {
            
        sizeLabel.text = cellViewModel.memorySize(size: model.size!)
        nameLabel.text = model.name
        typeLabel.text = cellViewModel.type(type: model.mime_type!)
            
            
        if let previewUrl = model.preview {
            delegate?.loadImage(stringUrl: previewUrl, completion: { [weak self] (image) in
                self?.previewImage.image = image
                let previewImage = image!.pngData() as Data?
                StorageFiles.storage.embeded?._embedded?.items[indexPath.row].previewImage = previewImage
            })
                
            } else if model.media_type == "audio" {
                previewImage.image = UIImage(named: "mp3")

            } else {
                previewImage.image = UIImage(named: "file")

            }
        }
   
    }
    
    
    
    // срабатывает каждый раз когда создается(переиспользуется) ячейка
    override func prepareForReuse() {
        previewImage.image = nil
        sizeLabel.text = nil
        typeLabel.text = nil
        super.prepareForReuse()
    }

}
