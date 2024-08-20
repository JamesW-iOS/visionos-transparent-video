//
//  SystemPlayerView.swift
//  TransparentVideoTest
//
//  Created by James Warren on 16/8/2024.
//

import AVKit
import SwiftUI

struct SystemPlayerView: UIViewControllerRepresentable {
    @Environment(VideoPlayerModel.self) private var model

    func makeUIViewController(context: Context) -> AVPlayerViewController {

        // Create a player view controller.
        let controller = makePlayerUI()

        // Return the configured controller object.
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {}

    @MainActor
    private func makePlayerUI() -> AVPlayerViewController {
        let controller = model.makePlayerUI()
        return controller
    }
}
