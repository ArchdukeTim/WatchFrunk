//
//  Settings.swift
//  WatchFrunk WatchKit Extension
//
//  Created by Winters, Tim on 9/24/20.
//

import SwiftUI

struct Settings: View {
  @EnvironmentObject var userData: UserData
  @State var signedIn = true
  
  var body: some View {
    if signedIn {
      Button(action: {}) {
        Text("Sign Out")
          .gesture(
            LongPressGesture(minimumDuration: 1)
              .onEnded { _ in
                TeslaAPIBridge.logout(){_, _, _ in
                  self.userData.authToken = ""
                  self.userData.refreshToken = ""
                  signedIn = false
                }})
      }
    } else {
      Text("Signed Out")
    }
  }
}

struct Settings_Previews: PreviewProvider {
  static var previews: some View {
    Settings()
  }
}
