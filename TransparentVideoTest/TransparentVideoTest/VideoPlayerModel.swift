//
//  VideoPlayerModel.swift
//  TransparentVideoTest
//
//  Created by James Warren on 16/8/2024.
//

import AVKit
import AVFoundation
import Combine

/// A model object that manages the playback of video.
@Observable @MainActor
public class VideoPlayerModel {

    /// A Boolean value that indicates whether playback is currently active.
    private(set) var isPlaying = false

    /// A Boolean value that indicates whether playback of the current item is complete.
    private(set) var isPlaybackComplete = false

    /// An object that manages the playback of a video's media.
    private static var player: AVPlayer = AVPlayer()

    /// The currently presented platform-specific video player user interface.
    ///
    /// On iOS, tvOS, and visionOS, the app uses `AVPlayerViewController` to present the video player user interface.
    /// The life cycle of an `AVPlayerViewController` object is different than a typical view controller. In addition
    /// to displaying the video player UI within your app, the view controller also manages the presentation of the media
    /// outside your app's UI such as when using AirPlay, Picture in Picture, or docked full window. To ensure the view
    /// controller instance is preserved in these cases, the app stores a reference to it here
    /// as an environment-scoped object.
    ///
    /// Call the `makePlayerUI()` method to set this value.
    private weak var playerUI: AnyObject? = nil

    private var cancellables = Set<AnyCancellable>()

    var isLoopingPlayback = false

    public init() {
        // Observe this notification to identify when a video plays to its end.
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.isPlaybackComplete = true
                if self.isLoopingPlayback {
                    self.play()
                }
            }
            .store(in: &cancellables)

        configureAudioSession()
    }

    /// Creates a new player view controller object.
    /// - Returns: a configured player view controller.
    func makePlayerUI() -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = Self.player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        #warning("Commenting out the below line will allow the video to play with alpha but will play in immersive mode")
        controller.experienceController.allowedExperiences = .only([.expanded])
        playerUI = controller
        return controller
    }

    /// Configures the audio session for video playback.
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio)
            Self.player.volume = 1
        } catch {
            print("Unable to configure audio session: \(error.localizedDescription)")
        }
    }

    /// Loads a video for playback in the requested presentation.
    /// - Parameters:
    ///   - video: The video to load for playback.
    public func loadVideo(_ video: AVPlayerItem) {
        isPlaybackComplete = false

        configureAudioExperience()

        // After preparing for coordination, load the video into the player and present it.
        replaceCurrentItem(with: video)
   }

    private func replaceCurrentItem(with video: AVPlayerItem) {
        // Create a new player item and set it as the player's current item.
        // Set the new player item as current, and begin loading its data.
        Self.player.replaceCurrentItem(with: video)
    }

    /// Clears any loaded media and resets the player model to its default state.
    private func reset() {
        Self.player.replaceCurrentItem(with: nil)
        playerUI = nil
        isPlaying = false
        isPlaybackComplete = false
    }

    /// Configures the spatial audio experience to best fit the presentation.
    private func configureAudioExperience() {
        do {
            try AVAudioSession.sharedInstance().setIntendedSpatialExperience(.headTracked(soundStageSize: .large, anchoringStrategy: .automatic))
        } catch {
            print("Unable to set the intended spatial experience. \(error.localizedDescription)")
        }
    }

    // MARK: - Transport Control

    public func play(_ item: AVPlayerItem, looping: Bool = false) {
        loadVideo(item)
        isLoopingPlayback = looping
        play()
    }

    public func play() {
        guard Self.player.timeControlStatus != .playing else {
            return
        }
        if isPlaybackComplete {
            seek(time: .zero)
            isPlaybackComplete = false
        }
        Self.player.play()
        isPlaying = true
    }

    public func resume() {
        guard !isPlaybackComplete else {
            return
        }

        Self.player.play()
    }

    public func pause() {
        Self.player.pause()
    }

    public func stop() {
        seek(time: .zero)
        pause()
    }

    public func seek(time: CMTime) {
        Self.player.seek(to: time)
    }

    public func togglePlayback() {
        Self.player.timeControlStatus == .paused ? play() : pause()
    }
}
