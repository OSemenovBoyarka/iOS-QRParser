//
//  CapturePreviewView.swift
//  QRScanner
//
//  Created by Alexander Semenov on 5/5/17.
//  Copyright © 2017 Dev Challenge. All rights reserved.
//

import UIKit
import AVFoundation

class CapturePreviewView: UIView {

    let previewLayer = AVCaptureVideoPreviewLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.addSublayer(previewLayer)
        resizePreviewLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        resizePreviewLayer()
    }
    
    private func resizePreviewLayer() {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        let videoOrientation: AVCaptureVideoOrientation = statusBarOrientation.videoOrientation ?? .portrait
       
        previewLayer.connection?.videoOrientation = videoOrientation
        previewLayer.frame = bounds
    }


}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}
