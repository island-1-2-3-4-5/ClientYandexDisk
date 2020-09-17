//
//  TableViewController.swift
//  MyCloudDisk
//
//  Created by Roman on 13.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, LoginViewControllerDelegate {
    func handleTokenChanged(token: String) {
        StorageFiles.storage.token = token
        
        if StorageFiles.storage.embeded?.path == nil {
            updateData(path: "disk:/")
        } else {
            updateData(path: StorageFiles.storage.embeded!.path)
        }
    }
    
    @IBOutlet weak var backButtonOutlet: UIBarButtonItem!
    




    
    override func viewDidLoad() {
        super.viewDidLoad()
        goToVC()
        
        // убираем разлиновку после ячеек
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 0))

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if StorageFiles.storage.embeded?.path == nil {
            updateData(path: "disk:/")
        } else {
            updateData(path: StorageFiles.storage.embeded!.path)
        }
        
    
    }
    
    
    
        private func requestToken() {
            let passcodeVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            passcodeVC.delegate = self
            passcodeVC.modalPresentationStyle = .overFullScreen
            present(passcodeVC, animated: true, completion: nil)
        }

        @objc func updateData(path: String) {
            guard let token = StorageFiles.storage.token else {
                requestToken()
                return
            }
            var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
            components?.queryItems = [URLQueryItem(name: "path", value: path)]

            guard let url = components?.url else { return }
            var request = URLRequest(url: url)
            request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self, let data = data else { return }
                
                
                print("ДАННЫЕ КОТОРЫЕ ПРИШЛИ \(data)")
                
                // создаем файл из которого извлекаем данные JSON
                guard let newFiles = try? JSONDecoder().decode(StorageFiles.Embebed.self, from: data) else { return }
                print("Received \(newFiles._embedded?.items.count ?? 0) files")
                    // Производим запись в нашу модель
                print("ЗАПИСЬ В БАЗУ ДАННЫХ\(newFiles)")
                        StorageFiles.storage.embeded = newFiles
                
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if newFiles.path == "disk:/"{
                        self.backButtonOutlet.isEnabled = false
                        self.backButtonOutlet.title = ""
                    } else {
                        self.backButtonOutlet.isEnabled = true
                        self.backButtonOutlet.title = "Назад"
                    }
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                                    
                }
            }
            
            task.resume()
            
        }
    
    
    

    // MARK: - Table view data source


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellOne", for: indexPath) as! TableViewCell

        
        guard let items = StorageFiles.storage.embeded?._embedded?.items, items.count > indexPath.row else {
            return cell
        }
        let currentFile = items[indexPath.row]
        cell.delegate = self
            cell.bindModel(currentFile, indexPath)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StorageFiles.storage.embeded?._embedded?.items.count ?? 0
    }
    
    
    

    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        let name = StorageFiles.storage.embeded?.name
        let str = (StorageFiles.storage.embeded?.path)
        var count = str!.count - (name!.count + 1)

        if count < 6{
            count = 6
        }
        // навигация назад, изменяем ссылку пути
        updateData(path: str!.padding(toLength: count, withPad: "", startingAt: 0))

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "2" {
            let fivc: FileInfoViewController = segue.destination as! FileInfoViewController
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!

            
            // передаем на второй экран информацию об выбранной ности
            fivc.name = StorageFiles.storage.embeded?._embedded?.items[indexPath.row].name
            fivc.indexPath = indexPath
            guard let image = StorageFiles.storage.embeded?._embedded?.items[indexPath.row].previewImage else { fivc.image = UIImage(named: "file")
                return
            }
            fivc.image = UIImage(data: image)
        }
    }
    
    func goToVC(){
        
        guard let indexPath = tableView.indexPathForSelectedRow  else {return}

        if StorageFiles.storage.embeded?._embedded?.items[indexPath.row].type == "dir"{

            let path = (StorageFiles.storage.embeded?._embedded?.items[indexPath.row].path)!
            StorageFiles.storage.embeded?.path = path
            updateData(path: StorageFiles.storage.embeded!.path)
            StorageFiles.storage.embeded?._embedded?.items.removeAll()
            tableView.reloadData()
            
            performSegue(withIdentifier: "1", sender: self)

        } else {
            performSegue(withIdentifier: "2", sender: self)

        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToVC()
    }

}


extension TableViewController: FileTableViewCellDelegate {

    func loadImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
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
}
