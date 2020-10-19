//
//  RootTabbarController.swift
//  Mp3App
//
//  Created by AnhLD on 9/29/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import UIKit
import Reusable

class RootTabbarController: UITabBarController, StoryboardBased {
    
    private var tabbarY: CGFloat!
    private let miniPlayerHeight = 52
    let playerView = PlayerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 50 - 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 52))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUpTabBar()
        setupPlayView()
        setupPanGesture()
        //UITabBar.appearance().barTintColor = UIColor.white
        tabBar.isTranslucent = false
    }
    
    private func setupPlayView() {
        view.addSubview(playerView)
        view.bringSubviewToFront(tabBar)
        tabbarY = tabBar.frame.origin.y
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        playerView.addGestureRecognizer(panGesture)
    }
    
    @objc func panGestureRecognizerAction(gesture: UIPanGestureRecognizer) {
//        let translation = sender.translation(in: view)
//        playView.frame.origin.y = translation.y
//        print(translation)
        
        let translation = gesture.translation(in: view)
                let contentHeight = UIScreen.main.bounds.height - tabBar.frame.height - 50
                switch gesture.state {
                case .began:
//                    playerViewController.miniPlayerView.enableInteraction(false)
                    print("began")
                case .changed:
                    let containerY = playerView.frame.origin.y
                    if containerY <= contentHeight && containerY >= view.bounds.origin.y {
                        if containerY + translation.y < 0 {
                            playerView.frame.origin.y = view.bounds.origin.y
                            tabBar.frame.origin.y = tabbarY + tabBar.frame.height
                        } else if containerY + translation.y > contentHeight {
                            playerView.frame.origin.y = contentHeight
                            tabBar.frame.origin.y = tabbarY
                        } else {
                            playerView.frame.origin.y += translation.y
                            tabBar.frame.origin.y -= translation.y * (tabBar.frame.height/contentHeight)
                        }
                        print("tabbar frame = \(tabBar.frame.origin.y)")
//                        playerViewController.miniPlayerView.alpha = 1 - miniPlayerPercentage
//                        playerViewController.contentView.alpha = fullPlayerContentPercentage
                        gesture.setTranslation(.zero, in: view)
                    }
                case .ended:
                    let velocity = gesture.velocity(in: view)
                    if velocity.y > 0 {
        //                self.isStatusBarHidden = false
                        UIView.animate(withDuration: 0.3, animations: {
                            self.playerView.frame.origin.y = self.tabbarY - 50
//                            self.playerViewController.miniPlayerView.alpha = 1
//                            self.playerViewController.contentView.alpha = 0
                            self.tabBar.frame.origin.y = self.tabbarY
                        }) { _ in
//                            self.playerViewController.miniPlayerView.enableInteraction(true)
//                            print("end gesture frame = \(self.tabBar.frame.origin.y)")
                        }
                    } else {
        //                self.isStatusBarHidden = true
                        UIView.animate(withDuration: 0.3, animations: {
                            self.playerView.frame.origin.y = -52
//                            self.playerViewController.miniPlayerView.alpha = 0
//                            self.playerViewController.contentView.alpha = 1
                            self.tabBar.frame.origin.y = self.tabbarY + self.tabBar.frame.height
                        }) { _ in
//                            self.playerViewController.miniPlayerView.enableInteraction(false)
                            print("tabbar frame = \(self.tabBar.frame.height)")
                        }
                    }
                default:
                    break
                }
    }
}
