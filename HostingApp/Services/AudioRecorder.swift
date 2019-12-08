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
    private var currentRecordSaveURL: URL?
    
    private let fileManager = LocalFileManager()
    
    private var isRecordingAllowed = false
    
    override init() {
        session = AVAudioSession.sharedInstance()
        super.init()
    }
    
    func setupAudioSession() {
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            session.requestRecordPermission() { [weak self] allowed in
                self?.isRecordingAllowed = allowed
                guard allowed else { return }
                self?.startRecording()
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    func startRecording() {
        
        let fileName = "\(UUID().uuidString).\(CacheFileType.mp4Audio.rawValue)"
        guard let audioFileURL = fileManager.cacheDirectoryURL?.appendingPathComponent(fileName) else {
            assertionFailure("Unable to create file path")
            return
        }

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            recorder?.delegate = self
            recorder?.record()
            currentRecordSaveURL = audioFileURL
        } catch {
            assertionFailure(error.localizedDescription)
            currentRecordSaveURL = nil
        }
    }
    
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag else { return }
        recorder.stop()
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        guard let error = error else { return }
        assertionFailure(error.localizedDescription)
    }
    
}
