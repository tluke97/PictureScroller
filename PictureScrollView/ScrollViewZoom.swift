//
//  ScrollViewZoom.swift
//  PictureScrollView
//
//  Created by Tanner Luke on 12/14/19.
//  Copyright © 2019 Tanner Luke. All rights reserved.
//

import Foundation
import UIKit

class ScrollViewZoom: UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var superScrollView: PictureViewer!
    var imagesToView: [UIImage] = []
    var storedScrollData: ScrollViewStorage!
    var currentWindow: UIWindow?
    var contentView: UIView!
    var startingIndex: Int!
    
    
    var panCoord = CGPoint(x: 0, y: 0)
    let topView = UIView()
    let bottomView = UIView()
    var zoomed: Bool = false
    var hideTap: UITapGestureRecognizer!
    var zoomTap: UITapGestureRecognizer!
    var subScrollViews = [UIScrollView]()
    var subImageViews = [UIImageView]()
    var gottaFinish: Bool = false
    var started: Bool = false
    var blurEffectView: UIVisualEffectView!
    var dismissGesture: UIPanGestureRecognizer!
    var postDisplayed: IndexPath?
    var likeBtn: UIButton!
    var commentBtn: UIButton!
    var moreBtn: UIButton!
    var dismissBtn: UIButton!
    var likeCount: UILabel!
    var paging = false
    var shouldShowTopView: Bool = false
    var parentView: UIView!
    
    //Struct holds the imageviews and index that is currently being used
    struct ScrollViewStorage {
        var storedViews: [UIImageView]
        var index: Int
    }
    
    //holds the drag directions
    enum Direction {
        case up
        case down
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, images: [UIImage], parentView: UIView) {
        super.init(frame: frame)
        //setting up the images that are in the scrollview
        self.imagesToView = images
        //this is to get the current superview of the object
        self.parentView = parentView
        //this gets the starting index. it can be set to other points than 0
        self.startingIndex = 0
        //helper function to actually set up the view
        setupView(initialFrame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: parentView.frame.size.height), view: UIImageView(frame: parentView.frame))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //helper function for creating the zoom imageview
    func setupView(initialFrame frame: CGRect, view imageView: UIImageView) {
        //creates the scrollview to hold the images
        superScrollView = PictureViewer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), imageArray: self.imagesToView, scrollTo: nil)
        //holding the data of the scrollviews and the index
        storedScrollData = ScrollViewStorage(storedViews: superScrollView.imgViews, index: 0)
        //setting the delegate to self so that it can access functions
        superScrollView!.delegate = self
        //getting the current window to put the image view over completely
        currentWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        //holding the image that is currently being viewed
        //this is just for the animation of bringing up the image
        let tempImageView = UIImageView(frame: frame)
        tempImageView.image = imageView.image
        tempImageView.clipsToBounds = true
        tempImageView.contentMode = .scaleAspectFill
        //overlay the imageview with the whole window
        currentWindow!.addSubview(tempImageView)
        currentWindow?.backgroundColor = .clear
        //add tap gesture to hide the closeout bar and like options
        hideTap = UITapGestureRecognizer(target: self, action: #selector(hide))
        hideTap.numberOfTapsRequired = 1
        hideTap.delegate = self
        superScrollView.addGestureRecognizer(hideTap)
        //this is used to get the amount of likes
        //setLikeButton(liked: setLiked, count: likeAmount)
        //add double tap gesture recognizer for the image
        zoomTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapZoom(sender:)))
        zoomTap.numberOfTapsRequired = 2
        zoomTap.delegate = self
        superScrollView?.addGestureRecognizer(zoomTap)
        //get the contentview from the superscrollview which is stored at index 0
        contentView = superScrollView!.subviews[0]
        //get the offset for where to start the view
        let offset = CGFloat(Int(UIScreen.main.bounds.width + 20) * Int(startingIndex!))
        superScrollView?.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        dismissGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        dismissGesture.delegate = self
        superScrollView?.addGestureRecognizer(dismissGesture)
        
        
        //adding a blur view for the background of the image
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIScreen.main.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //setting up zoom data and adding the images
        for scrollView in contentView.subviews {
            //sView holds an instance of a scrollview for zooming
            let sView = scrollView as! UIScrollView
            //iView holds an instance of an imageview which will be input for the scrollview
            let iView = sView.subviews[0] as! UIImageView
            //get scroll delegate functions
            sView.delegate = self
            //set the maximum zoom scale for the image
            sView.maximumZoomScale = 3.0
            //add the sViews to the subScrollViews var
            subScrollViews.append(sView)
            //add the images to the subImageViews var
            subImageViews.append(iView)
        }
        
        //animation to bring imageview up and blue the background
        UIView.animate(withDuration: 0.35, animations: {
            self.currentWindow!.addSubview(self.blurEffectView)
            self.currentWindow?.bringSubviewToFront(tempImageView)
            tempImageView.contentMode = .scaleAspectFit
            tempImageView.frame.size = CGSize(width: self.parentView.frame.size.width, height: self.parentView.frame.size.height)
            tempImageView.center = self.parentView.center
        }) { (done) in
            //when its done then we add the superscrollview as the main view
            self.currentWindow!.addSubview(self.superScrollView!)
            //create the imageviews
            self.createInteractivePictureView()
            //tempImageView was only for the animation so remove it from the superview as it is unnecessary now
            tempImageView.removeFromSuperview()
        }
        print(superScrollView.subviews)
    }
    
    
    @objc func hide() {
        if topView.isHidden {
            self.topView.isHidden = false
            self.bottomView.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                self.bottomView.frame = CGRect(x: 0,
                                               y: self.parentView.frame.size.height - self.bottomView.frame.size.height,
                                               width: self.bottomView.frame.size.width,
                                               height: self.bottomView.frame.size.height)
                self.topView.frame = CGRect(x: 0,
                                            y: 0,
                                            width: self.topView.frame.size.width,
                                            height: self.topView.frame.size.height)
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.topView.frame = CGRect(x: 0,
                                            y: self.topView.frame.origin.y - self.topView.frame.size.height,
                                            width: self.topView.frame.size.width,
                                            height: self.topView.frame.size.height)
                self.bottomView.frame = CGRect(x: 0,
                                               y: self.bottomView.frame.origin.y + self.bottomView.frame.size.height,
                                               width: self.bottomView.frame.size.width,
                                               height: self.bottomView.frame.size.height)
            }) { (complete) in
                if complete {
                    self.topView.isHidden = true
                    self.bottomView.isHidden = true
                }
            }
        }
    }
    
    
    @objc func doubleTapZoom(sender: UITapGestureRecognizer) {
        if zoomed {
            if (!topView.isHidden) {
                UIView.animate(withDuration: 0.25, animations: {
                    self.topView.frame = CGRect(x: 0,
                                                y: self.topView.frame.origin.y - self.topView.frame.size.height,
                                                width: self.topView.frame.size.width,
                                                height: self.topView.frame.size.height)
                    self.bottomView.frame = CGRect(x: 0,
                                                   y: self.bottomView.frame.origin.y + self.bottomView.frame.size.height,
                                                   width: self.bottomView.frame.size.width,
                                                   height: self.bottomView.frame.size.height)
                }) { (complete) in
                    if complete {
                        self.topView.isHidden = true
                        self.bottomView.isHidden = true
                    }
                }
            }
            superScrollView.zoom(to: superScrollView.frame, animated: true)
            zoomed = false
        } else {
            if (!topView.isHidden) {
                UIView.animate(withDuration: 0.25, animations: {
                    self.topView.frame = CGRect(x: 0,
                                                y: self.topView.frame.origin.y - self.topView.frame.size.height,
                                                width: self.topView.frame.size.width,
                                                height: self.topView.frame.size.height)
                    self.bottomView.frame = CGRect(x: 0,
                                                   y: self.bottomView.frame.origin.y + self.bottomView.frame.size.height,
                                                   width: self.bottomView.frame.size.width,
                                                   height: self.bottomView.frame.size.height)
                }) { (complete) in
                    if complete {
                        self.topView.isHidden = true
                        self.bottomView.isHidden = true
                    }
                }
            }
            let point = sender.location(in: superScrollView)
            superScrollView.zoom(to: CGRect(x: point.x - 50 - superScrollView.contentOffset.x,
                                            y: point.y - 50,
                                            width: 100,
                                            height: 100),
                                            animated: true)
            zoomed = true
        }
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        print(self.subviews)
        let percentThreshold = 0.3
        let upwardPercentThreshold = -(percentThreshold)
        let translation = sender.translation(in: self.parentView)
        let vertMv = translation.y / self.parentView.bounds.height
        let downwardMv = fmaxf(Float(vertMv), 0.0)
        let downwardMvPercent = fminf(downwardMv, 1.0)
        let upwardMv = fmaxf(Float(vertMv), 1.0)
        let upwardMvPercent = fminf(Float(upwardMv), 0.0)
        let progress = downwardMvPercent
        if (sender.state == .began) {
            self.panCoord = sender.location(in: sender.view)
        }
        
        let newCoord: CGPoint = sender.location(in: sender.view)
        
        let dY = newCoord.y - panCoord.y
        if (vertMv > 0.05 || vertMv < -0.05) && !paging && !zoomed {
            sender.view?.frame = CGRect(x: 0,
                                        y: (sender.view?.frame.origin.y)!+dY,
                                        width: (sender.view?.frame.size.width)!,
                                        height: (sender.view?.frame.size.height)!)
            superScrollView?.isScrollEnabled = false
            if !topView.isHidden {
                UIView.animate(withDuration: 0.3, animations: {
                    self.topView.alpha = 0
                    self.bottomView.alpha = 0
                }) { (success) in
                    if success {
                        self.topView.isHidden = true
                        self.bottomView.isHidden = true
                    }
                }
            }
        }
        
        if !zoomed {
            switch sender.state {
            case .began:
                self.started = true
            case .changed:
                if vertMv > 0 {
                    self.gottaFinish = progress > Float(percentThreshold)
                } else if vertMv < 0 {
                    self.gottaFinish = upwardMvPercent < Float(upwardPercentThreshold)
                }
            case .cancelled:
                self.started = false
                superScrollView?.isScrollEnabled = true
                self.cancel()
            case .ended:
                self.started = false
                if !paging {
                    self.gottaFinish ? self.finish(direction: determineDirection(value: vertMv)) : self.cancel()
                }
            default:
                break
            }
        }
    }
    
    func determineDirection(value: CGFloat) -> Direction {
        if value > 0.0 {
            return .down
        }
        return .up
    }
 
    
    func cancel() {
        print(self.superScrollView)
        superScrollView.isScrollEnabled = true
        UIView.animate(withDuration: 0.4, animations: {
            if let scrollView = self.superScrollView {
                
                scrollView.frame = CGRect(x: 0, y: 0, width: self.parentView.frame.size.width + 20, height: self.superScrollView!.frame.size.height)
                
                
                if self.topView.isHidden && self.topView.frame == CGRect(x: 0,
                                                                         y: 0,
                                                                         width: self.topView.frame.size.width,
                                                                         height: self.topView.frame.size.height) {
                    self.topView.isHidden = false
                    self.bottomView.isHidden = false
                    self.topView.alpha = 1
                    self.bottomView.alpha = 1
                }
                
            }
            
        }) { (true) in
            self.gottaFinish = false
        }
        
    }

    
    func createInteractivePictureView() {
        topView.frame = CGRect(x: 0,
                               y: 0,
                               width: self.parentView.frame.size.width,
                               height: 60)
        topView.backgroundColor = .gray
        currentWindow?.addSubview(topView)
        bottomView.frame = CGRect(x: 0,
                                  y: currentWindow!.frame.size.height - 60,
                                  width: self.parentView.frame.size.width,
                                  height: 60)
        bottomView.backgroundColor = .gray
        currentWindow?.addSubview(bottomView)
        
        likeBtn = UIButton(frame: CGRect(x: 40,
                                         y: 15,
                                         width: 30,
                                         height: 30))
        likeBtn.setImage(UIImage(named: "NeutralStar.png"), for: .normal)
        bottomView.addSubview(likeBtn)
        commentBtn = UIButton(frame: CGRect(x: self.bottomView.center.x - 15,
                                            y: 15,
                                            width: 30,
                                            height: 30))
        commentBtn.setImage(UIImage(named: "Comment.png"), for: .normal)
        commentBtn.tintColor = .white
        bottomView.addSubview(commentBtn)
        moreBtn = UIButton(frame: CGRect(x: self.bottomView.frame.size.width - 40 - likeBtn.frame.size.width,
                                         y: 15,
                                         width: 30,
                                         height: 30))
        moreBtn.setImage(UIImage(named: "More.png"), for: .normal)
        bottomView.addSubview(moreBtn)
        likeCount = UILabel(frame: CGRect(x: self.likeBtn.frame.maxX + 3,
                                          y: 15,
                                          width: commentBtn.frame.minX - self.likeBtn.frame.maxX - 6,
                                          height: 30))
        likeCount.text = "232"
        bottomView.addSubview(likeCount)
        
    }
    
    
    func finish(direction: Direction) {
        UIView.animate(withDuration: 0.4, animations: {
            if let scrollView = self.superScrollView {
                if direction == .up {
                    scrollView.frame.origin.y = -(UIScreen.main.bounds.height)
                } else {
                    scrollView.frame.origin.y = UIScreen.main.bounds.height
                }
                if self.topView.isHidden && self.topView.frame == CGRect(x: 0,
                                                              y: 0,
                                                              width: self.topView.frame.size.width,
                                                              height: self.topView.frame.size.height) {
                    self.topView.frame = CGRect(x: 0,
                                                y: self.topView.frame.origin.y - self.topView.frame.size.height,
                                                width: self.topView.frame.size.width,
                                                height: self.topView.frame.size.height)
                    self.bottomView.frame = CGRect(x: 0,
                                                   y: self.bottomView.frame.origin.y + self.bottomView.frame.size.height,
                                                   width: self.bottomView.frame.size.width,
                                                   height: self.bottomView.frame.size.height)
                    
                }
            }
        }) { (success) in
            if success {
                if let scrollView = self.superScrollView {
                    self.blurEffectView.removeFromSuperview()
                    scrollView.removeFromSuperview()
                    self.gottaFinish = false
                    //self.deinitSuperScrollView()
                    self.topView.alpha = 1
                    self.bottomView.alpha = 1
                }
            }
        }
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if superScrollView == scrollView {
            if scrollView.subviews.count != 1 {
                let index = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
                var i = 0
                for subview in scrollView.subviews {
                    if i != index {
                        subview.removeFromSuperview()
                    }
                    i += 1
                }
                storedScrollData.index = index
                scrollView.contentSize = parentView.frame.size
                scrollView.subviews[0].frame = CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: parentView.frame.size.height)
            }
            scrollView.isPagingEnabled = false
            return scrollView.subviews[0]
        }
        
        return nil
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.hideTap &&
            otherGestureRecognizer == self.zoomTap {
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let scroll = self.superScrollView {
            if scrollView == scroll {
                paging = true
            }
        }
    }
    
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let scroll = self.superScrollView {
            if scrollView == scroll {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                    self.paging = false
                }
            }
        }
    }
    
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale <= 1.0 {
            let x = CGFloat(scrollView.subviews[0].tag) * (parentView.frame.size.width + 20)
            if scrollView.subviews.count == 1 {
                scrollView.subviews[0].removeFromSuperview()
            }
            self.superScrollView.removeFromSuperview()
            self.superScrollView = PictureViewer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), imageArray: imagesToView, scrollTo: CGPoint(x: x, y: 0))
            addGestureRecogizers()
            currentWindow?.addSubview(superScrollView)
            self.superScrollView!.delegate = self
        }
    }
    
    func addGestureRecogizers() {
        superScrollView?.addGestureRecognizer(hideTap)
        superScrollView?.addGestureRecognizer(dismissGesture)
        superScrollView?.addGestureRecognizer(zoomTap)
    }
    
    
}




