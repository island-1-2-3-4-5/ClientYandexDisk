//
//  TableViewController.swift
//  MyCloudDisk
//
//  Created by Roman on 13.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    // кнопка назад
    @IBOutlet weak var backButtonOutlet: UIBarButtonItem!
    
    let viewModel = TableViewModel()
    let documentInteractionController = UIDocumentInteractionController()

    
    //1
    //MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Проверка на наличие токена
        if viewModel.tokenExist() {
            viewModel.requestPath()
        } else {
            requestToken()
        }
    }
    


    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        viewModel.loadData.delegate = self
        viewModel.loadData.downloadDelegate = self

        // метод навигации
        goToVC()
        
        setupScreen()
        
    }
    
     func setupScreen() {
        // убираем разлиновку после ячеек
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 0))
        
        // обновление интерфейса
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        
        // Долгое нажатие вызовет контроллер
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        
        longPress.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPress)
        
        
        if StorageFiles.storage.path != nil{
           okBarButton()
            
        } else {
            addBarButton()
        }
    }
    
    
    //2
    func requestToken() {
        let passcodeVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        passcodeVC.delegate = self
        passcodeVC.modalPresentationStyle = .overFullScreen
        present(passcodeVC, animated: true, completion: nil)
    }
    
    
    
    @objc func refresh(){
        viewModel.requestPath()
    }
    
    

    //MARK: - Долгое нажатие
    @objc func onLongPress(gesture: UILongPressGestureRecognizer) {

        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        // путь к объекту, и запись ссылки для скачивания
        let item = viewModel.itemPathAndDownload(indexPath: indexPath)

        // экземпляр AlertController
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteIcon = #imageLiteral(resourceName: "pngwing.com (4)")
        let replaceIcon = #imageLiteral(resourceName: "pngwing.com (3)")
        let downloadIcon = #imageLiteral(resourceName: "pngwing.com (5)")

        // MARK: - Перемещение
        let replace = UIAlertAction(title: "Переместить", style: .default) { _ in
            self.viewModel.storageFiles.path = item
            self.okBarButton()
        }

        // сдвигаем текст влево на всплывающем уведомлении
        replace.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        replace.setValue(replaceIcon, forKey: "image")

        //MARK: - Скачивание
        let download = UIAlertAction(title: "Скачать", style: .default) { _ in
            self.viewModel.loadData.downloadFile()

        }
        // сдвигаем текст влево на всплывающем уведомлении
        download.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        download.setValue(downloadIcon, forKey: "image")

        //MARK: - Удаление
        let delete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.viewModel.storageFiles.path = item
            self.viewModel.loadData.deleteFile()


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
        // после срабатывания заменяем кнопку Ok на +
        addBarButton()
        viewModel.loadData.replace()
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
            // При подтверждении, делаем запрос на создание папки
            self.viewModel.addFolder(name)
        }
        ac.addTextField{ textField in }

        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        
        ac.addAction(ok)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil) // отображаем на экране

    }
    
    
    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentOptionsMenu(from: view.frame, in: view, animated: true)
    }
    

    
    //MARK: - Передача данных для файлов
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "2" {
            let fivc: FileInfoViewController = segue.destination as! FileInfoViewController
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!

            // передаем на второй экран информацию
            fivc.name = viewModel.storageFiles.embeded?._embedded?.items[indexPath.row].name
            fivc.created = viewModel.storageFiles.embeded?._embedded?.items[indexPath.row].created
            fivc.mimeType = viewModel.storageFiles.embeded?._embedded?.items[indexPath.row].mime_type
            fivc.size = viewModel.storageFiles.embeded?._embedded?.items[indexPath.row].size
            //тк изображения могут передаваться разные, то сначала обработаем их
            fivc.image = viewModel.prepareImage(indexPath: indexPath)
        }
    }
    
    
    
    //MARK: Навигация для директорий
    func goToVC(){
        guard let indexPath = tableView.indexPathForSelectedRow  else {return}
        if viewModel.storageFiles.embeded?._embedded?.items[indexPath.row].type == "dir"{

            // передаем в менеждер загрузки путь
            viewModel.directoryNavigation(indexPath: indexPath)
            tableView.reloadData()
            performSegue(withIdentifier: "1", sender: self)
        } else {
            performSegue(withIdentifier: "2", sender: self)
        }
    }
    
    
    
    //MARK: - Навигация назад
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        viewModel.backStep()
        tableView.reloadData()
        self.viewDidLoad()
    }
    

    //MARK: Настройка ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellOne", for: indexPath) as! TableViewCell
        guard let items = viewModel.storageFiles.embeded?._embedded?.items, items.count > indexPath.row else { return cell }
        
        let currentFile = items[indexPath.row]
        cell.delegate = self
        cell.bindModel(currentFile, indexPath)
        
        return cell
    }

    //MARK: Количество строк
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countRows()
    }
    
    //MARK: - Выделение ячейки
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToVC()
    }

}





//MARK: EXTENSION


//MARK: Загрузка изображений
extension TableViewController: FileTableViewCellDelegate, LoginViewControllerDelegate, LoadDataDelegate, DownloadDelegate {
    
    //3
    //MARK: - Получение токена
    func handleTokenChanged(token: String) {
        viewModel.storageFiles.token = token
        viewModel.requestPath()
    }

    //4
    func handleDataChanged() {
        if viewModel.itRootPath(){
            self.backButtonOutlet.isEnabled = false
            self.backButtonOutlet.title = ""
        } else {
            self.backButtonOutlet.isEnabled = true
            self.backButtonOutlet.title = "Назад"
        }
        self.tableView.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    // срабатывает когда файл скачан
     func handleDownloadDataChanged(url: URL) {
         share(url: url)
     }

    func loadImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        viewModel.load(stringUrl: stringUrl, completion: completion)
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
