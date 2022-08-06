//
//  ScanView.swift
//  DVTScan
//
//  Created by darvin on 2022/8/5.
//

/*

 MIT License

 Copyright (c) 2022 darvin http://blog.tcoding.cn

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 */

import AVFoundation
import UIKit

open class ScanView: UIView {
    /// 相机扫描会话
    private var session: CameraScan?

    /// 扫描结果快照图
    private lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        self.addSubview(imageView)
        return imageView
    }()

    /// 对焦标记图
    private lazy var focusView: UIImageView = {
        let view = UIImageView()
        self.configFocusView = { view in
            view.backgroundColor = .red
            view.bounds = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
            view.layer.cornerRadius = 16
        }
        self.addSubview(view)
        return view
    }()

    /// 扫描后选中结果的回调
    private var resultCompletion: ((_ result: String?) -> Void)?
    /// 扫描结束的回调，在这一步可以隐藏闪光灯、选择相册、扫描动画等操作了
    public var scanCompletion: ((_ list: [CIQRCodeFeature], _ image: UIImage?) -> Void)?

    /// 标记按钮的图片
    private var tagImage = UIImage(dvt: .red, size: CGSize(width: 24, height: 24))?.dvt.image(cornerRadii: 12)
    private var tagBackgroundImage = UIImage(dvt: .white.dvt.alpha(0.8), size: CGSize(width: 36, height: 36))?.dvt.image(cornerRadii: 18)

    /// 多码标记按钮配置
    public var configTagUIButton: ((_ btn: UIButton) -> Void)?

    /// 配置对焦的视图，默认是半径16的红色圆点
    public var configFocusView: ((_ focusView: UIImageView) -> Void)?

    /// 对焦动画，通过修改视图的透明度来实现视图的显示和隐藏
    public var focusAnimation: ((_ focusView: UIImageView) -> Void)?

    @available(*, unavailable, message: "视图的显示模式，为了限制设置为其它模式的时候导致对不上点，禁用该属性")
    override open var contentMode: UIView.ContentMode {
        willSet {
            if newValue != .scaleAspectFill {
                assertionFailure("只能为UIView.ContentMode.scaleAspectFill")
            }
        }
    }

    /// 对焦手势
    private lazy var focusGesture: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(self.focus(_:)))
    }()

    /// 缩放手势
    private lazy var zoomGesture: UIPinchGestureRecognizer = {
        UIPinchGestureRecognizer(target: self, action: #selector(self.zoom(_:)))
    }()

    /// 记录缩放比例
    private var oldScale: CGFloat = 1

    /// 支持的编码类型
    private var metadataTypes: [AVMetadataObject.ObjectType] = [.qr]

    /// 识别范围，预览视图参考坐标系
    private var cropRect: CGRect = .zero

    /// 是否正在扫描
    private var isScaning = false {
        didSet {
            if self.isScaning {
                self.addZoomGesture()
                self.addFocusGesture()
            } else {
                self.removeGesture()
            }
        }
    }

    /// 是否自动选中，如果扫描结果只有一个的时候该属性生效
    private var autoSelect = true

    /// 指定初始化函数
    /// - Parameters:
    ///   - metadataTypes: 扫码识别的类型
    ///   - cropRect: 扫码的范围，参考坐标系为当前控件
    ///   - autoSelect: 是否自动选中，多码识别的时候有效
    ///   - success: 选中二维码/条码的回调
    public convenience init(_ metadataTypes: [AVMetadataObject.ObjectType] = [.qr],
                            cropRect: CGRect = .zero,
                            autoSelect: Bool = true,
                            success: @escaping (_ result: String?) -> Void) {
        self.init(frame: .zero)
        self.autoSelect = autoSelect
        self.resultCompletion = success
        self.metadataTypes = metadataTypes
    }

    override private init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable, renamed: "init(_:cropRect:autoSelect:success:)", message: "未实现，请勿使用该方法初始化实例对象")
    public init() {
        fatalError("不能用该方法初始化实例对象")
    }

    @available(*, unavailable, renamed: "init(_:cropRect:autoSelect:success:)", message: "未实现，请勿使用该方法初始化实例对象")
    public required init?(coder: NSCoder) {
        fatalError("不能用该方法初始化实例对象")
    }

    /// 准备开始，会检查基本设置，在此之前必须要确定视图的bounds
    open func prepareStart() throws {
        if self.bounds == .zero {
            throw ScanError.previewFailure(state: "请先设置视图的界限")
        }

        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            throw ScanError.authorizationFailure(state: "请开启相机权限")
        }

        if self.isScaning {
            return
        }

        self.session = try CameraScan(preView: self, success: { [weak self] list, image in
            self?.isScaning = false
            if let image = image {
                self?.draw(list, image: image)
            }
        })
        self.resultImageView.frame = self.bounds
        self.resultImageView.isHidden = true
        self.session?.start()
        self.isScaning = true
    }

    /// 闪光灯开关
    @discardableResult open func setFlashlight(open: Bool) throws -> Bool? {
        return try self.session?.setFlashlight(open: open)
    }

    /// 扫码相册选中的图片
    /// - Parameter image: 要扫描的图片
    public func scan(_ image: UIImage) {
        let list = image.dvt.codes
        self.draw(list, image: image)
    }

    /// 绘制二维码/条码所在的位置
    /// - Parameters:
    ///   - list: 二维码/条码信息
    ///   - image: 资源图片
    open func draw(_ list: [CIQRCodeFeature], image: UIImage) {
        self.scanCompletion?(list, image)
        if list.count == 1, self.autoSelect {
            self.resultCompletion?(list.first?.messageString)
        }
        self.resultImageView.dvt.removeAllSubView()
        self.resultImageView.image = image
        self.resultImageView.isHidden = false
        for i in 0 ..< list.count {
            let res = list[i]
            let frame = res.dvt.into(self.resultImageView)
            if frame == .zero {
                continue
            }
            let btn = self.getTagButton(res)
            btn.center = frame.dvt.center
            self.resultImageView.addSubview(btn)
        }
    }

    /// 获取二维码/条码标记的按钮，默认随机颜色
    /// - Parameter feature: 二维码/条码信息
    open func getTagButton(_ feature: CIQRCodeFeature) -> UIButton {
        let btn = UIButton()

        btn.setImage(self.tagImage, for: .normal)
        btn.setBackgroundImage(self.tagBackgroundImage, for: .normal)
        btn.bounds = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))

        self.configTagUIButton?(btn)
        btn.dvt.add { [weak self] _ in
            self?.resultCompletion?(feature.messageString)
        }
        return btn
    }
}

fileprivate extension ScanView {
    /// 添加对焦手势
    func addFocusGesture() {
        self.addGestureRecognizer(self.focusGesture)
    }

    /// 点击对焦手势的处理
    @objc func focus(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        try? self.session?.focus(point)
        self.showFocusPoint(point)
    }

    /// 添加缩放手势
    func addZoomGesture() {
        self.addGestureRecognizer(self.zoomGesture)
    }

    /// 缩放手势处理
    @objc func zoom(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        // 记录手势开始时的缩放比例
        if gesture.state == .began {
            self.oldScale = (try? self.session?.videoZoomFactor()) ?? 1
        }
        // 修改相机的缩放比例
        if gesture.state == .changed {
            try? self.session?.zoom(self.oldScale * scale)
        }
    }

    /// 移除对焦和缩放的手势
    func removeGesture() {
        self.removeGestureRecognizer(self.focusGesture)
        self.removeGestureRecognizer(self.zoomGesture)
    }

    /// 显示对焦点位视图
    /// - Parameter point: 对焦的点
    func showFocusPoint(_ point: CGPoint) {
        self.bringSubviewToFront(self.focusView)
        self.configFocusView?(self.focusView)
        self.focusView.center = point
        self.focusView.alpha = 1
        UIView.animate(withDuration: 1) {
            self.focusView.alpha = 0
            self.focusAnimation?(self.focusView)
        }
    }
}

fileprivate class CameraScan: NSObject, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
    private let device = AVCaptureDevice.default(for: AVMediaType.video)
    private var inputDevice: AVCaptureDeviceInput?
    private var outputMetadata: AVCaptureMetadataOutput
    private let photoOutput = AVCapturePhotoOutput()

    private let session = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return previewLayer
    }()

    /// 存储返回结果
    private var arrayResult = [CIQRCodeFeature]()

    /// 扫码结果返回block
    private var successBlock: (_ result: [CIQRCodeFeature], _ image: UIImage?) -> Void

    /// 当前扫码结果是否处理
    private var isNeedScanResult = true

    private var cropRect = CGRect.zero

    private var screenshot: UIImage?

    fileprivate init(preView: UIView,
                     metadataTypes: [AVMetadataObject.ObjectType] = [.qr],
                     cropRect: CGRect = .zero,
                     success: @escaping ((_ result: [CIQRCodeFeature], _ image: UIImage?) -> Void)) throws {
        guard let device = self.device else {
            throw ScanError.cameraCaptureFailure(state: "未获取到相机对象")
        }
        self.successBlock = success
        self.outputMetadata = AVCaptureMetadataOutput()
        do {
            let input = try AVCaptureDeviceInput(device: device)
            self.inputDevice = input
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
        } catch let error {
            throw ScanError.cameraCaptureFailure(state: error.localizedDescription)
        }
        super.init()
        self.cropRect = cropRect

        if self.session.canAddOutput(self.outputMetadata) {
            self.session.addOutput(self.outputMetadata)
        }

        if self.session.canAddOutput(self.photoOutput) {
            self.session.addOutput(self.photoOutput)
            self.photoOutput.isHighResolutionCaptureEnabled = true
        }

        self.session.sessionPreset = AVCaptureSession.Preset.high

        self.outputMetadata.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.outputMetadata.metadataObjectTypes = metadataTypes

        var frame: CGRect = preView.bounds
        frame.origin = CGPoint.zero
        self.previewLayer.frame = frame
        preView.layer.insertSublayer(self.previewLayer, at: 0)

        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
            try self.safetyChangeDevice {
                device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
            }
        }
    }

    fileprivate func metadataOutput(_ output: AVCaptureMetadataOutput,
                                    didOutput metadataObjects: [AVMetadataObject],
                                    from connection: AVCaptureConnection) {
        guard self.isNeedScanResult else {
            return
        }
        self.captureImage()
    }

    fileprivate func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            self.isNeedScanResult = true
            return
        }

        let list = image.dvt.codes
        if list.isEmpty {
            self.isNeedScanResult = true
        } else {
            self.screenshot = image
            list.forEach { feature in
                if feature.messageString != nil {
                    if self.cropRect != .zero {
                        let rect = feature.bounds.dvt.into(from: CGRect(origin: .zero, size: image.size), fromScale: image.scale, to: self.previewLayer.bounds, mode: .scaleAspectFill)
                        if self.cropRect.contains(rect) {
                            self.arrayResult.append(feature)
                        }
                    } else {
                        self.arrayResult.append(feature)
                    }
                }
            }
        }
        self.complete()
    }

    fileprivate func start() {
        if !self.session.isRunning {
            self.isNeedScanResult = true
            self.session.startRunning()
        }
    }

    fileprivate func stop() {
        if self.session.isRunning {
            self.isNeedScanResult = false
            self.session.stopRunning()
            self.previewLayer.removeFromSuperlayer()
        }
    }

    private func isGetFlash() throws -> Bool {
        let device = try self.safetyDevice()
        return device.hasFlash && device.hasTorch
    }

    @discardableResult
    fileprivate func setFlashlight(open: Bool) throws -> Bool {
        guard try self.isGetFlash() else {
            return false
        }

        try self.safetyChangeDevice {
            self.inputDevice?.device.torchMode = open ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
        }

        return (try self.safetyDevice().torchMode == .on) == open
    }

    @discardableResult
    fileprivate func changeFlashlight() throws -> Bool {
        let device = try self.safetyDevice()
        let torch = device.torchMode == .off
        return try self.setFlashlight(open: torch)
    }

    private func safetyDevice() throws -> AVCaptureDevice {
        guard let device = self.device else {
            throw ScanError.cameraCaptureError
        }
        return device
    }

    private func safetyChangeDevice(_ event: () -> Void) throws {
        let device = try self.safetyDevice()
        do {
            try device.lockForConfiguration()
            event()
            device.unlockForConfiguration()
        } catch let error {
            throw ScanError.changeCameraFailure(state: error.localizedDescription)
        }
    }

    private func captureImage() {
        self.isNeedScanResult = false
        let settings = AVCapturePhotoSettings()
        if let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first {
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            ]
            settings.previewPhotoFormat = previewFormat
        }
        self.photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func complete() {
        if self.arrayResult.isEmpty {
            self.isNeedScanResult = true
        } else {
            self.stop()
            self.successBlock(self.arrayResult, self.screenshot)
        }
    }

    fileprivate func focus(_ point: CGPoint) throws {
        let focusPoint = self.previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        let device = try self.safetyDevice()
        try self.safetyChangeDevice {
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
            }
            if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
            }
            if device.isExposureModeSupported(.autoExpose) {
                device.exposureMode = .autoExpose
            }
        }
    }

    fileprivate func zoom(_ scale: CGFloat) throws {
        let device = try self.safetyDevice()
        var newScale = scale
        if newScale > device.maxAvailableVideoZoomFactor {
            newScale = device.maxAvailableVideoZoomFactor
        }
        if newScale < device.minAvailableVideoZoomFactor {
            newScale = device.minAvailableVideoZoomFactor
        }
        try self.safetyChangeDevice {
            device.videoZoomFactor = newScale
        }
    }

    fileprivate func videoZoomFactor() throws -> CGFloat {
        try self.safetyDevice().videoZoomFactor
    }
}
