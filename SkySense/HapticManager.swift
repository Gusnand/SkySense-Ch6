import Foundation
import CoreHaptics
import Combine
import UIKit

class HapticManager: ObservableObject {
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    
    private var isEngineReady = false
    private var lastHapticState: HapticState = .silent
    
    enum HapticState {
        case silent
        case slowPulsing
        case rapidPulsing
        case locked
    }
    
    init() {
        prepareHaptics()
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.restartEngine()
        }
    }
    
    func restartEngine() {
        do {
            try engine?.start()
            isEngineReady = true
        } catch {
            print("Failed to restart engine: \(error)")
        }
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            engine?.isAutoShutdownEnabled = true
            
            engine?.stoppedHandler = { reason in
                print("Haptic Engine Stopped: \(reason)")
                self.isEngineReady = false
            }
            
            engine?.resetHandler = { [weak self] in
                print("Haptic Engine Reset")
                do {
                    try self?.engine?.start()
                    self?.isEngineReady = true
                } catch {
                    print("Failed to restart engine: \(error)")
                }
            }
            
            try engine?.start()
            isEngineReady = true
        } catch {
            print("Failed to initialize haptics: \(error)")
        }
    }
    
    func updateHapticFeedback(distance: Double) {
        guard isEngineReady else { return }
        
        let newState: HapticState
        if distance > 15.0 {
            newState = .silent
        } else if distance > 5.0 {
            newState = .slowPulsing
        } else if distance > 1.0 {
            newState = .rapidPulsing
        } else {
            newState = .locked
        }
        
        if newState == lastHapticState { return }
        
        stopContinuous()
        
        switch newState {
        case .silent:
            break
        case .slowPulsing:
            playContinuousPulse(intensity: 0.4, sharpness: 0.3, loopDuration: 0.6)
        case .rapidPulsing:
            playContinuousPulse(intensity: 0.8, sharpness: 0.7, loopDuration: 0.15)
        case .locked:
            playLockThump()
        }
        
        lastHapticState = newState
    }
    
    private func playContinuousPulse(intensity: Float, sharpness: Float, loopDuration: TimeInterval) {
        guard let engine = engine else { return }
        do {
            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpnessParam], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            continuousPlayer?.loopEnabled = true
            continuousPlayer?.loopEnd = loopDuration
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play continuous pulse: \(error)")
        }
    }
    
    private func playLockThump() {
        guard let engine = engine else { return }
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play lock thump: \(error)")
        }
    }
    
    func stopContinuous() {
        do {
            try continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            print("Error stopping continuous player: \(error)")
        }
        continuousPlayer = nil
    }
    
    func pause() {
        stopContinuous()
        lastHapticState = .silent
    }
}
