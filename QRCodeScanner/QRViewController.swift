//
//  QRViewController.swift
//  QRCodeScanner
//
//  Created by udn on 2018/8/1.
//  Copyright © 2018年 dengli. All rights reserved.
//

import UIKit
import AVFoundation

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var video = AVCaptureVideoPreviewLayer()
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define capture device
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print(error)
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        output.metadataObjectTypes = [.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        self.configureVideoOrientation()
    }
    
    private func configureVideoOrientation() {
        if let connection = video.connection {
            let orientation = UIDevice.current.orientation
            
            if connection.isVideoOrientationSupported,
                let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
                video.frame = self.view.bounds
                video.connection?.videoOrientation = videoOrientation
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 { return }
        session.stopRunning()
        if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject, object.type == .qr {
            let alertController = UIAlertController(title: "QRCode", message: object.stringValue, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.session.startRunning()
            }
            let openAction = UIAlertAction(title: "Open", style: .default) { _ in
                if let urlString = object.stringValue, let url = URL(string: urlString) {
                    UIApplication.shared.open(url, options: [:])
                    self.session.startRunning()
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(openAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
}

