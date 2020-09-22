//
//  TableViewModel.swift
//  ClientDisk
//
//  Created by Roman on 22.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation
import UIKit

class TableViewModel{

    let loadData = LoadData()
    var storageFiles = StorageFiles.storage
    
    
      //MARK: Запрос пути
    func requestPath(){
        if StorageFiles.storage.embeded?.path == nil {
            loadData.updateData(path: "disk:/")
        } else {
            loadData.updateData(path: StorageFiles.storage.embeded!.path)
        }
    }
    
    //Проверка на существование токена
    func tokenExist() -> Bool{
        if storageFiles.token != nil {
            return true
        }
        return false
    }
    
    // Проверка выбранного пути
    func itRootPath() -> Bool{
        if storageFiles.embeded?.path == "disk:/" {
            return true
        }
        return false
    }
    
    //количество строк
    func countRows() -> Int{
        guard let count = storageFiles.embeded?._embedded?.items.count else {
            return 0
        }
        return count
    }
    
    // функция подгрузки изображений для ячеек
    func load(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        loadData.load(stringUrl: stringUrl, completion: completion)
    }
    
    
    // Функция для возврата на предыдущую страницу
    func backStep(){
    let name = storageFiles.embeded?.name
    let str = storageFiles.embeded?.path
    var count = str!.count - (name!.count + 1)

    if count < 6{
        count = 6
    }

    let path = str!.padding(toLength: count, withPad: "", startingAt: 0)
    storageFiles.embeded!.path = path

    // навигация назад, изменяем ссылку пути
    loadData.updateData(path: path)
    storageFiles.embeded?._embedded?.items.removeAll()
    }
    
    
    
    func directoryNavigation(indexPath: IndexPath){
        
        let path = (storageFiles.embeded?._embedded?.items[indexPath.row].path)!
        
        // сохраняем путь чтобы не создавать повторно токен
        storageFiles.embeded?.path = path
        //передаем путь в менеджер загрузки
        loadData.updateData(path: storageFiles.embeded!.path)
        // чистим массив с данными
        storageFiles.embeded?._embedded?.items.removeAll()
    }
    
    
    
    
    func prepareImage(indexPath: IndexPath) -> UIImage{
        
        let image: UIImage?
        
        if storageFiles.embeded?._embedded?.items[indexPath.row].previewImage != nil {
            image = UIImage(data: (storageFiles.embeded?._embedded?.items[indexPath.row].previewImage)!)
        } else if storageFiles.embeded?._embedded?.items[indexPath.row].media_type == "audio"{
            image = UIImage(named: "mp3")
            } else {
            image = UIImage(named: "file")
            }

        
        
        return image!
    }
    
    
    
    
//    MARK: - Создание папок
        func addFolder(_ name: String?){
            loadData.addFolder(name)

}
    
    
    func itemPathAndDownload(indexPath: IndexPath) -> String{
        guard let item = storageFiles.embeded?._embedded!.items[indexPath.row].path else {return ""}
        // ссылка на скачивание
        let itemFile = storageFiles.embeded?._embedded!.items[indexPath.row].file
        // записываем ссылку, нужно для скачивания файлов
        storageFiles.file = itemFile
        
        return item
    }
}
