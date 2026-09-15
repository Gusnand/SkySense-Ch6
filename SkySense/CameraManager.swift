import AVFoundation
import SwiftUI
import Combine

class CameraManager: ObservableObject {
    let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var videoDevice: AVCaptureDevice?
    
    @Published var isNightVisionEnabled = false {
        didSet {
            updateCameraSettings()
        }
    }
    
    init() {
        setupCamera()
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            return
        }
        self.videoDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                videoDeviceInput = input
            }
        } catch {
            print("Error creating camera input: \(error)")
        }
        
        session.commitConfiguration()
        
        // Start session in background to not block main thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
        
        updateCameraSettings()
    }
    
    private func updateCameraSettings() {
        guard let device = videoDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if isNightVisionEnabled {
                if device.isExposureModeSupported(.custom) {
                    let maxISO = device.activeFormat.maxISO
                    let duration = CMTimeMake(value: 1, timescale: 10)
                    device.setExposureModeCustom(duration: duration, iso: maxISO, completionHandler: nil)
                }
                
                device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 10)
                device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 10)
                
            } else {
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                
                device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
                device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 30)
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Error locking configuration: \(error)")
        }
    }
    
    func pause() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.session.isRunning == true {
                self?.session.stopRunning()
            }
        }
    }
    
    func resume() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.session.isRunning == false {
                self?.session.startRunning()
            }
        }
    }
}
