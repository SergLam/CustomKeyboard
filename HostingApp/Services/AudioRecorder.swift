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
    private var recordingTimer: Timer?
    
    private var currentRecordSaveURL: URL?
    private let fileManager = LocalFileManager()
    
    private var isRecordingAllowed = false
    
    deinit {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    override init() {
        session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        super.init()
    }
    
    func setupAudioSession() {
        
        switch session.recordPermission {
        case .granted:
            isRecordingAllowed = true
            
        case .denied:
            isRecordingAllowed = false
            
        case .undetermined:
            session.requestRecordPermission({ [weak self] allowed in
                guard let `self` = self else { return }
                self.isRecordingAllowed = allowed
                guard allowed else { return }
                
                guard self.recordingTimer != nil else {
                    let timer = Timer(timeInterval: 5, target: self, selector: #selector(self.startRecording), userInfo: nil, repeats: true)
                    self.recordingTimer = timer
                    RunLoop.current.add(timer, forMode: .common)
                    return
                }
            })
            
        default:
            break
        }
    }
    
    @objc
    private func startRecording() {
        
        guard recorder?.isRecording ?? false else {
            
            let fileName = "\(UUID().uuidString).\(CacheFileType.mp4.rawValue)"
            guard let audioFileURL = fileManager.cacheDirectoryURL?.appendingPathComponent(fileName) else {
                assertionFailure("Unable to create file path")
                return
            }
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 16000,
                AVEncoderBitRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
            
            do {
                recorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
                recorder?.delegate = self
                
                guard recorder?.prepareToRecord() ?? false else {
                    assertionFailure("Unable to create audio record file")
                    return
                }
                recorder?.record()
                currentRecordSaveURL = audioFileURL
                return
            } catch {
                assertionFailure(error.localizedDescription)
                currentRecordSaveURL = nil
                return
            }
        }
        recorder?.stop()
        recorder = nil
    }
    
    private func deleteCurrentAudioRecord() {
        if let path = currentRecordSaveURL?.absoluteString {
            fileManager.removeFile(filePath: path)
        }
    }
    
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag else {
            deleteCurrentAudioRecord()
            return
        }
        recorder.stop()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        guard let error = error else { return }
        deleteCurrentAudioRecord()
        assertionFailure(error.localizedDescription)
    }
    
}
