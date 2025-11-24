//
//  UnderDevVC.swift
//  Primal
//
//  Created by Gurdeep Singh  on 17/09/25.
//

import UIKit
import AVKit
import AVFoundation

class UnderDevVC: UIViewController {
    @IBOutlet weak var btnWatch: UIButton!   // Connect this from storyboard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnWatch.addTarget(self, action: #selector(watchNowTapped), for: .touchUpInside)
        self.btnWatch.layer.cornerRadius = 10
        // Load video from bundle
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update frame on rotation
    }
    
    @objc private func watchNowTapped() {
        // Navigate to your video player screen
        let videoVC = VideoPlayerViewController() // Replace with your player VC
        self.present(videoVC, animated: true)
    }
    
}


class VideoPlayerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.playVideo()
    }
    
    private func playVideo() {
        // Example: Load a video from your project bundle
        guard let path = Bundle.main.path(forResource: "devVideo", ofType: "mp4") else {
            print("Video file not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = view.bounds
        
        // Add as child VC
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
        // Auto play
        player.play()
    }
    
    
}
