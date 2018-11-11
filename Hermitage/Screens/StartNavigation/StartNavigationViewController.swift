//
//  NavigationViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit
import AVKit
import Pulsator
import Cartography

class StartNavigationViewController: UIViewController {

    // MARK: - Outlets and Actions

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var pulsatorCenter: UIView!

    private lazy var model: StartNavigationModel =  {
        let model = StartNavigationModel()
        model.delegate = self

        return model
    }()
    private lazy var captureSession = AVCaptureSession()
    private lazy var pulsator: Pulsator = {
        let pulsator = Pulsator()
        pulsator.numPulse = 3
        pulsator.radius = UIScreen.main.bounds.width / 2
        pulsator.animationDuration = 6
        pulsator.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor

        return pulsator
    }()

    private lazy var device: AVCaptureDevice? = {
        guard let device = AVCaptureDevice.default(for: .video),
            (try? device.lockForConfiguration()) != nil else {
                return nil
        }

        let exposureDuration = CMTime(value: 1, timescale: 6000)
        device.setExposureModeCustom(duration: exposureDuration, iso: device.activeFormat.maxISO, completionHandler: nil)

        return device
    }()

    private lazy var dataOutput: AVCaptureVideoDataOutput = {
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

        return dataOutput
    }()

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.title = "Навигатор"

        pulsatorCenter.layer.addSublayer(pulsator)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startSession()
        pulsator.start()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopSession()
        pulsator.stop()
    }

    // MARK: - Private Functions

    private func handleLocation(_ location: Location) {

        DispatchQueue.main.async {
            let mapVC = MapViewController()
            mapVC.location = location
            self.navigationController?.pushViewController(mapVC, animated: true)
        }
    }
}

extension StartNavigationViewController: CameraController {

    func startSession() {
        guard let device = device, let input = try? AVCaptureDeviceInput(device: device) else {
            assertionFailure("Capture Device Error")
            return
        }
        captureSession.addInput(input)
        captureSession.addOutput(dataOutput)

        captureSession.commitConfiguration()
        captureSession.startRunning()
        print("---Start---")
    }

    func stopSession() {
        print("---Stop---")
        captureSession.stopRunning()

        captureSession.inputs.forEach {
            captureSession.removeInput($0)
        }

        captureSession.outputs.forEach {
            captureSession.removeOutput($0)
        }
    }
}

extension StartNavigationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)

//        let ciimage: CIImage = CIImage(cvPixelBuffer: pixelBuffer)
//
//        DispatchQueue.main.async {
//            self.imageView.image = ciimage.noir
//        }

        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let buffer = baseAddress!.assumingMemoryBound(to: UInt8.self)

        var bytes = [UInt8]()

        for column in 0..<height { // 1080
            var rowLuma = 0
            for row in 0..<bytesPerRow { // 1920
                rowLuma += Int(buffer[column * bytesPerRow + row])
            }
            let mid = rowLuma / bytesPerRow
            bytes.append(UInt8(mid))
        }

        model.decode(bytes: bytes)


        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }
}

extension CIImage {
    var noir: UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(self, forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let uiimage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)

        return uiimage
    }
}


extension StartNavigationViewController: LightDecoderDelegate {

    func didRecognizeLocation(_ location: Location) {
        stopSession()
        handleLocation(location)
    }

    
}
