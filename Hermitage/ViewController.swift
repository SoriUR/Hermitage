import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {

    var images = [UIImage]()

    lazy var captureSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        return captureSession
    }()

    lazy var device: AVCaptureDevice = {
        let device = AVCaptureDevice.default(for: .video)!
        try! device.lockForConfiguration()

        let time = CMTime(value: 1, timescale: 4000)

        device.setExposureModeCustom(duration: time, iso: device.activeFormat.maxISO, completionHandler: nil)

        return device
    }()

    lazy var imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
//        dataOutput.availableVideoPixelFormatTypes
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)

        captureSession.commitConfiguration()
        captureSession.addInput(input)
        captureSession.startRunning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = CGRect(x: 0, y: 0, width: 375, height: view.bounds.height/2)

        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: view.bounds.height/2, width: 375, height: view.bounds.height/2)
    }

    enum State: String {
        case zero = "0"
        case one = "1"

        func isDifferent(to state: State) -> Bool {
            return self != state
        }

        static var border: UInt8 = UInt8.max / 2

        static func getState(dependsOn byte: UInt8) -> State {
            return byte > border ? .one : .zero
        }
    }

    func decode(bytes: [UInt8]) {
        var resultBinary: String = ""
        //        State.border = (bytes.max()! - bytes.min()!) / 2
        State.border = 0

        let (zeroMinWidth, oneMinWidth) = decodeWidths(from: bytes)
        var lastState = State.getState(dependsOn: bytes[0])
        let function: (_ width: Int) -> Int = { width in
            let etalonWidth = lastState == .zero ? zeroMinWidth : oneMinWidth
            return width / etalonWidth
        }

        var currentWidth = 0
        for byteIndex in 1..<bytes.count {
            let currentByte = bytes[byteIndex]
            let currentState = State.getState(dependsOn: currentByte)
            currentWidth += 1

            guard currentState.isDifferent(to: lastState) else {
                continue
            }

           let digitsNumber = function(currentWidth)
            for _ in 0..<digitsNumber {
                resultBinary.append(lastState.rawValue)
            }

            lastState = currentState
            currentWidth = 0
        }

        let digitsNumber = function(currentWidth+1)
        for _ in 0..<digitsNumber {
            resultBinary.append(lastState.rawValue)
        }

        print(resultBinary)
    }

    func decodeWidths(from bytes: [UInt8]) -> (zeroWidth: Int, oneWidth: Int) {
        var lastState = State.getState(dependsOn: bytes[0])
        var zeroWidth = Int.max
        var oneWidth = Int.max

        var currentWidth = 0
        for byteIndex in 1..<bytes.count {
            let currentByte = bytes[byteIndex]
            let currentState = State.getState(dependsOn: currentByte)
            currentWidth += 1

            guard currentState.isDifferent(to: lastState) else {
                continue
            }

            switch lastState {
            case .zero:
                zeroWidth = min(zeroWidth, currentWidth)
            case .one:
                 oneWidth = min(zeroWidth, currentWidth)
            }

            lastState = currentState
            currentWidth = 0
        }

        return (zeroWidth, oneWidth)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        let ciimage: CIImage = CIImage(cvPixelBuffer: pixelBuffer)

        DispatchQueue.main.async {
            self.imageView.image = ciimage.noir
        }

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

        bytes = [0,1,0,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,1,1,0,0,0,0,0,1,0,0]
        decode(bytes: bytes)
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
        let uiimage = UIImage(cgImage: cgImage)

        return uiimage
    }
}
