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
    private let requester = Requester()
    
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
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        printCredential(appleCredential)

        //authCode = ONE TIME ONLY !!!
//        requester.requestToServer(code: appleCredential.authorizationCode,token: appleCredential.identityToken,completion: {data,response in
//            print("data:",data)
//            print("response:",response)
//        })
        
        
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    private func printCredential(_ appleCredential: ASAuthorizationAppleIDCredential) {
        print("===== Credential From Apple ====")
        print("authorization code: \(String(data:appleCredential.authorizationCode!, encoding: .utf8))")
        print("user: " + appleCredential.user)
        print("state: \(appleCredential.state)")
        print("authorizedScopes: \(appleCredential.authorizedScopes)")
        print("identityToken( JWT ): \(String(data:appleCredential.identityToken!, encoding: .utf8))")
        print("email: \(appleCredential.email)")
        print("fullName: \(appleCredential.fullName)")
        print("realUserStatus: \(appleCredential.realUserStatus)")
    }
}

struct Param : Codable {
    let authorizationCode: String?
    let identityToken: String?
}

class Requester {
    func requestToServer(code: Data?, token: Data?, completion: @escaping (Data, URLResponse) -> Void) {
        let url = URL(string: "http://0.0.0.0/appleAuth")!
        
        //  code - IMPORTANT - TTL = 5mins!
        // (Authorization) The authorization code received from your application’s user agent.
        // The code is single use only and valid for five minutes.

        let authCode = String(data: code!, encoding: .utf8)!
        print("authCode:",authCode)
        
        let identityToken = String(data: token!, encoding: .utf8)!
        print("identityToken:",identityToken)
        
        let requestParam = Param(authorizationCode: authCode, identityToken: identityToken)
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestParam)
        
        URLSession.shared.dataTask(with: request) { data , response ,error in
            guard let data = data, let response = response else { return }
            if let error = error {
                print("error:\(error)")
            } else {
                print("response:\(response)")
                completion(data, response)
            }
        }.resume()
    }
}

