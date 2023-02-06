//
//  ScanTool.swift
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
import Foundation
import AVFoundation

public enum BarcodeType: String, CaseIterable {
    case aztec, code128, code39, code93, dataMatrix, ean13, ean8, itf14, pdf417, qr, upce

    // MARK: Internal
    var vnSymbology: VNBarcodeSymbology {
        switch self {
            case .aztec:
                return .aztec
            case .code128:
                return .code128
            case .code39:
                return .code39
            case .code93:
                return .code93
            case .dataMatrix:
                return .dataMatrix
            case .ean13:
                return .ean13
            case .ean8:
                return .ean8
            case .itf14:
                return .itf14
            case .pdf417:
                return .pdf417
            case .qr:
                return .qr
            case .upce:
                return .upce
        }
    }

    var avObjectType: AVMetadataObject.ObjectType {
        switch self {
            case .aztec:
                return .aztec
            case .code128:
                return .code128
            case .code39:
                return .code39
            case .code93:
                return .code93
            case .dataMatrix:
                return .dataMatrix
            case .ean13:
                return .ean13
            case .ean8:
                return .ean8
            case .itf14:
                return .itf14
            case .pdf417:
                return .pdf417
            case .qr:
                return .qr
            case .upce:
                return .upce
        }
    }
}

public class ScanTool {
    public static func scan(_ image: UIImage, symbologies: [BarcodeType] = [.code128, .qr], completion: @escaping (_ result: [VNBarcodeObservation]?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        let barcodeRequest = VNDetectBarcodesRequest { request, _ in
            if let observations = request.results as? [VNBarcodeObservation] {
                DispatchQueue.main.async {
                    completion(observations)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }

        barcodeRequest.symbologies = symbologies.compactMap { $0.vnSymbology }
        let handler = VNImageRequestHandler(cgImage: cgImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do { try handler.perform([barcodeRequest]) }
            catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
