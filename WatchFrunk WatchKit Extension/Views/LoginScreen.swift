//
//  LoginScreen.swift
//  WatchFrunk WatchKit Extension
//
//  Created by Winters, Tim on 9/24/20.
//

import SwiftUI

struct LoginScreen: View {
  @State var email: String = ""
  @State var password: String = ""
  @State var wasError = false
  @EnvironmentObject var userData: UserData
  
  var body: some View {
    VStack {
      if wasError {
        Text("Invalid Credentials")
          .foregroundColor(.red)
      }
      TextField("Email", text: $email)
        .textContentType(.emailAddress)
        .padding()
      SecureField("Password", text: $password)
        .textContentType(.password)
        .padding()
      Button("Sign In", action: {
        TeslaAPIBridge.authorize(email: email, password: password) { authToken, refreshToken, error in
          guard error == nil else {
            wasError = true
            return
          }
          wasError = false
          self.userData.authToken = authToken!
          self.userData.refreshToken = refreshToken!
        }
        
      })
    }
  }
}

struct LoginScreen_Previews: PreviewProvider {
  static var previews: some View {
    Text("Hello World")
//      .environmentObject(UserData())
  }
}
