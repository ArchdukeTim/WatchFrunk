//
//  Circular.swift
//  WatchFrunk WatchKit Extension
//
//  Created by Winters, Tim on 9/25/20.
//

import SwiftUI
import ClockKit

struct Circular: View {
    var body: some View {
      Image("Circular")
    }
  
}

struct Circular_Previews: PreviewProvider {
    static var previews: some View {
      CLKComplicationTemplateGraphicRectangularFullView(Circular())
        .previewContext()
    }
  
}
