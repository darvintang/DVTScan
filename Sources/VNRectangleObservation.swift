//
//  VNRectangleObservation.swift
//  DVTScan
//
//  Created by darvin on 2022/8/7.
//

/*

 MIT License

 Copyright (c) 2023 darvin http://blog.tcoding.cn

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

import UIKit
import Vision
import DVTFoundation

#if canImport(DVTUIKit_Extension)
    import DVTUIKit_Extension
#elseif canImport(DVTUIKit)
    import DVTUIKit
#endif

extension VNRectangleObservation: NameSpace { }
public extension BaseWrapper where BaseType: VNRectangleObservation {
    // MARK: Internal
    /// 坐标转换
    func into(canvasImage: UIImage, to: CGRect, mode: UIView.ContentMode = .scaleAspectFill) -> CGRect {
        let rect = self.convertRect(canvasImage)
        return rect.dvt.into(canvasSize: canvasImage.size, to: to, mode: mode)
    }

    // MARK: Private
    /// 图片坐标转换
    ///
    /// 目前只测试过right和up的
    ///
    /// - Parameter image: 识别的图片
    private func convertRect(_ image: UIImage) -> CGRect {
        let imageSize = image.size
        var w: CGFloat = 0, h: CGFloat = 0, x: CGFloat = 0, y: CGFloat = 0
        switch image.imageOrientation {
            case .down:
                w = self.base.boundingBox.width * imageSize.width
                h = self.base.boundingBox.height * imageSize.height
                x = self.base.boundingBox.minX * imageSize.width
                y = self.base.boundingBox.minY * imageSize.height
            case .right:
                w = self.base.boundingBox.width * imageSize.height
                h = self.base.boundingBox.height * imageSize.width
                x = self.base.boundingBox.minY * imageSize.width
                y = self.base.boundingBox.minX * imageSize.height
            case .left:
                w = self.base.boundingBox.width * imageSize.height
                h = self.base.boundingBox.height * imageSize.width
                x = imageSize.height - self.base.boundingBox.minY * imageSize.width - w
                y = self.base.boundingBox.minX * imageSize.height
            default:
                w = self.base.boundingBox.width * imageSize.width
                h = self.base.boundingBox.height * imageSize.height
                x = self.base.boundingBox.minX * imageSize.width
                y = imageSize.height - self.base.boundingBox.minY * imageSize.height - h
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
