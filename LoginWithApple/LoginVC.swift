//
//  LoginVC.swift
//  LoginWithApple
//
//  Created by Brian Hersh on 10/3/19.
//  Copyright © 2019 Brian Hersh. All rights reserved.
//

import UIKit
import AuthenticationServices

struct User {
    let uid: String
    let name: String
    let email: String
}

class LoginVC: UIViewController {
    
    // MARK: - Properties
    var user: User?
    
    // MARK: - IBOutlets
    @IBOutlet weak var buttonStack: UIStackView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSignInAppleButton()
    }
    
    // MARK: - Methods
    private func setUpSignInAppleButton() {
        let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .white)
        authorizationButton.addTarget(self, action: #selector(handleAppleIDRequest), for: .touchUpInside)
        authorizationButton.cornerRadius = 10
        buttonStack.addArrangedSubview(authorizationButton)
    }
    
    @objc func handleAppleIDRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.presentationContextProvider = self
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

// MARK: - AS Methods
extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        user = User(uid: appleIDCredential.user, name: "\(String(describing: appleIDCredential.fullName))", email: appleIDCredential.email ?? "nil" )
        
        print(user?.email as Any, user?.name as Any, user?.uid as Any)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
