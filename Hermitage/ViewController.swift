import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {

    var isDecoding = false

    lazy var captureSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        return captureSession
    }()

    lazy var device: AVCaptureDevice = {
        let device = AVCaptureDevice.default(for: .video)!
        try! device.lockForConfiguration()

        let time = CMTime(value: 1, timescale: 6000)

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

        static var border: Float = Float(UInt8.max / 2)

        static func getState(dependsOn byte: UInt8) -> State {
            return Float(byte) > border ? .one : .zero
        }
    }

    func decode(bytes: [UInt8]) -> String? {
        var resultBinary: String = ""
        State.border = Float(bytes.max()! - bytes.min()!) / 2

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
            let etalonWidth = lastState == .zero ? zeroMinWidth : oneMinWidth
            guard currentWidth >= etalonWidth else { continue }

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

        return decodeBynaryString(resultBinary)
    }

    func decodeBynaryString(_ string: String) -> String? {
        let indexes = string.indexes(of: "0110")
        guard !indexes.isEmpty else {
            return nil
        }
        for i in 0..<indexes.count - 1 {
            var str = ""
            let startIndex = indexes[i]
            let endIndex = indexes[i+1]

            let tempString = String(string[startIndex...endIndex])
            for (index, char) in tempString.enumerated() {
                if index < 5 { continue }
                if index % 2 == 0 { continue }
                if index > tempString.count - 3 { continue}
                str += String(char)
            }
            if stringIsValid(str) {
                return String(str.dropLast())
            }
        }

        return nil
    }

    func stringIsValid(_ string: String) -> Bool {
        guard string.count == 13 else { return false }
        var oddCount = 0
        for (index, char) in string.enumerated() {
            if char == "1" {
                oddCount += 1
            }
        }
        guard oddCount % 2 == 0 else {
            return false
        }
        return true
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

            guard currentState.isDifferent(to: lastState), currentWidth > 4 else {
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

        guard !isDecoding else {
            return
        }
        isDecoding = true

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

        if let result = decode(bytes: bytes) {
            print(result)
        }

        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        isDecoding = false
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

extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range.lowerBound)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
