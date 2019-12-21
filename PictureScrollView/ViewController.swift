//
//  ViewController.swift
//  PictureScrollView
//
//  Created by Tanner Luke on 12/14/19.
//  Copyright © 2019 Tanner Luke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let picViewer = PictureViewer(frame: self.view.frame, imageArray: [UIImage(named: "Snoopy.jpg")!, UIImage(named: "Maverick.jpg")!, UIImage(named: "hd.jpg")!, UIImage(named: "flameyguy.jpg")!], scrollTo: CGPoint(x: 0, y: 0))
        
        //self.view.addSubview(picViewer)
        
        let button = UIButton(frame: CGRect(x: 30, y: 100, width: 100, height: 100))
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        button.backgroundColor = .gray
        self.view.addSubview(button)
        
        
        print("hello world")
    }
    
    @objc func click() {
        let viewer = ScrollViewZoom(frame: self.view.frame, images: [UIImage(named: "Snoopy.jpg")!, UIImage(named: "Maverick.jpg")!, UIImage(named: "hd.jpg")!, UIImage(named: "flameyguy.jpg")!], parentView: self.view)
        self.view.addSubview(viewer)
    }


}

