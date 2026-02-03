//
//  CameraManager.swift
//  MikroskopCapture
//
//  Verwaltet die Kamera/Capture-Card Verbindung
//

import AVFoundation
import AppKit
import Combine

class CameraManager: NSObject, ObservableObject {
    @Published var isSessionRunning = false
    @Published var availableDevices: [AVCaptureDevice] = []
    @Published var selectedDevice: AVCaptureDevice?
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var error: String?
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var movieOutput = AVCaptureMovieFileOutput()
    private var currentInput: AVCaptureDeviceInput?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var tempVideoURL: URL?
    
    // Callback für fertige Aufnahmen
    var onPhotoCaptured: ((NSImage) -> Void)?
    var onVideoCaptured: ((URL) -> Void)?
    
    // Für Live-Preview
    private var sampleBufferDelegate: SampleBufferDelegate?
    @Published var previewImage: NSImage?
    
    override init() {
        super.init()
        setupSession()
        checkAndRequestAuthorization()

        // Beobachte Geräteänderungen
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceConnected),
            name: .AVCaptureDeviceWasConnected,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceDisconnected),
            name: .AVCaptureDeviceWasDisconnected,
            object: nil
        )

        // Re-check authorization when app becomes active (user might have changed it in Settings)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func appDidBecomeActive() {
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)

        // Only act if status changed from denied/restricted to authorized
        if authorizationStatus != .authorized && currentStatus == .authorized {
            DispatchQueue.main.async {
                self.authorizationStatus = currentStatus
                self.error = nil
                self.discoverDevices()
                self.startSession()
            }
        }
    }

    private func checkAndRequestAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }

        switch status {
        case .authorized:
            discoverDevices()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.discoverDevices()
                    } else {
                        self?.error = "Camera access denied. Please enable in System Settings > Privacy & Security > Camera."
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.error = "Camera access denied. Please enable in System Settings > Privacy & Security > Camera."
            }
        @unknown default:
            break
        }
    }
    
    private func setupSession() {
        session.sessionPreset = .high
    }
    
    func discoverDevices() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        DispatchQueue.main.async {
            self.availableDevices = discoverySession.devices
            
            // Auto-select preferred device from settings
            let preferredDeviceID = UserDefaults.standard.string(forKey: "preferredDeviceID")
            
            if let preferredID = preferredDeviceID,
               let device = self.availableDevices.first(where: { $0.uniqueID == preferredID }) {
                self.selectDevice(device)
            } else if let firstExternal = self.availableDevices.first(where: { $0.deviceType == .external }) {
                // Fallback: erstes externes Gerät (wahrscheinlich Elgato)
                self.selectDevice(firstExternal)
            } else if let firstDevice = self.availableDevices.first {
                self.selectDevice(firstDevice)
            }
        }
    }
    
    @objc private func deviceConnected(_ notification: Notification) {
        discoverDevices()
    }
    
    @objc private func deviceDisconnected(_ notification: Notification) {
        discoverDevices()
    }
    
    func selectDevice(_ device: AVCaptureDevice) {
        session.beginConfiguration()
        
        // Entferne alten Input
        if let currentInput = currentInput {
            session.removeInput(currentInput)
        }
        
        // Entferne alte Outputs
        session.outputs.forEach { session.removeOutput($0) }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
                currentInput = input
                selectedDevice = device
            }
            
            // Video Data Output für Preview
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            sampleBufferDelegate = SampleBufferDelegate { [weak self] image in
                DispatchQueue.main.async {
                    self?.previewImage = image
                }
            }
            
            videoOutput.setSampleBufferDelegate(sampleBufferDelegate, queue: DispatchQueue(label: "videoQueue"))
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            // Movie Output für Videoaufnahme
            movieOutput = AVCaptureMovieFileOutput()
            if session.canAddOutput(movieOutput) {
                session.addOutput(movieOutput)
            }
            
            DispatchQueue.main.async {
                self.error = nil
            }
            
        } catch {
            DispatchQueue.main.async {
                self.error = "Gerät konnte nicht verbunden werden: \(error.localizedDescription)"
            }
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        guard !session.isRunning else { return }
        guard authorizationStatus == .authorized else {
            if authorizationStatus == .notDetermined {
                checkAndRequestAuthorization()
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = self?.session.isRunning ?? false
            }
        }
    }

    func openPrivacySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func stopSession() {
        guard session.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }
    
    // MARK: - Foto aufnehmen
    
    func capturePhoto() {
        guard let image = previewImage else {
            error = "Kein Bild verfügbar"
            return
        }
        
        onPhotoCaptured?(image)
    }
    
    // MARK: - Video aufnehmen
    
    func startVideoRecording() {
        guard !isRecording else { return }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "temp_recording_\(Date().timeIntervalSince1970).mov"
        tempVideoURL = tempDir.appendingPathComponent(fileName)
        
        guard let url = tempVideoURL else { return }
        
        movieOutput.startRecording(to: url, recordingDelegate: self)
        
        isRecording = true
        recordingStartTime = Date()
        recordingDuration = 0
        
        // Timer für Sekundenanzeige
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            DispatchQueue.main.async {
                self.recordingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func stopVideoRecording() {
        guard isRecording else { return }
        
        movieOutput.stopRecording()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.error = "Aufnahme fehlgeschlagen: \(error.localizedDescription)"
                return
            }
            
            self?.onVideoCaptured?(outputFileURL)
        }
    }
}

// MARK: - Sample Buffer Delegate für Live Preview

class SampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let onFrame: (NSImage) -> Void
    
    init(onFrame: @escaping (NSImage) -> Void) {
        self.onFrame = onFrame
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        onFrame(nsImage)
    }
}
