//
//  AuthenticationModel.swift
//  Hyderi
//
//  Created by Ali Earp on 1/2/25.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import LocalAuthentication

class AuthenticationModel: ObservableObject {
    @Published var user: User?
    
    @Published var loading: Bool = true
    
    init() {
        getUser()
    }
    
    private func getUser() {
        user = Auth.auth().currentUser
        
        loading = false
    }
    
    @MainActor
    func signIn() async {
        loading = true
        
        do {
            guard let topViewController = UIApplication.topViewController() else { return }
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
            
            guard let idToken = result.user.idToken?.tokenString else { return }
            let accessToken = result.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            try await Auth.auth().signIn(with: credential)
            
            getUser()
        } catch {
            loading = false
        }
    }
    
    func signOut() {
        loading = true
        
        do {
            try Auth.auth().signOut()
            
            getUser()
        } catch {
            loading = false
        }
    }
    
    static func authenticate(withReason reason: String, completion: @escaping (Bool) -> Void) {
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            completion(success)
        }
    }
}
