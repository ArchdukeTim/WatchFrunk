//
//  PageNavigator.swift
//  WatchFrunk WatchKit Extension
//
//  Created by Winters, Tim on 9/24/20.
//

import SwiftUI

struct PagerManager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content

    //Set the initial values for the variables
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    @GestureState private var translation: CGFloat = 0

    //Set the animation
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            .offset(x: self.translation)

                
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.width
                }.onEnded { value in
                    let offset = value.translation.width / geometry.size.width
                    let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                    self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                }
            )
        }
    }
}

struct PagerManager_Preview: PreviewProvider {
    @State static var currentIndex = 0
    
    static var previews: some View {
        PagerManager(pageCount: 2, currentIndex: PagerManager_Preview.$currentIndex, content: {
            Text("Hello")
            Text("World")
        })
    }
}
