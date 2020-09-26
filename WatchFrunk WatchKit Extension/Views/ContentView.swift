//
//  ContentView.swift
//  WatchFrunk WatchKit Extension
//
//  Created by Winters, Tim on 9/23/20.
//

import SwiftUI
import KeychainAccess

struct ContentView: View {
    @State var currentPage: Int = 0
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        if self.userData.signedIn {
            VStack {
                PagerManager(pageCount: 2, currentIndex: $currentPage) {
                  VehicleList(vehicles: self.userData.vehicles)
                  Settings()
                }
                Spacer()
                //Page Control
                HStack{
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(currentPage==1 ? Color.gray:Color.white)
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(currentPage==1 ? Color.white:Color.gray)
                }
            }
        } else {
            LoginScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
  static var userData: UserData = {
    var ud = UserData()
    ud.signedIn = true
    ud.vehicles = ["Dragonfly": "1234"]
    return ud
  }()
    static var previews: some View {
      ContentView()
        .environmentObject(userData)
    }
}
