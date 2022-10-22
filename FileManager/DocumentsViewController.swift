//
//  ViewController.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 22.10.2022.
//

import UIKit

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties

    let fileManagerService = FileManagerService()

    var rootURL: URL

    var files: [URL] = []

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        files = fileManagerService.contentsOfDirectory(currentDirectory: rootURL)
    }

    // MARK: - Setup View

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

    // MARK: - TableView

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return files.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        )
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = "\(self.files[indexPath.row].lastPathComponent)"

        do {
            let fileType = try FileManager.default.attributesOfItem(atPath: "\(self.files[indexPath.row].path)")[FileAttributeKey.type]
            if fileType as! FileAttributeType == FileAttributeType.typeDirectory {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
        } catch {
            print(error.localizedDescription)
        }
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
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

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
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

    // MARK: - Picker Controller

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.imageURL] as! URL
        self.dismiss(animated: true, completion: nil)
        fileManagerService.createFile(
            currentDirectory: rootURL,
            newFile: image
        )
        files = fileManagerService.contentsOfDirectory(currentDirectory: rootURL)
        self.listOfFiles.reloadData()
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
