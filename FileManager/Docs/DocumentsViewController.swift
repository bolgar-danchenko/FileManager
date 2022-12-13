//
//  ViewController.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 22.10.2022.
//

import UIKit

class DocumentsViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Properties

    static var isLoggedIn = false

    let fileManagerService = FileManagerService()

    var rootURL: URL

    public var files: [URL] = []

    var directoryTitle: String

    let listOfFiles: UITableView = {
        let listOfFiles = UITableView.init(
            frame: .zero,
            style: .grouped
        )
        listOfFiles.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "Cell"
        )
        listOfFiles.translatesAutoresizingMaskIntoConstraints = false
        return listOfFiles
    }()

    let picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        return picker
    }()

    // MARK: - Init

    init(rootURL: URL, directoryTitle: String) {
        self.rootURL = rootURL
        self.directoryTitle = directoryTitle
        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = directoryTitle
        view.backgroundColor = .white

        setupNavigationController()
        setupTableView()

        checkAuth()

        files = fileManagerService.contentsOfDirectory(currentDirectory: rootURL)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortFiles()
    }

    // MARK: - Setup View

    private func checkAuth() {
        if DocumentsViewController.isLoggedIn {
            return
        } else {
            let vc = PasswordViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }

    private func sortFiles() {
        if UserDefaults.standard.bool(forKey: "sorting") {
            files = files.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        } else {
            files = files.sorted(by: { $1.lastPathComponent < $0.lastPathComponent })
        }

        listOfFiles.reloadData()
    }

    func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true

        let addFileButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createFile)
        )

        let addDirectoryButton = UIBarButtonItem(
            image: UIImage(systemName: "folder.badge.plus"),
            style: .plain,
            target: self,
            action: #selector(createDirectory)
        )

        navigationItem.rightBarButtonItems = [addFileButton, addDirectoryButton]
    }

    func setupTableView() {
        view.addSubview(listOfFiles)
        listOfFiles.dataSource = self
        listOfFiles.delegate = self

        NSLayoutConstraint.activate([
            listOfFiles.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            listOfFiles.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            listOfFiles.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listOfFiles.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc func createDirectory() {
        let alert = UIAlertController(
            title: "Add Folder",
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { (textField) in
            textField.placeholder = "New Folder"
        }
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: "Add",
            style: .default,
            handler: { [self] _ in
                guard let name = alert.textFields?[0].text else { return }
                fileManagerService.createDirectory(
                    currentDirectory: rootURL,
                    newDirectoryName: name
                )
                files = fileManagerService.contentsOfDirectory(currentDirectory: rootURL)
                self.sortFiles()
                self.listOfFiles.reloadData()
            }))
        self.present(
            alert,
            animated: true,
            completion: nil
        )
    }

    @objc func createFile() {
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - TableView

extension DocumentsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = "\(self.files[indexPath.row].lastPathComponent)"
        
        do {
            let filePath = "\(self.files[indexPath.row].path)"
            
            let fileType = try FileManager.default.attributesOfItem(atPath: filePath)[FileAttributeKey.type]

            if fileType as! FileAttributeType == FileAttributeType.typeDirectory {
                cell.accessoryType = .disclosureIndicator
                cell.imageView?.image = UIImage(systemName: "folder")
                cell.detailTextLabel?.text = fileManagerService.sizeOfFolder(filePath)
            } else {
                cell.accessoryType = .none
                cell.imageView?.image = UIImage(systemName: "photo")
                
                if let fileUrl = URL(string: files[indexPath.row].path) {

                    let fileSizeString = fileUrl.fileSizeString
                    
                    if UserDefaults.standard.bool(forKey: "fileSize") {
                        cell.detailTextLabel?.text = fileSizeString
                    } else {
                        cell.detailTextLabel?.text = nil
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            let fileType = try FileManager.default.attributesOfItem(atPath: "\(self.files[indexPath.row].path)")[FileAttributeKey.type]
            if fileType as! FileAttributeType == FileAttributeType.typeDirectory {
                guard let path = self.files[indexPath.row].path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let pathURL = URL(string: path) else {
                    print("Incorrect URL")
                    return
                }
                let view = DocumentsViewController(rootURL: pathURL, directoryTitle: pathURL.lastPathComponent)
                navigationController?.pushViewController(view, animated: true)
            }

        } catch {
            print(error.localizedDescription)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let url = files[indexPath.row]
            files.remove(at: indexPath.row)
            fileManagerService.removeContent(
                currentDirectory: rootURL,
                toDelete: url
            )
            listOfFiles.deleteRows(
                at: [indexPath],
                with: .fade
            )
        }
    }
}

// MARK: - Picker Controller

extension DocumentsViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imageURL = info[.imageURL] as! URL
        let originalImage = info[.originalImage] as! UIImage
        
        self.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fileManagerService.createFile(currentDirectory: strongSelf.rootURL, newFile: imageURL, image: originalImage)
            strongSelf.files = strongSelf.fileManagerService.contentsOfDirectory(currentDirectory: strongSelf.rootURL)
            strongSelf.self.sortFiles()
            strongSelf.self.listOfFiles.reloadData()
        }
        
    }
}
