//
//  FeedNavigationController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit
import SwiftUI

extension UINavigationController {
    func fadeTo(_ viewController: UIViewController) {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
}

class MainNavigationController: UINavigationController, Themeable, UIGestureRecognizerDelegate {
    var isTransparent: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        viewControllers.last?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    weak var backGestureDelegate: UIGestureRecognizerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
            
        interactivePopGestureRecognizer?.delegate = self
        
        delegate = self
        
        updateAppearance()
    }
    
    func updateTheme() {
        updateAppearance()
        
        viewControllers.forEach { $0.updateThemeIfThemeable() }
    }
    
    func updateAppearance() {
        let appearance = UINavigationBarAppearance()
        if isTransparent {
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [
                .font: UIFont.appFont(withSize: 20, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        } else {
            appearance.backgroundColor = .background
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                .font: UIFont.appFont(withSize: 20, weight: .bold),
                .foregroundColor: UIColor.foreground
            ]
        }
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1 && (backGestureDelegate?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true)
    }
}

extension MainNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC as? WalletTransferSummaryController != nil {
            return SlideDownAnimator(presenting: false)
        }
        
        if let home: WalletHomeViewController = fromVC.findInChildren() ?? toVC.findInChildren() {
            let isPresenting = fromVC.children.contains(where: { $0 == home })
            
            if let qrCode: WalletQRCodeViewController = fromVC.findInChildren() ?? toVC.findInChildren() {
                if isPresenting {
                    return WalletQRTransitionAnimator(home: home, qrController: qrCode, presenting: isPresenting)
                }
            }
            
            if let user: WalletPickUserController = fromVC.findInChildren() ?? toVC.findInChildren() {
                if isPresenting {
                    return WalletSendTransitionAnimator(home: home, userController: user, presenting: isPresenting)
                }
            }
            
            if let receive = toVC as? WalletReceiveViewController {
                return WalletReceiveTransitionAnimator(home: home, receive: receive, presenting: isPresenting)
            }
            
            if let transaction = toVC as? TransactionViewController ?? fromVC as? TransactionViewController {
                return WalletHomeToTransactionAnimator(home: home, transactionController: transaction, isPresenting: isPresenting)
            }
            
            return nil
        }
        
        if let amount = fromVC as? WalletSendAmountController ?? toVC as? WalletSendAmountController {
            if let userList: WalletPickUserController = fromVC.findInChildren() ?? toVC.findInChildren() {
                let isPresenting = amount == toVC
                return UserListToSendAnimator(userListController: userList, sendController: amount, isPresenting: isPresenting)
            }
            
            if let send = fromVC as? WalletSendViewController ?? toVC as? WalletSendViewController {
                return WalletSendAmountSendAnimator(sendAmount: amount, send: send, presenting: amount == fromVC)
            }
            
            return nil
        }
        
        if let send = fromVC as? WalletSendViewController ?? toVC as? WalletSendViewController {
            if let spinner = toVC as? WalletSpinnerViewController {
                return WalletSendSpinnerAnimator(sendController: send, spinner: spinner)
            }
        }
        
        if let result = toVC as? WalletTransferSummaryController {
            if let spinner = fromVC as? WalletSpinnerViewController {
                return WalletSpinnerToResultAnimator(spinner: spinner, result: result)
            }
        }
        
        if let longForm = toVC as? ArticleViewController {
            if operation == .pop { return nil }
            if let listVC = fromVC as? ArticleCellController {
                return ArticleTransition(listVCs: [listVC], longFormController: longForm, presenting: true)
            }
            return ArticleTransition(listVCs: fromVC.findAllChildren(), longFormController: longForm, presenting: true)
        }
        
        if let article = fromVC as? ArticleViewController {
            if operation == .push { return nil }
            if let listVC = toVC as? ArticleCellController {
                return ArticleTransition(listVCs: [listVC], longFormController: article, presenting: false)
            }
            return ArticleTransition(listVCs: toVC.findAllChildren(), longFormController: article, presenting: false)
        }
        
        return nil
    }
}


class NearByChat: UIViewController {
    private let chatViewModel = ChatViewModel()   // 👈 regular property

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = customBackButton
        navigationItem.title = "CRAYS MESH"
        GeoRelayDirectory.shared.prefetchIfNeeded()

        // Create the SwiftUI view
        let swiftUIView = ContentView().environmentObject(self.chatViewModel)
        
        // Wrap in UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add as child VC
        addChild(hostingController)
        hostingController.view.frame = self.view.bounds
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hostingController.view)
        
        // Constraints to fit
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatViewModel.meshService.startServices()

        // Inject live Noise service into VerificationService to avoid creating new BLE instances
        VerificationService.shared.configure(with: chatViewModel.meshService.getNoiseService())
        // Prewarm Nostr identity and QR to make first VERIFY sheet fast
        DispatchQueue.global(qos: .utility).async {
            let npub = try? NostrIdentityBridge.getCurrentNostrIdentity()?.npub
            _ = VerificationService.shared.buildMyQRString(nickname: self.chatViewModel.nickname, npub: npub)
        }
    }
}

