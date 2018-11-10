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

class StartNavigationViewController: UIViewController {

    // MARK: - Outlets and Actions

    @IBOutlet private weak var pulsatorCenter: UIView!
    @IBOutlet private weak var calculatePathBtn: RoundedButton!
    @IBOutlet private weak var roomLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!

    @IBAction private func calculatePath(_ sender: UIButton) {
        print("show new screen")
    }

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
        self.title = "Navigation"

        pulsatorCenter.layer.addSublayer(pulsator)
        pulsator.start()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopSession()
    }

    // MARK: - Private Functions

    private func handleLocation(_ location: Location) {
        print("current room is \(location.room)")
        DispatchQueue.main.async {
            self.pulsator.stop()
            self.calculatePathBtn.isHidden = false
            self.roomLabel.isHidden = false
            self.textLabel.isHidden = false
            self.roomLabel.text = String(location.room)
        }
    }

}

extension StartNavigationViewController: CameraController {

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

extension StartNavigationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)

        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let buffer = baseAddress!.assumingMemoryBound(to: UInt8.self)

        var bytes = [UInt8]()

        for column in 0..<height {
            var rowLuma = 0
            for row in 0..<bytesPerRow {
                rowLuma += Int(buffer[column * bytesPerRow + row])
            }
            bytes.append(UInt8(rowLuma / bytesPerRow))
        }

        model.decode(bytes: bytes)


        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }
}

extension StartNavigationViewController: LightDecoderDelegate {
    func didRecognizeLocation(_ location: Location) {
        stopSession()
        handleLocation(location)
    }
}
