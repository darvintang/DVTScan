//
//  CIQRCodeFeature.swift
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

import DVTFoundation
import DVTUIKit
import UIKit

extension CIQRCodeFeature: NameSpace {}
public extension BaseWrapper where BaseType: CIQRCodeFeature {
    /// 坐标转换
    /// - Parameter imageView: 参考的视图，必须设置image之后
    /// - Returns: 返回该二维码相对于`imageView`的位置
    func into(_ imageView: UIImageView) -> CGRect {
        guard let image = imageView.image else {
            return .zero
        }
        let oldSize = image.size
        let mode = imageView.contentMode
        let rect = self.base.bounds.dvt.swapXY
        return rect.dvt.into(from: CGRect(origin: .zero, size: oldSize), fromScale: image.scale, to: imageView.bounds, mode: mode)
    }
}
