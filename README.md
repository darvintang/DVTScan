# DVTScan

[![Version](https://img.shields.io/cocoapods/v/DVTScan.svg?style=flat)](https://cocoapods.org/pods/DVTScan)[![License](https://img.shields.io/cocoapods/l/DVTScan.svg?style=flat)](https://cocoapods.org/pods/DVTScan)[![Platform](https://img.shields.io/cocoapods/p/DVTScan.svg?style=flat)](https://cocoapods.org/pods/DVTScan)[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)

基于原生Vision库实现的二维码/条码扫码封装

```swift
open class ScanView : UIView {

    /// 识别范围，预览视图参考坐标系
    public var cropRect: CGRect

    /// 是否自动选中，如果扫描结果只有一个的时候该属性生效
    public var autoSelect: Bool

    /// 扫描结束的回调，在这一步可以隐藏闪光灯、选择相册、扫描动画等操作了
    public var scanCompletion: ((_ list: [VNBarcodeObservation], _ image: UIImage?) -> Void)?

    /// 多码标记按钮配置
    public var configTagUIButton: ((_ btn: UIButton) -> Void)?

    /// 配置对焦的视图，默认是半径16的红色圆点
    public var configFocusView: ((_ focusView: UIImageView) -> Void)?

    /// 对焦动画，通过修改视图的透明度来实现视图的显示和隐藏
    public var focusAnimation: ((_ focusView: UIImageView) -> Void)?

    public var brightnessBlock: ((_ brightness: CGFloat) -> Void)? { get set }

    /// 指定初始化函数
    /// - Parameters:
    ///   - metadataTypes: 扫码识别的类型
    ///   - cropRect: 扫码的范围，参考坐标系为当前控件
    ///   - autoSelect: 是否自动选中，多码识别的时候有效
    ///   - success: 选中二维码/条码的回调
    public convenience init(_ barcodeTypes: [BarcodeType] = [.qr, .code128], cropRect: CGRect = .zero, autoSelect: Bool = true, success: @escaping (_ result: String?) -> Void)

    /// 准备开始，会检查基本设置，在此之前必须要确定视图的bounds
    open func prepareStart() throws -> Bool

    /// 闪光灯开关
    open func setFlashlight(open: Bool) throws -> Bool?

    /// 扫码相册选中的图片
    ///
    /// 扫码结果不在扫码区域范围内的结果会忽略
    ///
    /// - Parameter image: 要扫描的图片
    public func scan(_ image: UIImage)

    /// 绘制二维码/条码所在的位置
    ///
    /// - Parameters:
    ///   - list: 二维码/条码信息
    ///   - image: 资源图片
    ///   - mode: 结果预览模式
    open func draw(_ list: [VNBarcodeObservation], image: UIImage, mode: UIView.ContentMode = .scaleAspectFill)

    /// 获取二维码/条码标记的按钮
    ///
    /// 默认会有一个layer的缩放动画，如果不需要可以移除，key: animation
    ///
    /// - Parameter feature: 二维码/条码信息
    open func getTagButton(_ barcode: VNBarcodeObservation) -> UIButton
}

public class ScanTool {

    public static func scan(_ image: UIImage, symbologies: [BarcodeType] = [.code128, .qr], completion: @escaping (_ result: [VNBarcodeObservation]?) -> Void)
}

```
