//
//  TableViewController.swift
//  MyCloudDisk
//
//  Created by Roman on 13.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, LoginViewControllerDelegate {


    // кнопка назад
    @IBOutlet weak var backButtonOutlet: UIBarButtonItem!
    
    let documentInteractionController = UIDocumentInteractionController()




    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // метод навигации
        goToVC()
        
        // убираем разлиновку после ячеек
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 0))
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(requestPath), for: .valueChanged)
        tableView.refreshControl = refreshControl

        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        
        longPress.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPress)
        
        
        if StorageFiles.storage.path != nil{
            okBarButton()

        } else {
            addBarButton()
        }
        
    }
    
    
    
    //MARK: - Получение токена
    func handleTokenChanged(token: String) {
        StorageFiles.storage.token = token
        
        requestPath()
    }
    
    
         func requestToken() {
            let passcodeVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            passcodeVC.delegate = self
            passcodeVC.modalPresentationStyle = .overFullScreen
            present(passcodeVC, animated: true, completion: nil)
        }
    
    
    
    
    //MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPath()
    }
    
    
    
    
    //MARK: Запрос пути
  @objc  func requestPath(){
        if StorageFiles.storage.embeded?.path == nil {
            updateData(path: "disk:/")
        } else {
            updateData(path: StorageFiles.storage.embeded!.path)
        }
    }
    
    //MARK: - Загрузка данных
         func updateData(path: String) {
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
    
    
    //MARK: - Долгое нажатие
    @objc func onLongPress(gesture: UILongPressGestureRecognizer) {
        
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        let item = StorageFiles.storage.embeded?._embedded!.items[indexPath.row].path
        let itemFile = StorageFiles.storage.embeded?._embedded!.items[indexPath.row].file
        StorageFiles.storage.file = itemFile


                   // экземпляр AlertController
                   let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                   
        
        let deleteIcon = #imageLiteral(resourceName: "pngwing.com (4)")
        let replaceIcon = #imageLiteral(resourceName: "pngwing.com (3)")
        let downloadIcon = #imageLiteral(resourceName: "pngwing.com (5)")

        
                   // первая кнопка
                   let replace = UIAlertAction(title: "Переместить", style: .default) { _ in
                    StorageFiles.storage.path = item

                      
     
                    self.okBarButton()
                    
        }
                   
                   // сдвигаем текст влево на всплывающем уведомлении
                   replace.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                   replace.setValue(replaceIcon, forKey: "image")

                   
                   // вторая кнопка - вызывает галерею
                   let download = UIAlertAction(title: "Скачать", style: .default) { _ in

                    self.download()
                    
                   }
                   // сдвигаем текст влево на всплывающем уведомлении
                   download.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                   download.setValue(downloadIcon, forKey: "image")

        
                let delete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    StorageFiles.storage.path = item

                    self.delete()
         
                    }
                delete.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            delete.setValue(deleteIcon, forKey: "image")
        
        
                   // кнопка выхода
                   let cancel = UIAlertAction(title: "Отмена", style: .cancel)
                   
                   // добавляем действия
                   actionSheet.addAction(replace)
                   actionSheet.addAction(download)
                   actionSheet.addAction(delete)
                   actionSheet.addAction(cancel)
                   
                   // отображаем AlertController
                   present(actionSheet, animated: true)

    }
    
    
    //MARK: okBarButton
    func okBarButton(){
        let aboutButton = UIBarButtonItem(title: "Ок", style: .plain, target: self, action: #selector(self.replace))
        self.navigationItem.rightBarButtonItem = aboutButton
        
    }
    
    
    //MARK: - Перемещение файлов
    @objc func replace(){
        addBarButton()
        
        guard let token = StorageFiles.storage.token else {
            self.requestToken()
            return
        }
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
                    self.requestPath()
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                                    
                }
              }.resume()
        
        StorageFiles.storage.path = nil
    }

    
    
    
    //MARK: Add AlertController

    func addBarButton(){
        let aboutButton = UIBarButtonItem.SystemItem.add
        let button = UIBarButtonItem(barButtonSystemItem: aboutButton, target: self, action: #selector(add))
        navigationItem.rightBarButtonItem = button
    }
    
    // Добавление директорий
    @objc func add(){
        
        // Создаем Алерт контроллер для добавления значений
        let ac = UIAlertController(title: "Добавление директории", message: "Введите название", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { action in
            guard let name = ac.textFields?[0].text else { return }
            self.addFolder(name)
        }
        
        ac.addTextField{ textField in }

        let cancel = UIAlertAction(title: "Отмена", style: .cancel)

        ac.addAction(ok)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil) // отображаем на экране
    
    }
    
    
    
    //MARK: - Создание папок
    func addFolder(_ name: String?){
               
    guard let token = StorageFiles.storage.token else {
        self.requestToken()
        return
        }
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
            self.requestPath()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            }
            }.resume()
        
    }
    
    
    
    
    //MARK: - Скачивание файлов
    func download(){

        let path = StorageFiles.storage.file
        
        guard let url = URL(string: path!) else { return }
         URLSession.shared.dataTask(with: url) { data, response, error in
             guard let data = data, error == nil else { return }
             let tmpURL = FileManager.default.temporaryDirectory
                 .appendingPathComponent(response?.suggestedFilename ?? "fileName.csv")
             do {
                 try data.write(to: tmpURL)
                 DispatchQueue.main.async {
                     self.share(url: tmpURL)
                 }
             } catch {
                 print(error)
             }

         }.resume()

    }
    
    
    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentOptionsMenu(from: view.frame, in: view, animated: true)
    }
    
    
    //MARK: - Удаление файлов

    func delete(){
        let path = StorageFiles.storage.path

        guard let token = StorageFiles.storage.token else {
            self.requestToken()
            return
        }

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
                    self.requestPath()
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
              }.resume()
        
        StorageFiles.storage.path = nil
    }
    

    
    
    //MARK: - Навигация для файлов
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "2" {
            let fivc: FileInfoViewController = segue.destination as! FileInfoViewController
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!

            
            // передаем на второй экран информацию об выбранной ности
            fivc.name = StorageFiles.storage.embeded?._embedded?.items[indexPath.row].name
            fivc.created = StorageFiles.storage.embeded?._embedded?.items[indexPath.row].created
            fivc.mimeType = StorageFiles.storage.embeded?._embedded?.items[indexPath.row].mime_type
            fivc.size = StorageFiles.storage.embeded?._embedded?.items[indexPath.row].size
   
            
            guard let image = StorageFiles.storage.embeded?._embedded?.items[indexPath.row].previewImage else {
                
                if StorageFiles.storage.embeded?._embedded?.items[indexPath.row].media_type == "audio"{
                    fivc.image = UIImage(named: "mp3")
                } else {
                fivc.image = UIImage(named: "file")
                }
                return
            }
            fivc.image = UIImage(data: image)
        }
    }
    
    
    
    //MARK: Навигация для директорий
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
    
    
    
    //MARK: - Навигация назад
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        let name = StorageFiles.storage.embeded?.name
          let str = (StorageFiles.storage.embeded?.path)
          var count = str!.count - (name!.count + 1)

          if count < 6{
              count = 6
          }
        
        let path = str!.padding(toLength: count, withPad: "", startingAt: 0)
        StorageFiles.storage.embeded!.path = path
        
          // навигация назад, изменяем ссылку пути
          updateData(path: path)
        StorageFiles.storage.embeded?._embedded?.items.removeAll()
        tableView.reloadData()
        self.viewDidLoad()

    }
    

    
    // MARK: - Table view data source

    

    //MARK: Настройка ячейки
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

    //MARK: Количество строк
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StorageFiles.storage.embeded?._embedded?.items.count ?? 0
    }
    
    //MARK: - Выделение ячейки
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToVC()
    }

}



//MARK: Загрузка изображений
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
