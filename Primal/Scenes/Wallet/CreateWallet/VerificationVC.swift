//
//  VerificationVC.swift
//  Crays
//
//  Created by Gurdeep Singh  on 23/11/25.
//

import UIKit
import Bip39
import BreezSdkSpark

class VerificationVC: UIViewController {
    @IBOutlet weak var btnVerification: UIButton!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var txtFldWord1: UITextField!
    @IBOutlet weak var txtFldWord2: UITextField!
    @IBOutlet weak var txtFldWord3: UITextField!
    @IBOutlet weak var txtFldWord4: UITextField!
    var mnemonicString:String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnVerification.layer.cornerRadius = 15

        self.viewTop.layer.cornerRadius = 15
        self.viewTop.layer.borderWidth = 1
        self.viewTop.layer.borderColor = #colorLiteral(red: 0.3098039216, green: 0.8196078431, blue: 0.7725490196, alpha: 1)
        
        
        self.txtFldWord1.layer.cornerRadius = 10
        self.txtFldWord1.layer.borderWidth = 1
        self.txtFldWord1.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.9098039216, blue: 0.9411764706, alpha: 1)

        
        self.txtFldWord2.layer.cornerRadius = 10
        self.txtFldWord2.layer.borderWidth = 1
        self.txtFldWord2.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.9098039216, blue: 0.9411764706, alpha: 1)

        
        self.txtFldWord3.layer.cornerRadius = 10
        self.txtFldWord3.layer.borderWidth = 1
        self.txtFldWord3.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.9098039216, blue: 0.9411764706, alpha: 1)

        self.txtFldWord4.layer.cornerRadius = 10
        self.txtFldWord4.layer.borderWidth = 1
        self.txtFldWord4.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.9098039216, blue: 0.9411764706, alpha: 1)
        
        self.txtFldWord4.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        self.txtFldWord4.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        self.txtFldWord4.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        self.txtFldWord4.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        self.updateVerifyButtonState()
    }
    
    
    private func updateVerifyButtonState() {
        let allFilled = self.txtFldWord1.text!.isEmpty && self.txtFldWord2.text!.isEmpty && self.txtFldWord3.text!.isEmpty && self.txtFldWord4.text!.isEmpty
        self.btnVerification.isEnabled = !allFilled
        self.btnVerification.alpha = !allFilled ? 1.0 : 0.5
    }
    
    @objc private func textFieldChanged(_ sender: UITextField) {
        self.updateVerifyButtonState()
     }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActionVerification(_ sender: UIButton) {
        let array = self.mnemonicString.components(separatedBy: " ")
        if array.count > 11{
            if array[2] == self.txtFldWord1.text && array[5] == self.txtFldWord2.text && array[8] == self.txtFldWord3.text && array[9] == self.txtFldWord4.text{
                let isValid = Mnemonic.isValid(phrase: self.mnemonicString.components(separatedBy: " "))
                if isValid{
                    self.createWallet()
                }
            }
        }
    }
    
    func createWallet() {
        Task {
            do {
                let seed = Seed.mnemonic(mnemonic: self.mnemonicString, passphrase: nil)

                var config = defaultConfig(network: Network.mainnet)
                config.apiKey = "MIIBdDCCASagAwIBAgIHPpfhotBcKzAFBgMrZXAwEDEOMAwGA1UEAxMFQnJlZXowHhcNMjUxMDMwMTcxMzExWhcNMzUxMDI4MTcxMzExWjAmMRIwEAYDVQQKEwlDb2RlIElkZWExEDAOBgNVBAMTB0d1cm5vb3IwKjAFBgMrZXADIQDQg/XL3yA8HKIgyimHU/Qbpxy0tvzris1fDUtEs6ldd6OBiDCBhTAOBgNVHQ8BAf8EBAMCBaAwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU2jmj7l5rSw0yVb/vlWAYkK/YBwkwHwYDVR0jBBgwFoAU3qrWklbzjed0khb8TLYgsmsomGswJQYDVR0RBB4wHIEac2luZ2hqYXNrYXJhbi5jaUBnbWFpbC5jb20wBQYDK2VwA0EA4PSjNi+1g8D+AIJQGGXS5va926BkffEJDi6ubz1A7/BiwzPRxLNZ/3n3FVvxaxHGLDKOJpGqwNtX+dUpNihIBg=="

                // Get writable storage dir
                let storageDir = FileManager.default.urls(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask
                ).first!.appendingPathComponent("breez_data").path

                // Create directory if needed
                if !FileManager.default.fileExists(atPath: storageDir) {
                    try FileManager.default.createDirectory(atPath: storageDir, withIntermediateDirectories: true)
                }

                let builder = SdkBuilder(config: config, seed: seed)

                // Use correct writable path
                await builder.withDefaultStorage(storageDir: storageDir)

                let sdk = try await builder.build()
                WalletManager1.shared.saveMnemonic(self.mnemonicString)
                self.navigationController?.pushViewController(WalletSuccessfullyVC(), animated: true)
                print("Wallet created successfully")

            } catch {
                print("❌ Failed to create wallet:", error.localizedDescription)
            }
        }
    }


}
