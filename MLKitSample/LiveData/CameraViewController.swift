//
//  CameraViewController.swift
//  MLKitSample
//
//  Created by anoop mohanan on 23/07/18.
//  Copyright © 2018 anoop mohanan. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var decodedTextView: UITextView!
    var cameraController: CameraController!
    var presenterProtocol: UpdateUIProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraController.startSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraController.stopSession()
    }
    func initialize() {

        cameraController = CameraController(with: self)
        cameraController.prepare {[weak self] (err) in

            if let error = err {
                print(error.localizedDescription)
            } else {
                self?.addPreviewLayer()
            }

        }

    }

    func addPreviewLayer() {
        guard let prevLayer = cameraController.fetchPreviewLayer() else {
            return
        }
        prevLayer.frame = cameraView.frame
        cameraView.layer.addSublayer(prevLayer)
    }

    @IBAction func dismissView() {

        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CameraViewController: UpdateUIProtocol {
    func updateUIWith(message: String) {

        decodedTextView.text = message
    }

}
