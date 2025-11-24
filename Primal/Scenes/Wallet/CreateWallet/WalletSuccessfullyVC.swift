//
//  WalletSuccessfullyVC.swift
//  Crays
//
//  Created by Gurdeep Singh  on 23/11/25.
//

import UIKit
import Lottie

class WalletSuccessfullyVC: UIViewController {
    @IBOutlet weak var btnWallet: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTile: UILabel!
    @IBOutlet weak var viewLottie: UIView!
    @IBOutlet weak var viewBack: UIView!
    var timer: Timer?
    var counter = 5
    var loadingSpinnerAnimation: AnimationType { .walletSuccessfully }
    let animView = LottieAnimationView().constrainToSize(width: 150, height: 150)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.viewBack.layer.cornerRadius = 15
        self.btnWallet.layer.cornerRadius = 10
        self.lblTime.text = "Redirecting automatically in \(self.counter) seconds...."
        self.startTimer()
        self.animView.animation = self.loadingSpinnerAnimation.animation
        self.animView.play()
        self.animView.loopMode = .loop
        self.viewLottie.addSubview(self.animView)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.stopTimer()
    }

    func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.counter -= 1
            self.lblTime.text = "Redirecting automatically in \(self.counter) seconds...."
            if self.counter < 1{
                
            }
        }
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
