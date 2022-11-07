//
//  PasswordViewController.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 28.10.2022.
//

import Foundation
import UIKit
import KeychainAccess

class PasswordViewController: UIViewController {

    // MARK: - Model

    enum ControllerType {
        case createPassword
        case signIn
    }

    // MARK: - Properties

    let keychainService = KeychainService()

    var controllerType: ControllerType {
        if keychainService.data() {
            return ControllerType.signIn
        } else {
            return ControllerType.createPassword
        }
    }

    var newPassword = ""

    // MARK: - Subviews

    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubview()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        setupConstraints()
    }

    // MARK: - Layout

    private func setupSubview() {

        switch controllerType {

        case .createPassword:
            self.title = "Create Password"
            loginButton.setTitle("Create Password", for: .normal)
        case .signIn:
            self.title = "Sign In"
            loginButton.setTitle("Sign In", for: .normal)
        }
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            passwordField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 50),
            passwordField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            passwordField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            passwordField.heightAnchor.constraint(equalToConstant: 40),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            loginButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 40),

        ])
    }

    // MARK: - Auth

    @objc func didTapLoginButton() {

        switch controllerType {
        case .createPassword:
            guard let input = passwordField.text, input.count >= 4 else {
                let alert = UIAlertController(title: "Invalid Password", message: "Password should be at least 4 characters long", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                passwordField.text = ""
                return
            }

            if newPassword == "" {
                newPassword = input
                passwordField.text = ""
                loginButton.setTitle("Confirm Password", for: .normal)
            } else {
                if input == newPassword {
                    keychainService.setPassword(newPassword: input)
                    DocumentsViewController.isLoggedIn = true
                    self.dismiss(animated: true)
                } else {
                    let alert = UIAlertController(title: "Attention", message: "Passwords didn't match", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                    passwordField.text = ""
                }
            }
        case .signIn:
            guard let input = passwordField.text else { return }

            if keychainService.checkPassword(input: input) {
                DocumentsViewController.isLoggedIn = true
                self.dismiss(animated: true)
            } else {
                let alert = UIAlertController(title: "Attention", message: "Password is wrong", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                passwordField.text = ""
            }
        }
    }

}
