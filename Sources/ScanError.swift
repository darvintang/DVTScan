//
//  ScanError.swift
//  DVTScan
//
//  Created by darvin on 2022/8/6.
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

import Foundation

public enum ScanError: Error {
    case previewFailure(state: String)
    case authorizationFailure(state: String)
    case cameraCaptureError
    case cameraCaptureFailure(state: String)
    case changeCameraFailure(state: String)

    var localizedDescription: String {
        switch self {
            case let .previewFailure(state):
                return "预览视图异常：\(state)"
            case let .authorizationFailure(state):
                return "用户未授权：\(state)"
            case let .cameraCaptureFailure(state):
                return "相机异常：\(state)"
            case let .changeCameraFailure(state):
                return "设置相机发生异常：\(state)"
            case .cameraCaptureError:
                return "相机异常：未获取到相机对象"
        }
    }
}
