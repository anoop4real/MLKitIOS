//
//  CameraController.swift
//  MLKitSample
//
//  Created by anoop mohanan on 23/07/18.
//  Copyright © 2018 anoop mohanan. All rights reserved.
//

import Foundation
import AVFoundation
import FirebaseMLVision

protocol UpdateUIProtocol {

    func updateUIWith(message: String)
}

enum CameraControllerError: Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}
class CameraController: NSObject {

    var cameraCaptureSession: AVCaptureSession?
    private var isUsingFrontCamera = false
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var uiUpdater: UpdateUIProtocol?

    init(with uiUpdater: UpdateUIProtocol) {

        self.uiUpdater = uiUpdater
    }
    func prepare(completionHandler: @escaping (Error?) -> Void) {

        DispatchQueue(label: "prepare").async {[weak self] in
            do {
                self?.createCaptureSession()

                try self?.configureDeviceInputs()
                try self?.configureMediaOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }

                return
            }

            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    func startSession() {
        self.cameraCaptureSession?.startRunning()
    }

    func stopSession() {
        self.cameraCaptureSession?.stopRunning()
    }

    func fetchPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let captureSession = self.cameraCaptureSession else {
            print("Unable to show peview")
            return nil
        }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        return self.previewLayer
    }

    func createCaptureSession() {
        self.cameraCaptureSession = AVCaptureSession()
        cameraCaptureSession?.sessionPreset = .medium
    }

    func configureDeviceInputs() throws {
        let cameraPosition: AVCaptureDevice.Position = self.isUsingFrontCamera ? .front : .back
        guard let device = self.captureDevice(forPosition: cameraPosition) else {
            print("Failed to get capture device for camera position: \(cameraPosition)")
            throw( CameraControllerError.noCamerasAvailable)
        }
        do {
            let currentInputs = self.cameraCaptureSession?.inputs
            for input in currentInputs! {
                self.cameraCaptureSession?.removeInput(input)
            }
            let input = try AVCaptureDeviceInput(device: device)
            guard (self.cameraCaptureSession?.canAddInput(input))! else {
                print("Failed to add capture session input.")
                return
            }
            self.cameraCaptureSession?.addInput(input)
        } catch {
            print("Failed to create capture device input: \(error.localizedDescription)")
            throw( CameraControllerError.unknown)
        }

    }

    func configureMediaOutput() throws {

        self.cameraCaptureSession?.beginConfiguration()

        let output = AVCaptureVideoDataOutput()
        output.videoSettings =
            [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
        let outputQueue = DispatchQueue(label: "OutputQueue")
        output.setSampleBufferDelegate(self, queue: outputQueue)
        guard (self.cameraCaptureSession?.canAddOutput(output))! else {
            print("Failed to add capture session output.")
            throw( CameraControllerError.inputsAreInvalid)
        }
        self.cameraCaptureSession?.addOutput(output)
        self.cameraCaptureSession?.commitConfiguration()
    }
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
    }

    //    +------------------------------------------------------------------+
    //    |                       _____ _____  _______                       |
    //    |                      |_   _| __\ \/ /_   _|                      |
    //    |                        | | | _| >  <  | |                        |
    //    |                        |_| |___/_/\_\ |_|                        |
    //    |                                                                  |
    //    +------------------------------------------------------------------+
    private func recognizeText(with selectedImage: VisionImage) {

        let vision = Vision.vision()
        let textDetector = vision.textDetector()
        let visionImage = selectedImage

        textDetector.detect(in: visionImage) {[weak self] (visiontexts, error) in
            guard error == nil, let texts = visiontexts, !texts.isEmpty else {
                return
            }

            self?.processTextRecognitionData(texts: texts)
        }
    }

    private func processTextRecognitionData(texts: [VisionText]) {
        var finalText = ""
        for text in texts {
            if let block = text as? VisionTextBlock {
                for line in block.lines {
                    // ...
                    for element in line.elements {
                        // ...
                        print("Elements are \(element.text)")
                    }
                }
            }

            finalText += text.text
            _ = text.cornerPoints
        }
        uiUpdater?.updateUIWith(message: finalText)
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let _ = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Error getting image buffer from sample buffer.")
            return
        }
        let visionImage = VisionImage(buffer: sampleBuffer)
        let metadata = VisionImageMetadata()
        metadata.orientation = .rightTop
        visionImage.metadata = metadata
        recognizeText(with: visionImage)
    }
}
