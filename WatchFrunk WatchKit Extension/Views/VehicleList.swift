//
//  OpenFrunk.swift
//  WatchFrunk WatchKit Extension
//
//  Created by Winters, Tim on 9/24/20.
//

import SwiftUI

struct VehicleList: View {
  var vehicles: [String: String]
  var body: some View {
      ScrollView {
        VStack(alignment: .center, spacing: 10) {
          ForEach(self.vehicles.sorted(by: >), id: \.key) { name, id in
            OpenFrunkButton(carName: name, carId: id)
          }
        }
      }
  }
}

struct VehicleList_Preview: PreviewProvider {
  static var previews: some View {
    Group {
    VehicleList(vehicles: ["Model S": "123",
                           "Model 3": "123",
                           "Model X": "123",
                           "Model Y": "123"])
      VehicleList(vehicles: ["Dragonfly": "123"])
    }
  }
}
