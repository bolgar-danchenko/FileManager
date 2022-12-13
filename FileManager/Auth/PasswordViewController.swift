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

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to FileManager"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please create your password to continue"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordField: UITextField = {
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

    private lazy var loginButton: UIButton = {
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
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        setupConstraints()
    }

    // MARK: - Layout

    private func setupSubview() {

        switch controllerType {

        case .createPassword:
            subtitleLabel.text = "Please create your password to continue"
            loginButton.setTitle("Create Password", for: .normal)
        case .signIn:
            subtitleLabel.text = "Please enter your password"
            loginButton.setTitle("Sign In", for: .normal)
        }
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 90),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -25),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            subtitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            
            passwordField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 120),
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
                subtitleLabel.text = "Please enter your password"
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
