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
        self.token = token
        updateData()
    }
    

    var container = ["1","2","2","3","1"]
    private var first = true
    var token: String = ""
    var filesData: DiskResponse?



    
    override func viewDidLoad() {
        super.viewDidLoad()
        goToVC()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if first {
             updateData()
         }
         first = false
    }
    
    
    
        private func requestToken() {
            let passcodeVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            passcodeVC.delegate = self
            passcodeVC.modalPresentationStyle = .overFullScreen
            present(passcodeVC, animated: true, completion: nil)
        }

        @objc
        private func updateData() {
            guard !token.isEmpty else {
                requestToken()
                return
            }
            var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/files")
    //        components?.queryItems = [URLQueryItem(name: "path", value: "disk:/")]

            guard let url = components?.url else { return }
            var request = URLRequest(url: url)
            request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let sself = self, let data = data else { return }
                
                // создаем файл из которого извлекаем данные JSON
                guard let newFiles = try? JSONDecoder().decode(DiskResponse.self, from: data) else { return }
                print("Received \(newFiles.items?.count ?? 0) files")
                    // Производим запись в нашу модель
                print(newFiles)
                        sself.filesData = newFiles
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
            task.resume()
        }
    
    
    

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return container.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellOne", for: indexPath) as! TableViewCell

        cell.label.text = container[indexPath.row]
        
    
        
        
        return cell
    }
    


    
    func goToVC(){
        
        guard let indexPath = tableView.indexPathForSelectedRow  else {return}

    if container[indexPath.row] == "2"{
            performSegue(withIdentifier: "2", sender: self)

        } else {
            let alert = UIAlertController(title: "Ваш пароль:", message: "РАБОТАЕТ", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            tableView.reloadData()
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToVC()
    }

}
