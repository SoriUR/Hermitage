//
//  NavigationViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit
import AVKit

class NavigationViewController: UIViewController {

    private lazy var model = NavigationModel()
    private lazy var captureSession = AVCaptureSession()

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

    private var isDecoding = false

    override func viewDidLoad() {
        super.viewDidLoad()
        model.convertBinaryString("")

        view.backgroundColor = .white
        self.title = "Navigation"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopSession()
    }

}

extension NavigationViewController: CameraController {

    func startSession() {
        guard let device = device, let input = try? AVCaptureDeviceInput(device: device) else {
            //todo: show device error
            return
        }
        captureSession.addInput(input)
        captureSession.addOutput(dataOutput)

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    func stopSession () {
        captureSession.stopRunning()

        captureSession.inputs.forEach {
            captureSession.removeInput($0)
        }

        captureSession.outputs.forEach {
            captureSession.removeOutput($0)
        }
    }
}

extension NavigationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard !isDecoding else {
            return
        }
        isDecoding = true

        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)

        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let buffer = baseAddress!.assumingMemoryBound(to: UInt8.self)

        var bytes = [UInt8]()

        //todo: refactor
        for i in 0...height {
            let luma = buffer[i * bytesPerRow + 0]
            bytes.append(luma)
        }

        if let binaryString = model.decodeBytes(bytes) {
            model.convertBinaryString(binaryString)
        }

        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        isDecoding = false
    }
}

