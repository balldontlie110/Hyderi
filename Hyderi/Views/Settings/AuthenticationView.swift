//
//  AuthenticationView.swift
//  Hyderi
//
//  Created by Ali Earp on 1/2/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import SDWebImageSwiftUI

struct AuthenticationView: View {
    @StateObject private var authenticationModel: AuthenticationModel = AuthenticationModel()
    
    var body: some View {
        if authenticationModel.loading {
            ProgressView()
        } else if authenticationModel.user == nil {
            signInButton
        } else {
            signOutButton
        }
    }
}

extension AuthenticationView {
    var signInButton: some View {
        Button {
            signIn()
        } label: {
            Image("googleSignIn")
                .resizable()
                .scaledToFit()
                .frame(height: 44)
        }
    }
    
    private func signIn() {
        Task {
            await authenticationModel.signIn()
        }
    }
}

extension AuthenticationView {
    var signOutButton: some View {
        Button(role: .destructive) {
            signOut()
        } label: {
            Text("Sign Out")
                .fontWeight(.semibold)
        }.buttonStyle(BorderedButtonStyle())
    }
    
    private func signOut() {
        authenticationModel.signOut()
    }
}

#Preview {
    AuthenticationView()
}
