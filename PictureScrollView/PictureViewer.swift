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
    
    func getImageViewSize(image: UIImage?) -> CGSize {
        let containerView = self
        let imageView = UIImageView()

         if let image = image {
             let ratio = image.size.width / image.size.height
             if containerView.frame.width > containerView.frame.height {
                 let newHeight = containerView.frame.width / ratio
                 imageView.frame.size = CGSize(width: containerView.frame.width, height: newHeight)
             }
             else{
                 let newWidth = containerView.frame.height * ratio
                 imageView.frame.size = CGSize(width: newWidth, height: containerView.frame.height)
             }
         }
        return imageView.frame.size
    }
    
    func createScrollView(imageArray: [UIImage], frame: CGRect, scrollTo: CGPoint?) {
        var i = 0
        imgViews = [UIImageView]()
        let width = UIScreen.main.bounds.width
        self.contentSize = CGSize(width: (width + 20) * CGFloat(4), height: frame.size.height)
        self.maximumZoomScale = 3.0
        self.minimumZoomScale = 1.0
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        //self.contentInsetAdjustmentBehavior = .always
        self.backgroundColor = .black
        self.frame = CGRect(x: 0, y: 0, width: frame.size.width + 20, height: frame.size.height)
        self.delegate = delegate
        self.isPagingEnabled = true
        self.alwaysBounceHorizontal = true
        
        while i < imageArray.count {
            //let size = getImageViewSize(image: imageArray[i])
            let imageView = UIImageView(frame: CGRect(x: (width + 20) * CGFloat(i), y: 0, width: frame.size.width, height: frame.size.height))
            imageView.backgroundColor = .blue
            //print(self.contentSize.height)
            //imageView.getPicture(path: imageArray[i])
            //print("image size: ", getImageViewSize(image: imageArray[i]))
            imageView.image = imageArray[i]
            imageView.tag = i
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFit
            imgViews.reverse()
            imgViews.append(imageView)
            //storedScrollData = ScrollViewStorage(storedViews: imgViews, index: 0)
            self.addSubview(imageView)
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
    
}
