//
//  KeychainService.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 28.10.2022.
//

import Foundation
import UIKit
import KeychainAccess

protocol KeychainServiceProtocol {
    func data() -> Bool
    func setPassword(newPassword: String)
    func checkPassword(input: String) -> Bool
    func removePassword()
}

class KeychainService: KeychainServiceProtocol {

    let keychain = Keychain(service: "file-manager")

    func data() -> Bool {
        if keychain["password"] != nil {
            return true
        } else {
            return false
        }
    }

    func setPassword(newPassword: String) {
        keychain["password"] = newPassword
    }

    func checkPassword(input: String) -> Bool {
        if input == keychain["password"] {
            return true
        } else {
            return false
        }
    }

    func removePassword() {
        keychain["password"] = nil
    }
}
