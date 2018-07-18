//
//  ViewController.swift
//  MLKitSample
//
//  Created by anoop mohanan on 17/07/18.
//  Copyright © 2018 anoop mohanan. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var previewImageView:UIImageView!
    @IBOutlet weak var decodedTextView:UITextView!

    lazy var vision = Vision.vision()
    var selectedImage:UIImage?
    var isCameraAvailable = true
    var isPhotolibraryAvailable = true
    enum ImageSource {
        case Photolibrary
        case Camera
    }
    
    var `imagePickerController`:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.delegate = self
        // Check if camera, library etc are available, accordingly show the options
        validateSources()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function to check if sources are available
    func `validateSources`() {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            isCameraAvailable = false
        }
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            isPhotolibraryAvailable = false
        }
    }
//    +------------------------------------------------------------------+
//    |                       _____ _____  _______                       |
//    |                      |_   _| __\ \/ /_   _|                      |
//    |                        | | | _| >  <  | |                        |
//    |                        |_| |___/_/\_\ |_|                        |
//    |                                                                  |
//    +------------------------------------------------------------------+
    
    @IBAction func detectText(){
        recognizeText()
    }
    
    private func recognizeText(){
        
        guard let img = selectedImage else {
            return
        }
        
        //let vision = Vision.vision()
        let textDetector = vision.textDetector()
        let visionImage = VisionImage(image: img)

        textDetector.detect(in: visionImage) {[weak self] (visiontexts, error) in
            guard error == nil, let texts = visiontexts, !texts.isEmpty else {
                return
            }
            
            self?.processTextRecognitionData(texts: texts)
        }
    }
    
    private func processTextRecognitionData(texts: [VisionText]){
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
        decodedTextView.text = finalText
    }
//    +------------------------------------------------------------------+
//    |        _      _   ___ ___ _      ___ __  __   _   ___ ___        |
//    |       | |    /_\ | _ ) __| |    |_ _|  \/  | /_\ / __| __|       |
//    |       | |__ / _ \| _ \ _|| |__   | || |\/| |/ _ \ (_ | _|        |
//    |       |____/_/ \_\___/___|____| |___|_|  |_/_/ \_\___|___|       |
//    |                                                                  |
//    +------------------------------------------------------------------+
    
    @IBAction func recognizeImage(){
        decodeImage()
    }
    
    func decodeImage(){
        
//        let options = VisionLabelDetectorOptions(
//            confidenceThreshold: Constants.labelConfidenceThreshold
//        )
        guard let img = selectedImage else {
            return
        }
        
        //let vision = Vision.vision()
        let labelDetector = vision.labelDetector()
        let visionImage = VisionImage(image: img)
        
        labelDetector.detect(in: visionImage) { [weak self] (visionlabels, error) in
            guard error == nil, let labels = visionlabels, !labels.isEmpty else {
                return
            }
            
            self?.process(labels: labels)
        }
    }
    
    private func process(labels:[VisionLabel]){
        
        if let first = labels.first{
            let text = first.label + " \(first.confidence)"
            decodedTextView.text = text
        }
        for label in labels {
            let labelText = label.label
            let entityId = label.entityID
            let confidence = label.confidence
            print("\(labelText),\(entityId),\(confidence)")
        }
    }
    
//    +------------------------------------------------------------------+
//    |                 ___   _   ___  ___ ___  ___  ___                 |
//    |                | _ ) /_\ | _ \/ __/ _ \|   \| __|                |
//    |                | _ \/ _ \|   / (_| (_) | |) | _|                 |
//    |                |___/_/ \_\_|_\\___\___/|___/|___|                |
//    |                                                                  |
//    +------------------------------------------------------------------+
 
    @IBAction func recognizeBarcode(){
        decodeBarcode()
    }
    
    func decodeBarcode(){
        
        guard let img = selectedImage else {
            return
        }
//        let format = VisionBarcodeFormat.all
//        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        let barcodeDetector = vision.barcodeDetector()
        let visionImage = VisionImage(image: img)
        
        barcodeDetector.detect(in: visionImage) {[weak self] (visionBarcodes, error) in
            guard error == nil, let barcodes = visionBarcodes, !barcodes.isEmpty else {
                return
            }
            self?.process(barcodes: barcodes)
        }
    }
    
    private func process(barcodes:[VisionBarcode]){
        
        for barcode in barcodes {
            let corners = barcode.cornerPoints
            
            let displayValue = barcode.displayValue
            let rawValue = barcode.rawValue
            decodedTextView.text = rawValue

            let valueType = barcode.valueType
            switch valueType {
            case .wiFi:
                let ssid = barcode.wifi!.ssid
                let password = barcode.wifi!.password
                let encryptionType = barcode.wifi!.type
            case .URL:
                let title = barcode.url!.title
                let url = barcode.url!.url
            default:
                break
            }
        }
    }
    
//    +------------------------------------------------------------------+
//    |   ___ _   ___ ___   ___  ___ _____ ___ ___ _____ ___ ___  _  _   |
//    |  | __/_\ / __| __| |   \| __|_   _| __/ __|_   _|_ _/ _ \| \| |  |
//    |  | _/ _ \ (__| _|  | |) | _|  | | | _| (__  | |  | | (_) | .` |  |
//    |  |_/_/ \_\___|___| |___/|___| |_| |___\___| |_| |___\___/|_|\_|  |
//    |                                                                  |
//    +------------------------------------------------------------------+
 
    
    @IBAction func recognizeFace(){
        decodeFace()
    }
    
    func decodeFace(){
        guard let img = selectedImage else {
            return
        }

        let options = VisionFaceDetectorOptions()
        options.landmarkType = .all
        options.classificationType = .all
        options.modeType = .accurate
        let faceDetector = vision.faceDetector(options: options)
        let visionImage = VisionImage(image: img)
        
        faceDetector.detect(in: visionImage) {[weak self] (visionFaces, error) in
            guard error == nil, let faces = visionFaces, !faces.isEmpty else {
                return
            }
            self?.process(faces: faces)
        }
    }
    
    private func process(faces:[VisionFace]){
        
        for face in faces {
            var finalText = ""
            
            // If classification was enabled:
            if face.hasSmilingProbability {
                let smileProb = face.smilingProbability
                finalText += "smiling"
            }
            if face.hasRightEyeOpenProbability {
                let rightEyeOpenProb = face.rightEyeOpenProbability
                finalText += " right eye opened"
            }
            
            finalText += " Doing nothing"
            decodedTextView.text = finalText
            // If face tracking was enabled:
            if face.hasTrackingID {
                let trackingId = face.trackingID
            }
        }
        
    }
    // Show the action sheet
    @IBAction func pickPressed() {
        
        decodedTextView.text = ""
        pick()
    }
    
    // Show the action sheet
    func pick() {
        
        showActionSheet()
    }
    
    func showActionSheet() {
        
        let alertController = UIAlertController(title: "Choose", message: "", preferredStyle: .actionSheet)
        
        if (isCameraAvailable) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) {[weak self] (_) in
                self?.showImagePickerWith(source: .Camera)
            }
            alertController.addAction(cameraAction)
        }
        
        if (isPhotolibraryAvailable) {
            let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) {[weak self] (_) in
                self?.`showImagePickerWith`(source: .Photolibrary)
            }
            alertController.addAction(photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("Cancel")
        }
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Show an image picker with either camera or photo library as source
    func showImagePickerWith(source: ImageSource) {
        
        switch source {
        case .Camera:
            imagePickerController.sourceType = .camera
        case .Photolibrary:
            imagePickerController.sourceType = .photoLibrary
        }
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            updateImageView(with: image)
            //previewImageView.image = image
            //selectedImage = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    private func updateImageView(with image: UIImage) {
        let orientation = UIApplication.shared.statusBarOrientation
        var scaledImageWidth: CGFloat = 0.0
        var scaledImageHeight: CGFloat = 0.0
        switch orientation {
        case .portrait, .portraitUpsideDown, .unknown:
            scaledImageWidth = previewImageView.bounds.size.width
            scaledImageHeight = image.size.height * scaledImageWidth / image.size.width
        case .landscapeLeft, .landscapeRight:
            scaledImageWidth = image.size.width * scaledImageHeight / image.size.height
            scaledImageHeight = previewImageView.bounds.size.height
        }
        DispatchQueue.global(qos: .userInitiated).async {
            // Scale image while maintaining aspect ratio so it displays better in the UIImageView.
            var scaledImage = image.scaledImage(
                withSize: CGSize(width: scaledImageWidth, height: scaledImageHeight)
            )
            scaledImage = scaledImage ?? image
            guard let finalImage = scaledImage else { return }
            DispatchQueue.main.async {
                self.previewImageView.image = finalImage
                self.selectedImage = finalImage
            }
        }
    }
}
/// A `UIImage` category used for vision detection.
extension UIImage {
    /// Returns a scaled image to the given size.
    ///
    /// - Parameter size: Maximum size of the returned image.
    /// - Return: Image scaled according to the give size or `nil` if image resize fails.
    public func scaledImage(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Attempt to convert the scaled image to PNG or JPEG data to preserve the bitmap info.
        guard let image = scaledImage else { return nil }
        let imageData = UIImagePNGRepresentation(image) ??
            UIImageJPEGRepresentation(image, Constants.jpegCompressionQuality)
        return imageData.map { UIImage(data: $0) } ?? nil
    }
}

// MARK: - Constants
private enum Constants {
    static let jpegCompressionQuality: CGFloat = 0.8
}


