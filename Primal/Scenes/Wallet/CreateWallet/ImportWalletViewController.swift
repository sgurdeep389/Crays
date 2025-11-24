//
//  ImportWalletViewController.swift
//  Crays
//
//  Created by Gurdeep Singh  on 22/11/25.
//

import UIKit

import UIKit
//import BreezSdkSpark
import Bip39

class ImportWalletViewController: UIViewController {
    @IBOutlet weak var btnImport: UIButton!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var txtViewPhase: UITextView!
    @IBOutlet weak var lblWordNumber: UILabel!
    @IBOutlet weak var viewTxt: UIView!
    @IBOutlet weak var viewWordNumber: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "Import Wallet"
        self.viewTop.layer.borderColor = #colorLiteral(red: 0.3098039216, green: 0.8196078431, blue: 0.7725490196, alpha: 1)
        self.viewBottom.layer.borderColor = #colorLiteral(red: 0.9647058824, green: 0.6784313725, blue: 0.3333333333, alpha: 1)
        self.viewTop.layer.borderWidth = 1
        self.viewBottom.layer.borderWidth = 1
        self.viewTop.layer.cornerRadius = 15
        self.viewBottom.layer.cornerRadius = 15
        self.btnImport.layer.cornerRadius = 15
        self.viewTxt.layer.cornerRadius = 15
        self.viewTxt.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.9098039216, blue: 0.9411764706, alpha: 1)
        self.viewTxt.layer.borderWidth = 1
        self.viewWordNumber.layer.cornerRadius = 8
        self.txtViewPhase.delegate = self
        self.lblWordNumber.text = "0 words"
    }
    
    @IBAction func btnActionImport(_ sender: UIButton) {
        if self.txtViewPhase.text.components(separatedBy: " ").count > 11{
            if let mnemonicString = self.txtViewPhase.text{
                let isValid = Mnemonic.isValid(phrase: mnemonicString.components(separatedBy: " "))
                if isValid{
                    self.createWallet()
                }
            }
        }
    }
    
    func createWallet() {
//        Task {
//            do {
//                let seed = Seed.mnemonic(mnemonic: self.txtViewPhase.text, passphrase: nil)
//
//                var config = defaultConfig(network: Network.mainnet)
//                config.apiKey = "MIIBdDCCASagAwIBAgIHPpfhotBcKzAFBgMrZXAwEDEOMAwGA1UEAxMFQnJlZXowHhcNMjUxMDMwMTcxMzExWhcNMzUxMDI4MTcxMzExWjAmMRIwEAYDVQQKEwlDb2RlIElkZWExEDAOBgNVBAMTB0d1cm5vb3IwKjAFBgMrZXADIQDQg/XL3yA8HKIgyimHU/Qbpxy0tvzris1fDUtEs6ldd6OBiDCBhTAOBgNVHQ8BAf8EBAMCBaAwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU2jmj7l5rSw0yVb/vlWAYkK/YBwkwHwYDVR0jBBgwFoAU3qrWklbzjed0khb8TLYgsmsomGswJQYDVR0RBB4wHIEac2luZ2hqYXNrYXJhbi5jaUBnbWFpbC5jb20wBQYDK2VwA0EA4PSjNi+1g8D+AIJQGGXS5va926BkffEJDi6ubz1A7/BiwzPRxLNZ/3n3FVvxaxHGLDKOJpGqwNtX+dUpNihIBg=="
//
//                // Get writable storage dir
//                let storageDir = FileManager.default.urls(
//                    for: .applicationSupportDirectory,
//                    in: .userDomainMask
//                ).first!.appendingPathComponent("breez_data").path
//
//                // Create directory if needed
//                if !FileManager.default.fileExists(atPath: storageDir) {
//                    try FileManager.default.createDirectory(atPath: storageDir, withIntermediateDirectories: true)
//                }
//
//                let builder = SdkBuilder(config: config, seed: seed)
//
//                // Use correct writable path
//                await builder.withDefaultStorage(storageDir: storageDir)
//
//                let sdk = try await builder.build()
//                WalletManager1.shared.saveMnemonic(self.txtViewPhase.text)
//                self.navigationController?.pushViewController(WalletSuccessfullyVC(), animated: true)
//                print("Wallet created successfully")
//
//            } catch {
//                print("❌ Failed to create wallet:", error.localizedDescription)
//            }
//        }
    }
    
}

extension ImportWalletViewController:UITextViewDelegate{
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {

        // Predict the final text after the change
        let currentText = textView.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: textRange, with: text)

        // Count words
        let words = updatedText.split { $0.isWhitespace }

        // Allow typing only if ≤ 12 words
        self.lblWordNumber.text = "\(words.count) words"
        return true
    }
}


