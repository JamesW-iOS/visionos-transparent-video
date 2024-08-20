//
//  ContentView.swift
//  TransparentVideoTest
//
//  Created by James Warren on 16/8/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Open video") {
            openWindow(id: "video")
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
