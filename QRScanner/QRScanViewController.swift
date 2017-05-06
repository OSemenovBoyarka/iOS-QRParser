//
//  QRScanViewController.swift
//  QRScanner
//
//  Created by Alexander Semenov on 5/5/17.
//  Copyright © 2017 Dev Challenge. All rights reserved.
//

import UIKit
import AVFoundation

class QRScanViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var videoPreviewView: CapturePreviewView!

    let qrFrameView: UIView = UIView()

    let parserService = ParserService.shared

    private let captureSession = AVCaptureSession()
    private let captureMetadataOutput = AVCaptureMetadataOutput()

    fileprivate let supportedCodeTypes = [AVMetadataObjectTypeQRCode]
    fileprivate let greetingText = "Please, scan QR code in bill to begin"

    fileprivate var parsedItems: [Item] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        initQrFrameView()
        initCaptureSession()
        navigationController?.setNavigationBarHidden(true, animated: false)

        //TODO handle camera permissions
        videoPreviewView.previewLayer.session = captureSession
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
        parserService.delegate = self
        startCodeScanning()
        setInitialUIState()

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
        pauseCodeScanning()
    }

    fileprivate func startCodeScanning(){
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }


    fileprivate func pauseCodeScanning(){
        captureMetadataOutput.setMetadataObjectsDelegate(nil, queue:  nil)
    }


    override var prefersStatusBarHidden: Bool{
        return true
    }

    private func initCaptureSession() {
        do {
            let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let input = try AVCaptureDeviceInput(device: captureDevice)

            captureSession.addInput(input)
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            print(error)
            //TODO show error to user
        }
    }

    private func initQrFrameView() {
        qrFrameView.layer.borderColor = UIColor.green.cgColor
        qrFrameView.layer.borderWidth = 2
        view.addSubview(qrFrameView)
        view.bringSubview(toFront: qrFrameView)
    }

    fileprivate func setInitialUIState() {
        messageLabel.text = greetingText
        //hide frame
        qrFrameView.frame = CGRect.zero
    }

}

// MARK : segue control
extension QRScanViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showBillDetails"){
            (segue.destination as! BillDetailsTableViewController).items = self.parsedItems;
        }
    }



}

extension QRScanViewController : AVCaptureMetadataOutputObjectsDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        print("didOutPutMetadataObjects: \(metadataObjects)")
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            setInitialUIState()
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if supportedCodeTypes.contains(metadataObj.type)  {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let qrObject = videoPreviewView.previewLayer.transformedMetadataObject(for: metadataObj)
            qrFrameView.frame = qrObject!.bounds

            parserService.parse(code: metadataObj.stringValue)
        }
    }
}

extension QRScanViewController : ParserServiceDelegate {

    func didFinishParsing(result: ParsingResult) {
        if (result.success) {
            parsedItems = result.items!
            self.performSegue(withIdentifier: "showBillDetails", sender: self)
        } else {
            messageLabel.text = "Can't understand that QR code, try another one."
            startCodeScanning()
        }

    }

    func didStartParsing(code: String){
        //avoid a lot of duplicated callbacks
        pauseCodeScanning()
        messageLabel.text = "Parsing code..."
    }
}


