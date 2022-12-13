//
//  ViewController.swift
//  SettingsExample
//
//  Created by Konstantin Bolgar-Danchenko on 28.10.2022.
//

import UIKit

// MARK: - Model

struct Section {
    let title: String
    let options: [SettingsOptionsType]
}

enum SettingsOptionsType {
    case staticCell(model: SettingsOptions)
    case switchCell(model: SettingsSwitchOption)
}

struct SettingsSwitchOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let action: Selector
    var isOn: Bool
}

struct SettingsOptions {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

// MARK: - ViewController

class SettingsViewController: UIViewController {

    // MARK: - Properties & Subviews

    var models = [Section]()

    let keychainService = KeychainService()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsTableViewCell.self,
                       forCellReuseIdentifier: SettingsTableViewCell.identifier)
        table.register(SwitchTableViewCell.self,
                       forCellReuseIdentifier: SwitchTableViewCell.identifier)
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        configure()
        title = "Settings"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }

    // MARK: - Setup View

    private func isSortingSwitchOn() -> Bool {
        UserDefaults.standard.bool(forKey: "sorting")
    }

    private func isSizeSwitchOn() -> Bool {
        UserDefaults.standard.bool(forKey: "fileSize")
    }

    private func configure() {
        models.append(Section(title: "Appearance", options: [
            .switchCell(model: SettingsSwitchOption(
                title: "Sorting (A-Z)",
                icon: UIImage(systemName: "line.3.horizontal.decrease.circle"),
                iconBackgroundColor: .systemBlue,
                action: #selector(SwitchTableViewCell.sortingSwitchChanged(_:)),
                isOn: isSortingSwitchOn()
            )),

            .switchCell(model: SettingsSwitchOption(
                title: "Show File Size",
                icon: UIImage(systemName: "doc.badge.ellipsis"),
                iconBackgroundColor: .systemGreen,
                action: #selector(SwitchTableViewCell.sizeSwitchChanged(_:)),
                isOn: isSizeSwitchOn()
            )),
        ]))

        models.append(Section(
            title: "Security",
            options: [
            .staticCell(model: SettingsOptions(
                title: "Change Password",
                icon: UIImage(systemName: "key"),
                iconBackgroundColor: .systemRed) {
                    self.keychainService.removePassword()
                    let vc = PasswordViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
            })
        ]))
    }
}

// MARK: - TableView

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]

        switch model.self {
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsTableViewCell.identifier,
                for: indexPath
            ) as? SettingsTableViewCell else {
                return UITableViewCell()
            }
            cell.configureSettingsCell(with: model)
            return cell
        case .switchCell(let model):

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SwitchTableViewCell.identifier,
                for: indexPath
            ) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.configureSwitchCell(with: model)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(let model):
            model.handler()
        case .switchCell(_):
            return
        }
    }
}
