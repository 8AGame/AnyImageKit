//
//  AudioCapture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import AVFoundation

protocol AudioCaptureDelegate: class {
    
    func captureOutput(audio output: AVCaptureAudioDataOutput, didOutput sampleBuffer: CMSampleBuffer)
}

final class AudioCapture: NSObject {
    
    weak var delegate: AudioCaptureDelegate?
    
    private let output = AVCaptureAudioDataOutput()
    private let workQueue = DispatchQueue(label: "org.AnyImageProject.AnyImageKit.DispatchQueue.AudioCapture")
    
    init(session: AVCaptureSession) {
        super.init()
        do {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone],
                                                                    mediaType: .audio,
                                                                    position: .unspecified)
            guard let microphone = discoverySession.devices.first else {
                _print("Can't find the specified audio device")
                return
            }
            let input = try AVCaptureDeviceInput(device: microphone)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                _print("Can't add audio device input")
            }
            output.setSampleBufferDelegate(self, queue: workQueue)
            if session.canAddOutput(output) {
                session.addOutput(output)
            } else {
                _print("Can't add audio device output")
            }
        } catch {
            _print(error)
        }
    }
    
    func startRunning() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            _print(error)
        }
        
    }
    
    func stopRunning() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            _print(error)
        }
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate
extension AudioCapture: AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(audio: self.output, didOutput: sampleBuffer)
    }
}
