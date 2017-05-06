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

    private var captureSessionInitComplete: Bool = false

    fileprivate let supportedCodeTypes = [AVMetadataObjectTypeQRCode]
    fileprivate let greetingText = "Please, point camera on the bill, provided by waiter, and prepare for magic 😼"

    fileprivate var parsedItems: [Item] = []
    fileprivate var lastScannedObject: AVMetadataMachineReadableCodeObject?


    override func viewDidLoad() {
        super.viewDidLoad()
        initQrFrameView()
        navigationController?.setNavigationBarHidden(true, animated: false)

        videoPreviewView.previewLayer.session = captureSession

        // currently we need to track camera permissions, while app enters
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
        parserService.delegate = self
        startCodeScanning()
        setInitialUIState()

        navigationController?.setNavigationBarHidden(true, animated: true)

        if (!captureSessionInitComplete){
            self.initCaptureSession()
        }
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

    func willEnterForeground() {
        if (!captureSessionInitComplete){
            self.initCaptureSession()
        }
        lastScannedObject = nil;
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
            captureSessionInitComplete = true
        } catch {
            print(error)
            let alert = UIAlertController(
                    title: "Camera error",
                    message: "App can't work without camera access, please ensure it's working and you have provided camera permission in settings",
                    preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Retry", style: .cancel) { action in
                self.initCaptureSession()
            })
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { action in
                let settingsUrl = URL(string:UIApplicationOpenSettingsURLString)!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl)
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            })
            self.present(alert, animated: true)
        }
    }

    private func initQrFrameView() {
        qrFrameView.layer.borderColor = UIColor.green.cgColor
        qrFrameView.layer.borderWidth = 2
        view.addSubview(qrFrameView)
        view.bringSubview(toFront: qrFrameView)
    }

    fileprivate func setInitialUIState() {
        show(message: greetingText, style: .normal)
        //hide frame
        qrFrameView.frame = CGRect.zero
        
        self.lastScannedObject = nil
    }

    fileprivate func show(message: String, style: MessageStyle) {
        messageLabel.text = message
        switch style {
            case .error:
                messageLabel.backgroundColor = UIColor.red;
                break;
            case .normal:
                messageLabel.backgroundColor = UIColor.black;
                break;

        }
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

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if supportedCodeTypes.contains(metadataObj.type)  {

            // Get metadata for visual feedback with user
            let qrObject = videoPreviewView.previewLayer.transformedMetadataObject(for: metadataObj)
            qrFrameView.frame = qrObject!.bounds


            //avoid infinite parsing same objects
            guard metadataObj.stringValue != self.lastScannedObject?.stringValue else { return }
            parserService.parse(code: metadataObj.stringValue)
            self.lastScannedObject = metadataObj
        }
    }
}

extension QRScanViewController : ParserServiceDelegate {

    func didFinishParsing(result: ParsingResult) {
        if (result.success) {
            parsedItems = result.items!
            self.performSegue(withIdentifier: "showBillDetails", sender: self)
            setInitialUIState()
        } else {
            let errorMessage: String
            if (result.error?.isNetworkError() == true) {
                errorMessage = "Can't download QR code content, please check your internet connection and try again"
            } else {
                errorMessage = "Can't understand that QR code, please try another one."
            }
            show(message: errorMessage, style: .error)

            //scan for new codes
            startCodeScanning()
        }

    }

    func didStartParsing(code: String){
        //avoid a lot of duplicated callbacks
        pauseCodeScanning()
        show(message: "Parsing code... 🙈🙈🙈", style: .normal)
    }
}

fileprivate enum MessageStyle {
    case normal
    case error
}


