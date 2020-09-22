//
//  LoadData.swift
//  ClientDisk
//
//  Created by Roman on 22.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation
import UIKit

class LoadData{
    
    weak var delegate: LoadDataDelegate?
    weak var downloadDelegate: DownloadDelegate?
    

        //MARK: - Загрузка данных
        func updateData(path: String) {
            guard let token = StorageFiles.storage.token else {
                return
            }
            var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
            components?.queryItems = [URLQueryItem(name: "path", value: path)]

            guard let url = components?.url else { return }
            var request = URLRequest(url: url)
            request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                
                guard let self = self, let data = data else { return }
                                    
                // создаем файл из которого извлекаем данные JSON
                guard let newFiles = try? JSONDecoder().decode(StorageFiles.Embebed.self, from: data) else { return }
                // Производим запись в нашу модель
                print("ЗАПИСЬ В БАЗУ ДАННЫХ\(newFiles)")
                StorageFiles.storage.embeded = newFiles
                    
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.delegate?.handleDataChanged()
                      
                }
            }
            task.resume()
        }
    
    
    // Обновление интерфейса
    func updateInterface(){
        self.delegate?.handleDataChanged()
        if StorageFiles.storage.embeded?.path == nil {
            self.updateData(path: "disk:/")
        } else {
            self.updateData(path: StorageFiles.storage.embeded!.path)
        }
    }
    
    
    
    
    //MARK: Подгрузка изображений
    func load(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        
        
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(StorageFiles.storage.token!)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
        
    }
    
    
    //MARK: Добавление директорий
    func addFolder(_ name: String?){

        guard let token = StorageFiles.storage.token else { return }
            // Куда
            var path = ""
    
            if StorageFiles.storage.embeded!.path == "disk:/" {
                path = StorageFiles.storage.embeded!.path + name!
    
            } else {
                path = StorageFiles.storage.embeded!.path + "/" + name!
    
            }
    
            var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
    
            components?.queryItems = [ URLQueryItem(name: "path", value: path)]
            guard let url = components?.url else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("OAuth \(String(describing: token))", forHTTPHeaderField: "Authorization")
    
            URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                    case 200..<300:
                        print("Success")
                    default:
                        print("Status: \(response.statusCode)")
                    }
    
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.updateInterface()
                }
    
            }.resume()
    
        }
    
    
    
    func replace(){
        
         guard let token = StorageFiles.storage.token else { return }
        // Откуда
           let fileUrl = StorageFiles.storage.path

           let fullNameArr = fileUrl!.components(separatedBy: "/")

           //Куда
           var path = ""

           if StorageFiles.storage.embeded!.path == "disk:/"{
               path = StorageFiles.storage.embeded!.path + fullNameArr[fullNameArr.count - 1]
           } else {
               path = StorageFiles.storage.embeded!.path + "/" + fullNameArr[fullNameArr.count - 1]
           }


           var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/move")

           components?.queryItems = [
               URLQueryItem(name: "from", value: fileUrl),
               URLQueryItem(name: "path", value: path),
           ]
           guard let url = components?.url else { return }
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("OAuth \(String(describing: token))", forHTTPHeaderField: "Authorization")

           URLSession.shared.dataTask(with: request) { (data, response, error) in
               if let response = response as? HTTPURLResponse {
                   switch response.statusCode {
                   case 200..<300:
                   print("Success")
                   default:
                   print("Status: \(response.statusCode)")

                   }

               }
               DispatchQueue.main.async { [weak self] in
                   guard let self = self else { return }
                self.updateInterface()

               }

           }.resume()
           StorageFiles.storage.path = nil
    }
    
    
    
    func deleteFile(){
        
    let path = StorageFiles.storage.path

     guard let token = StorageFiles.storage.token else { return }

     var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")

     components?.queryItems = [ URLQueryItem(name: "path", value: path)]
     guard let url = components?.url else { return }
     var request = URLRequest(url: url)
     request.httpMethod = "DELETE"
     request.setValue("OAuth \(String(describing: token))", forHTTPHeaderField: "Authorization")
     URLSession.shared.dataTask(with: request) { (data, response, error) in
     if let response = response as? HTTPURLResponse {
         switch response.statusCode {
         case 200..<300:
             print("Success")
         default:
             print("Status: \(response.statusCode)")

         }

         }
         DispatchQueue.main.async { [weak self] in
             guard let self = self else { return }
            self.updateInterface()

         }

     }.resume()
     StorageFiles.storage.path = nil
    
    }
    
    
    
    func downloadFile(){
        let path = StorageFiles.storage.file

        guard let url = URL(string: path!) else { return }
         URLSession.shared.dataTask(with: url) { data, response, error in
             guard let data = data, error == nil else { return }
             let tmpURL = FileManager.default.temporaryDirectory
                 .appendingPathComponent(response?.suggestedFilename ?? "fileName.csv")
             do {
                 try data.write(to: tmpURL)
                 DispatchQueue.main.async {
                    self.downloadDelegate?.handleDownloadDataChanged(url: tmpURL)
                 }
             } catch {
                 print(error)
             }

         }.resume()
    }
}

    
    

