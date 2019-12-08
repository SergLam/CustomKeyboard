//
//  AudioRecorder.swift
//  HostingApp
//
//  Created by Serg Liamthev on 07.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import AVFoundation
import Foundation

class AudioRecorder: NSObject {
    
    private var session: AVAudioSession
    private var recorder: AVAudioRecorder?
    
    private let fileManager = LocalFileManager()
    
    private var isRecordingAllowed = false
    
    override init() {
        session = AVAudioSession.sharedInstance()
        super.init()
    }
    
    private func setupAudioSession() {
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            session.requestRecordPermission() { [weak self] allowed in
                self?.isRecordingAllowed = allowed
                guard allowed else { return }
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    func startRecording() {
        
        let fileName = "\(UUID().uuidString).\(CacheFileType.mp4Audio.rawValue)"
        guard let audioFilename = fileManager.cacheDirectoryURL?.appendingPathComponent(fileName) else {
            return
        }

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorder: AVAudioRecorderDelegate {
    
}
