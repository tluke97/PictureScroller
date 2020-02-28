//
//  ViewController.swift
//  PictureScrollView
//
//  Created by Tanner Luke on 12/14/19.
//  Copyright © 2019 Tanner Luke. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    let image = UIImage(named: "flameyguy")
    private let scrollView = ImageScrollView(image: UIImage(named: "flameyguy")!)
    var scrollView1: UIScrollView!
    var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let picViewer = PictureViewer(frame: self.view.frame, imageArray: [UIImage(named: "Snoopy.jpg")!, UIImage(named: "Maverick.jpg")!, UIImage(named: "hd.jpg")!, UIImage(named: "flameyguy.jpg")!], scrollTo: CGPoint(x: 0, y: 0))
        
        //self.view.addSubview(picViewer)
        
        let button = UIButton(frame: CGRect(x: 30, y: 100, width: 100, height: 100))
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        button.backgroundColor = .gray
        self.view.addSubview(button)
        
        let button2 = UIButton(frame: CGRect(x: 150, y: 100, width: 100, height: 100))
        button2.addTarget(self, action: #selector(click2), for: .touchUpInside)
        button2.backgroundColor = .blue
        self.view.addSubview(button2)
        
        let button3 = UIButton(frame: CGRect(x: 30, y: 300, width: 100, height: 100))
        button3.addTarget(self, action: #selector(click3), for: .touchUpInside)
        button3.backgroundColor = .black
        self.view.addSubview(button3)
        
    }
    
    @objc func click() {
        let viewer = ScrollViewZoom(frame: self.view.frame, images: [UIImage(named: "Snoopy.jpg")!, UIImage(named: "Maverick.jpg")!, UIImage(named: "hd.jpg")!, UIImage(named: "flameyguy.jpg")!], parentView: self.view)
        self.view.addSubview(viewer)
        viewer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    @objc func click2() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        
        scrollView.frame = view.frame
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
    }
    
    @objc func click3() {
//        var sv = UIScrollView(frame: CGRect(x: 0, y: -193.66949152542372, width: self.view.frame.size.width, height: self.view.frame.size.height + (193.66949152542372) * 2))
//        sv.maximumZoomScale = 3.0
//        sv.minimumZoomScale = 1.0
//        sv.backgroundColor = .red
//        //sv.contentSize = CGSize(width: 375, height: 279.66101694915255)
//        sv.contentSize = self.view.frame.size
//        //let imageview = UIImageView(frame: CGRect(x:0 , y:193.66949152542372 * 2, width: 375, height: 279.66101694915255))
//        let imageview = UIImageView()
//        imageview.frame.size = CGSize(width: 375, height: 279.66101694915255)
//        imageview.center = self.view.center
//        //let imageview = UIImageView(frame: CGRect(x: 0, y: 193.66949152542372, width: self.view.frame.size.width, height: self.view.frame.size.height))
//        //imageview.contentMode = .scaleAspectFit
//        imageview.image = image
//        imageview.backgroundColor = .green
//        sv.delegate = self
//        sv.addSubview(imageview)
//        self.view.addSubview(sv)
        setup()
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    
    
    
    
    func setup() {
        imageView = UIImageView(image: image)
        scrollView1 = UIScrollView(frame: view.bounds)
        scrollView1.backgroundColor = UIColor.black
        scrollView1.contentSize = imageView.bounds.size
        scrollView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView1.contentOffset = CGPoint(x: 1000, y: 450)

        scrollView1.addSubview(imageView)
        view.addSubview(scrollView1)

        scrollView1.delegate = self

        setZoomScale(scrollview: scrollView1)

        setupGestureRecognizer()
    }
    

    override func viewWillLayoutSubviews()
    {
        setZoomScale(scrollview: scrollView1)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        guard let imageView = scrollView.subviews[0] as? UIImageView else { return }
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0

        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }

    func setZoomScale(scrollview: UIScrollView)
    {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height

        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }

    func setupGestureRecognizer()
    {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer)
    {
        if (scrollView.zoomScale > scrollView.minimumZoomScale)
        {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }


    

}

