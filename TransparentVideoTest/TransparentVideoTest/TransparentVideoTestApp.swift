//
//  TransparentVideoTestApp.swift
//  TransparentVideoTest
//
//  Created by James Warren on 16/8/2024.
//

import AVKit
import SwiftUI

@main
struct TransparentVideoTestApp: App {
    @State private var videoPlayerModel = VideoPlayerModel()

    var body: some Scene {
        WindowGroup(id: "initial") {
            ContentView()
        }

        WindowGroup(id: "video") {
            SystemPlayerView()
                .environment(videoPlayerModel)
                .onAppear {
                    let url = Bundle.main.url(forResource: "example", withExtension: "mov")!
                    videoPlayerModel.play(AVPlayerItem(url: url))
                }
        }
     }
}
