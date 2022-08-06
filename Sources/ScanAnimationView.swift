//
//  ScanAnimationView.swift
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

import UIKit

open class ScanAnimationView: UIView, CAAnimationDelegate {
    public var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    public var duration: CGFloat = 2

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.frame = .zero
        return view
    }()

    private var isStop = true

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }

    public init() {
        super.init(frame: .zero)
        self.didInitialize()
    }

    private func didInitialize() {
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.addSubview(self.imageView)
    }

    @available(*, unavailable, message: "不支持xib/sb")
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func start() {
        let rect = self.bounds
        guard let image = self.image, rect != .zero else {
            return
        }

        let newWidth = rect.width
        let height = rect.height
        let newHeight = rect.width / image.size.width * image.size.height
        self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: -newHeight), size: CGSize(width: newWidth, height: newHeight))

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")

        opacityAnimation.fromValue = 0.5
        opacityAnimation.byValue = 1
        opacityAnimation.toValue = 0.8
        opacityAnimation.duration = self.duration
        self.layer.removeAllAnimations()
        self.layer.add(opacityAnimation, forKey: "opacityAniamtion")

        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.toValue = height
        animation.duration = self.duration
        animation.delegate = self
        self.imageView.layer.removeAllAnimations()
        self.imageView.layer.add(animation, forKey: "imageView.animation")
        self.isStop = false
    }

    open func stop() {
        self.isStop = true
        self.layer.removeAllAnimations()
        self.imageView.layer.removeAllAnimations()
    }

    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !self.isStop {
            self.start()
        }
    }
}
