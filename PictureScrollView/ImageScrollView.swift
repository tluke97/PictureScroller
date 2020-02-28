//
//  ImageScrollView.swift
//  PictureScrollView
//
//  Created by Tanner Luke on 1/3/20.
//  Copyright © 2020 Tanner Luke. All rights reserved.
//

import Foundation
import UIKit

final class ImageScrollView: UIScrollView {
    
    private let imageView = UIImageView()
    override var frame: CGRect {
        didSet {
            if frame.size != oldValue.size { setZoomScale() }
        }
    }
    
    required init(image: UIImage) {
        super.init(frame: .zero)
        
        imageView.image = image
        imageView.sizeToFit()
        addSubview(imageView)
        contentSize = imageView.bounds.size
        
        contentInsetAdjustmentBehavior = .never // Adjust content according to safe area if necessary
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper methods

    func setZoomScale() {
        print("running")
        let widthScale = frame.size.width / imageView.bounds.width
        let heightScale = frame.size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        minimumZoomScale = minScale
        zoomScale = minScale
    }

}

extension ImageScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
}

