//
//  LocalAuthorizationService.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 21.12.2022.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class LocalAuthorizationService {
    
    private let context = LAContext()
    private let policy: LAPolicy
    private let loginReason: String
    
    init(
        policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
        loginReason: String = "Verify your identity",
        localizedFallbackTitle: String = "Enter your password"
    ) {
        self.policy = policy
        self.loginReason = loginReason
        
        context.localizedFallbackTitle = localizedFallbackTitle
        context.localizedCancelTitle = "Cancel"
    }
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(policy, error: nil)
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(policy, error: nil)
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .none
        }
    }
    
    func authorizeIfPossible(completion: @escaping (String?) -> Void) {
        
        guard canEvaluatePolicy() else {
            completion("Face ID/Touch ID is not available")
            return
        }
        
        context.evaluatePolicy(policy,
                               localizedReason: loginReason) { success, error in
            
            DispatchQueue.main.async {
                if success {
                    completion(nil)
                } else {
                    let message: String
                                
                    switch error {
                    case LAError.authenticationFailed?:
                      message = "There was a problem verifying your identity."
                    case LAError.userCancel?:
                      message = "You pressed cancel."
                    case LAError.userFallback?:
                      message = "You pressed password."
                    case LAError.biometryNotAvailable?:
                      message = "Face ID/Touch ID is not available."
                    case LAError.biometryNotEnrolled?:
                      message = "Face ID/Touch ID is not set up."
                    case LAError.biometryLockout?:
                      message = "Face ID/Touch ID is locked."
                    default:
                      message = "Face ID/Touch ID may not be configured"
                    }
                    completion(message)
                }
            }
        }
    }
}


