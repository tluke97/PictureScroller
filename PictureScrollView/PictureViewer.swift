//
//  PictureViewer.swift
//  PictureScrollView
//
//  Created by Tanner Luke on 12/14/19.
//  Copyright © 2019 Tanner Luke. All rights reserved.
//

import Foundation
import UIKit

class PictureViewer: UIScrollView {
    
    var imgViews: [UIImageView]!
    override var frame: CGRect {
        didSet {
            if frame.size != oldValue.size { setZoomScale() }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, imageArray: [UIImage], scrollTo: CGPoint?) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width + 20, height: frame.height))
        createScrollView(imageArray: imageArray, frame: frame, scrollTo: scrollTo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createScrollView(imageArray: [UIImage], frame: CGRect, scrollTo: CGPoint?) {
        var i = 0
        imgViews = [UIImageView]()
        let width = UIScreen.main.bounds.width
        self.backgroundColor = .green
        self.contentSize = CGSize(width: (width + 20) * CGFloat(4), height: frame.size.height)
        self.maximumZoomScale = 3.0
        self.minimumZoomScale = 1.0
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.contentInsetAdjustmentBehavior = .never
        //self.contentInsetAdjustmentBehavior = .always
        self.frame = CGRect(x: 0, y: 0, width: frame.size.width + 20, height: frame.size.height)
        self.delegate = delegate
        self.isPagingEnabled = true
        self.alwaysBounceHorizontal = true
        
        while i < imageArray.count {
            //let size = getImageViewSize(image: imageArray[i])
            //print("Image size: ", getImageViewSize(image: imageArray[i], amountOfViews: 4))
            let imageView = UIImageView(frame: CGRect(x: (width + 20) * CGFloat(i), y: 0, width: frame.size.width, height: frame.size.height))
            imageView.backgroundColor = .blue
            //print(self.contentSize.height)
            //imageView.getPicture(path: imageArray[i])
            //print("image size: ", getImageViewSize(image: imageArray[i]))
            imageView.image = imageArray[i]
            imageView.tag = i
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFit
            //imageView.frame.size.width = imageView.contentClippingRect.size.width
            //imageView.frame.size.height = imageView.contentClippingRect.size.height
            //imageView.frame.origin.y = (self.frame.height / 2) - (imageView.frame.size.height / 2)
            imgViews.reverse()
            imgViews.append(imageView)
            //storedScrollData = ScrollViewStorage(storedViews: imgViews, index: 0)
            self.addSubview(imageView)
            //print("size: ", imageView.contentClippingRect)
            i += 1
        }
        for subview in self.subviews {
            guard let imagev = subview as? UIImageView else { return }
            //print(getImageViewSize(image: imagev.image))
        }
        if let pt = scrollTo {
            self.contentOffset = pt
        }
    }
    
    public func setZoomScale() {
        guard let imageView = subviews[0] as? UIImageView else { return }
        let widthScale = frame.size.width / imageView.bounds.width
        let heightScale = frame.size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        minimumZoomScale = minScale
        zoomScale = minScale
    }
    
    
}

extension PictureViewer: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let imageView = scrollView.subviews[0] as? UIImageView else { return }
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
}


extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        scale = bounds.width / image.size.width
//        if image.size.width > image.size.height {
//            scale = bounds.width / image.size.width
//        } else {
//            scale = bounds.height / image.size.height
//        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}

