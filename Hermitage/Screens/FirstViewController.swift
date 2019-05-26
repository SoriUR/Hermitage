import UIKit
import AVFoundation
import Cartography

class ViewController: UIViewController {

    var captureOutput = false

    // Views
    let previewView = UIView()
    let imageView = UIImageView()
    let controlsContainer = UIView()
    let isoSlider = UISlider()
    let isoLabel = UILabel()
    let exposureSlider = UISlider()
    let exposureLabel = UILabel()
    let snapButton = UIButton()
    let acceptButton = UIButton()
    let resultLabel = UITextView()

    // Camera
    private lazy var dataOutput: AVCaptureVideoDataOutput = {
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

        return dataOutput
    }()

    let captureSession = AVCaptureSession()
    private var device: AVCaptureDevice!

    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(previewView)
        view.addSubview(snapButton)
        view.addSubview(controlsContainer)
        view.addSubview(acceptButton)
        view.addSubview(imageView)
        view.addSubview(resultLabel)

        controlsContainer.addSubview(isoSlider)
        controlsContainer.addSubview(isoLabel)
        controlsContainer.addSubview(exposureSlider)
        controlsContainer.addSubview(exposureLabel)

        constrain(view, previewView, snapButton, controlsContainer, acceptButton, imageView) {
            $0.top == $1.top
            $0.left == $1.left
            $1.width == $0.width / 2

            $1.bottom == $3.top

            $3.bottom == $2.top
            $3.left == $0.left
            $3.right == $0.right

            $2.centerX == $0.centerX * 0.5
            $2.height == 50
            $2.width == $0.width / 2.5

            $4.width == $2.width
            $4.height == $2.height
            $4.centerY == $2.centerY
            $4.centerX == $0.centerX * 1.5

            $5.width == $1.width
            $5.height == $1.height
            $5.right == $0.right
            $5.top == $1.top
        }

        constrain(resultLabel, snapButton) {
            $0.top == $1.bottom
        }

        constrain(view, resultLabel) {
            $1.bottom == $0.bottom - 15
            $1.left == $0.left + 10
            $1.right == $0.right - 10
            $1.height == 40
        }

        constrain(controlsContainer, exposureSlider, exposureLabel) {
            $0.left == $1.left
            $0.top == $1.top
            $1.height == 50
            $1.right == $2.left

            $2.right == $0.right
            $2.height == $1.height
            $2.centerY == $1.centerY
            $2.width == 100
        }

        constrain(controlsContainer, isoSlider, isoLabel) {
            $0.left == $1.left
            $0.bottom == $1.bottom
            $1.height == 50
            $1.right == $2.left

            $2.right == $0.right
            $2.height == $1.height
            $2.centerY == $1.centerY
            $2.width == 100
        }

        constrain(exposureSlider, isoSlider) {
            $0.bottom == $1.top
        }

        view.backgroundColor = .black

        previewView.contentMode = .scaleAspectFit
        previewView.clipsToBounds = true
        previewView.layer.masksToBounds = true

        previewView.layer.borderColor = UIColor.white.cgColor
        previewView.layer.borderWidth = 2

        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2

        setupButton(btn: acceptButton, text: "Применить")
        setupButton(btn: snapButton, text: "Сделать снимок")

        exposureSlider.minimumValue = 1000
        exposureSlider.maximumValue = 8000
        exposureSlider.value = 1000
        exposureSlider.addTarget(self, action: #selector(rangeChanged), for: .valueChanged)

        isoSlider.minimumValue = 29
        isoSlider.maximumValue = 464
        isoSlider.value = 464
        isoSlider.addTarget(self, action: #selector(rangeChanged), for: .valueChanged)

        isoLabel.text = String(Int(isoSlider.value))
        isoLabel.textAlignment = .center
        isoLabel.textColor = .white

        exposureLabel.textColor = .white
        exposureLabel.text = String(Int(exposureSlider.value))
        exposureLabel.textAlignment = .center

        resultLabel.textColor = .white
        resultLabel.textAlignment = .center
        resultLabel.backgroundColor = .black

        createDevice()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addLayer()
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopSession()
    }

    @objc func onClickMyButton(sender: UIButton) {
        if sender == acceptButton {
            refreshSession()
        } else {
            captureOutput = true
        }
    }

    @objc func rangeChanged(sender: UISlider) {

        if sender == exposureSlider {
            exposureLabel.text = String(Int(sender.value))
        } else {
            isoLabel.text = String(Int(sender.value))
        }
    }

    private func setupButton(btn: UIButton, text: String) {
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.addTarget(self, action: #selector(onClickMyButton), for: .touchUpInside)
    }

    func refreshSession() {
        createDevice()
        stopSession()
        startSession()
    }

    func createDevice() {
        guard let device = AVCaptureDevice.default(for: .video), (try? device.lockForConfiguration()) != nil else {
            return
        }

        let exposureDuration = CMTime(value: 1, timescale: CMTimeScale(exposureLabel.text!)!)

        device.setExposureModeCustom(duration: exposureDuration, iso: Float(isoLabel.text!)!, completionHandler: nil)

        self.device = device
    }

    func startSession() {
        guard let device = device, let input = try? AVCaptureDeviceInput(device: device) else {
            assertionFailure("Capture Device Error")
            return
        }
        captureSession.addInput(input)
        captureSession.addOutput(dataOutput)

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    func stopSession() {
        captureSession.stopRunning()

        captureSession.inputs.forEach {
            captureSession.removeInput($0)
        }

        captureSession.outputs.forEach {
            captureSession.removeOutput($0)
        }
    }

    func addLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspect

        let rootLayer = previewView.layer
        rootLayer.masksToBounds = true
        layer.frame = rootLayer.bounds
        rootLayer.addSublayer(layer)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        if captureOutput {
            captureOutput = false

            let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

            CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)

            let ciimage: CIImage = CIImage(cvPixelBuffer: pixelBuffer)

            DispatchQueue.main.async {
                self.imageView.image = UIImage(ciImage: ciimage).rotate(radians: .pi / 2)
            }

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

            decode(bytes: bytes)

            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
    }

    func decode(bytes: [UInt8]) {
        guard let str = decodeBytes(bytes) else {
            return
        }

        DispatchQueue.main.async {
            self.resultLabel.text = str
        }
    }

    func decodeBytes(_ bytes: [UInt8]) -> String? {
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

        resultBinary.append(lastState.rawValue)

        return resultBinary
    }

    private func decodeWidths(from bytes: [UInt8]) -> (zeroWidth: Int, oneWidth: Int) {
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

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
