//
//  IntroVideoController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SwiftUI
import Lottie

final class IntroVideoController: UIViewController {
    private let video: UIImageView = {
          let imageView = UIImageView(image: UIImage(named: "Frame 1948755992.png"))
          imageView.contentMode = .scaleAspectFill   // or .scaleAspectFit
          imageView.clipsToBounds = true
          return imageView
      }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(video)
        video.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            video.topAnchor.constraint(equalTo: view.topAnchor),
            video.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            video.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            video.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
